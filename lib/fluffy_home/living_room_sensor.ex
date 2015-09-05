defmodule FluffyHome.LivingRoomSensor do
  use GenServer

  alias Statistics

  alias FluffyHome.InfluxDb
  alias FluffyHome.Endpoint

  require Logger


  # TODO: make configurable
  @name          "living-room"
  @database_name "fluffy_home"

  @interval_live 3_000
  @interval_save 30_000

  @serial_path   System.get_env("ARDUINO_USB_PORT")
  @serial_speed  115_200

  @known_sensor_values ~w(air_quality humidity temperature)
  @known_serial_errors ["Checksum error\r\n", "Time out error\r\n", "Unknown error\r\n"]


  defp receive_until_line_ending(jsonString \\ "") do
    receive do
      {:data, chunk} when is_binary(chunk) ->
        jsonString = jsonString <> chunk

      _error ->
        Logger.error "received _error from serial port: #{inspect _error}"
        # TODO: stop_link and restart in a minute or so

    after
      10_000 ->
        Logger.warn "Didn't receive any new Serial Input in the last ten seconds."
    end

    if String.ends_with? jsonString, "\r\n" do
      jsonString # return
    else
      receive_until_line_ending(jsonString)
    end
  end


  defp get_new_values_from_serial(_interval_counter, serial_pid) do
    # TODO: only when pid |> Process.alive?

    # send control signal
    send serial_pid, {:send, '1'}

    # wait until response is complete
    jsonString = receive_until_line_ending()

    case jsonString do
      x when x in @known_serial_errors ->
        {:halt, serial_pid}
      _ ->
        Poison.Parser.parse!(jsonString)
    end
    # (?) validate values -> -40 < temp < 60 || 0 <= hum <= 100 || x < air_q < y
    # return values
  end


  # Calculates the medians from a given array of Maps containing keys in `@known_sensor_values`
  defp calculate_medians(aggregated_values) do
    Enum.reduce @known_sensor_values, %{}, fn(x, result) ->
      median = aggregated_values |> Enum.map(&Map.get(&1, x)) # take raw value
                                 |> Statistics.median()
                                 |> Float.round(1)

      Map.put(result, x, median) # put into accumulator
    end
  end


  # Takes each key from `@known_sensor_values` out of a given Map and converts it into a List
  # of datapoints suitable for Instream and saves them to InfluxDb afterwards.
  defp write_to_influxdb(median_values) do
    points = Enum.map @known_sensor_values, fn(x) ->
      %{measurement: x,
        tags: %{location: @name},
        fields: %{value: Map.get(median_values, x)}}
    end

    %{database: @database_name, points: points} |> Instream.Data.Write.query()
                                                |> InfluxDb.execute([async: true])
  end


  # Broadcasts given values to a given channel in room `"rooms:#{@name}"`.
  defp broadcast!(values, channel) do
    values_as_list = Enum.map @known_sensor_values, fn(x) ->
      %{
        name: x,
        value: Map.get(values, x)
      }
    end

    Endpoint.broadcast!("rooms:#{@name}", channel, %{values: values_as_list})
    values # return for further piping
  end


  ##-------------------------------------------------- Client API
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  ##-------------------------------------------------- Callbacks (aka Server API)
  def init(:ok) do
    serial_pid = :serial.start [{:open, @serial_path}, {:speed, @serial_speed}]
    Process.send_after(self(), :work, @interval_live)
    {:ok, serial_pid}
  end

  def handle_info(:work, serial_pid) do
    do_work(serial_pid)
    {:noreply, serial_pid}
  end

  defp do_work(serial_pid) do
    Stream.interval(@interval_live)
      |> Stream.map(&get_new_values_from_serial(&1, serial_pid))
      |> Stream.map(&broadcast!(&1, "live:#{@name}"))
      |> Enum.take(div(@interval_save, @interval_live))
      |> calculate_medians()
      |> write_to_influxdb

    do_work(serial_pid)
  end

  def terminate(reason, serial_pid) do
    Logger.error "Terminating... reason: #{inspect(reason)}"
    serial_pid |> send :stop
    {:ok}
  end
end
