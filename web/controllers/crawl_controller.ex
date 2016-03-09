defmodule SmalltalkCrawler.CrawlController do
  use SmalltalkCrawler.Web, :controller
  
  def crawl(conn, _params) do
    SmalltalkCrawler.Crawler.crawl()
    conn
    |> put_status(200)
    |> json %{}
  end
end

