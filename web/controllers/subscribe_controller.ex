defmodule SmalltalkCrawler.SubscribeController do
  use SmalltalkCrawler.Web, :controller
  require Logger

  def new(conn, params) do
    Logger.debug("#{inspect params}")
    thread = params["threadId"]
    channel = params["channelId"]
    {_, highest_ret_code} = params["participants"]
    #Returns http return codes based on success of subscribe
    |> Enum.map(fn(participant) ->
      SmalltalkCrawler.Subscription.find_subscription(participant, thread, channel)
      |> subscribe(thread, channel, participant)
    end) 
    #We're interested in the highest return code in case we get errors
    |> Enum.min_max

    SmalltalkCrawler.Crawler.crawl()
    conn
    |> put_status(highest_ret_code)
    |> json %{}
  end

  def delete(conn, params) do
    Logger.debug("#{inspect params}")
    thread = params["threadId"]
    channel = params["channelId"]
    params["participants"]
    |> Enum.each(fn(participant) ->
      SmalltalkCrawler.Subscription.unsubscribe(participant, channel, thread)
    end) 

    conn
    |> put_status(200)
    |> json %{}
  end

  def get(conn, params) do
    Logger.debug("#{inspect params}")
    thread = params["threadId"]
    channel = params["channelId"]
    user = params["user"]
    exists = subscription_exists(SmalltalkCrawler.Subscription.find_subscription(user, thread, channel))
    conn
    |> put_status(200)
    |> json %{status: exists}
  end

  #Subscription doesn't exist yet
  defp subscribe(nil, thread, channel, participant) do
    SmalltalkCrawler.Subscription.subscribe(participant, "1-on-1", channel, "youtube", thread)
    200
  end

  defp subscribe(_, _, _, _) do
    Logger.debug("Subscription exists already")
    400
  end

  defp subscription_exists(nil) do
    false
  end

  defp subscription_exists(_) do
    true
  end
end


