defmodule SmalltalkCrawler.Crawler do
  use GenServer
  require Logger
  use Timex

  #Every 5 minutes
  @timeout 5 * 60 * 1000

  def crawl() do 
    GenServer.cast(Crawler, {:crawl}) 
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: Crawler)
  end

  def init(_opts \\ []) do
    start_timeout()
    crawl()
    {:ok, %{}}    
  end

  def terminate(reason, _state) do 
    Logger.debug("Crawler terminating #{inspect reason}")
    :ok
  end

  def handle_info({:crawl_timeout}, state) do 
    Logger.debug("Crawler :crawl_timeout")
    crawl()
    start_timeout()    
    {:noreply, state}
  end

  def handle_cast({:crawl}, state) do
    SmalltalkCrawler.Subscription.subscribed_channels() 
    |> Enum.each(fn(distinct_subscription) ->
      crawl_channel(distinct_subscription.channel, distinct_subscription.service) 
    end)
    {:noreply, state}
  end

  defp start_timeout() do
    Process.send_after(self(), {:crawl_timeout}, @timeout)
  end

  defp crawl_channel(channel, service) do
    uri = "#{service_uri(service)}#{channel}"
    case HTTPoison.get(uri) do
      {:ok, %HTTPoison.Response{status_code: 200, body: rssBody}} ->
        {:ok, feed, _} = FeederEx.parse(rssBody)
        subscribers = SmalltalkCrawler.Subscription.channel_subscribers(channel)

        Enum.each(subscribers, fn(subscriber) -> #For all subscribers
          send_entries(subscriber, feed.title, feed.entries) 
        end)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("HTTP get not found :( #{uri}")
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP get error #{inspect reason}")
    end
  end

  #Case where the user has just subscribed to the feed and has not been sent any updates yet
  defp send_entries(%{ latest_update_sent: nil} = subscriber, channel_title, feed_entries) do
    [latest_entry | _] = feed_entries        
    SmalltalkCrawler.XMPPBot.send(channel_title, latest_entry.title, latest_entry.summary, latest_entry.link, subscriber)
  end
  
  #Send all entries that have occurred between now and latest_update_sent
  defp send_entries(subscriber, channel_title, feed_entries) do 
    entries_to_send = Enum.reduce(feed_entries, [], fn(entry, entries_to_send) ->
      feed_published = feed_published_datetime(entry.published)
      #Check if this link has already been handled by the subscriber
      if Ecto.DateTime.compare(feed_published, subscriber.latest_update_sent) == :gt do
        entries_to_send = [entry | entries_to_send] 
      end
      entries_to_send
    end)

    Logger.debug("Entries to handle #{length(entries_to_send)}")
    Enum.reduce(entries_to_send, 0, fn(entry, wait_period) -> #All entries to this subscriber
      #We don't want to flood single user with a massive single burst so we send them 1000 ms apart
      Logger.debug("Spawn to wait #{wait_period}")
      spawn(fn() ->
        Logger.debug("Spawned waiting #{wait_period}")
        :timer.sleep(wait_period)
        SmalltalkCrawler.XMPPBot.send(channel_title, entry.title, entry.summary, entry.link, subscriber)      
      end)
      wait_period + 2000
    end)
  end
 
  #We have to do a bit of datetime conversion tweaking here as Ecto.DateTime doesn't know
  #how to parse the youtube published datetime
  defp feed_published_datetime(youtube_formatted_iso_datetime) do 
        {:ok, published_datetime} = youtube_formatted_iso_datetime |> DateFormat.parse("{ISO}")
        erl_time = published_datetime |> DateConvert.to_erlang_datetime
        {:ok, published} = Ecto.DateTime.cast(erl_time)
        published
  end
  
  defp service_uri("youtube") do
    "https://www.youtube.com/feeds/videos.xml?channel_id="
  end
end

