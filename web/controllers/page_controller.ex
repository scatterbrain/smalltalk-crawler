defmodule SmalltalkCrawler.PageController do
  use SmalltalkCrawler.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
