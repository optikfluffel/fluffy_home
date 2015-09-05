defmodule FluffyHome.RoomChannel do
  use FluffyHome.Web, :channel

  def join("rooms:living-room", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # TODO: Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
