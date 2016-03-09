defmodule SmalltalkCrawler.Router do
  use SmalltalkCrawler.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SmalltalkCrawler do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", SmalltalkCrawler do
    pipe_through :api
    post "/crawler/crawl", CrawlController, :crawl
    post "/subscribe/new", SubscribeController, :new
    post "/subscribe/delete", SubscribeController, :delete    
    get "/subscribe/get", SubscribeController, :get    
  end
end
