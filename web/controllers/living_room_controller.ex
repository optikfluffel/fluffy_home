defmodule FluffyHome.LivingRoomController do
  use FluffyHome.Web, :controller
  alias FluffyHome.InfluxDb
  require Logger

  @database_name "fluffy_home"
  @name "living-room"

  @known_sensor_values ~w(air_quality humidity temperature)

  defp build_median_query(measurement, start_time, resolution) do
    select   = "SELECT median(value) FROM #{measurement}"
    where    = "WHERE time > now() - #{start_time} AND location = '#{@name}'"
    group_by = "GROUP BY time(#{resolution});"

    # return query
    "#{select} #{where} #{group_by}"
  end

  defp pull_data_from_influx_db(query) do
    query |> Instream.Data.Read.query()
          |> InfluxDb.execute(database: @database_name)
  end

  defp take_series_from_influxdb_result(result) do
    result |> Map.get(:results)
           |> List.first()
           |> Map.get(:series)
  end

  def last_hour(conn, %{"measurement" => measurement}) do
    if Enum.member?(@known_sensor_values, measurement) do
      series = measurement |> build_median_query("1h", "5m")
                           |> pull_data_from_influx_db()
                           |> take_series_from_influxdb_result()

      case series do
        nil -> conn |> json([])

        _ when is_list(series) ->
          result = series |> List.first() # take first series only
                          |> Map.get(:values)
                          |> Enum.map(&%{date: List.first(&1), value: List.last(&1)})

          conn |> json(result)
      end
    else
      conn |> put_status(:not_found)
    end
  end
end
