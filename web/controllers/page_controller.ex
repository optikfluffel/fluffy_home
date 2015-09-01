defmodule FluffyHome.PageController do
  use FluffyHome.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
