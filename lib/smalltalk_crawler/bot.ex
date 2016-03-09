defmodule SmalltalkCrawler.XMPPBot do
  use GenServer
  use Hedwig.XML  
  require Logger

  def send(channel_title, title, summary, link, subscriber) do 
    GenServer.cast(XMPPBot, {:send, channel_title, title, summary, link, subscriber}) 
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: XMPPBot)
  end

  def init(_opts \\ []) do
    {:ok, pid} = Hedwig.start_client(hd(Application.get_env(:hedwig, :clients)))
    {:ok, %{ pid: pid}}    
  end

  def terminate(reason, _state) do 
    Logger.debug("Crawler terminating #{inspect reason}")
    :ok
  end

  def handle_cast({:send, channel_title, title, _summary, link, subscriber}, state) do
    msg = title    
    to_user = subscriber.username 
    from_jid = hd(Application.get_env(:hedwig, :clients)).jid
    from_user = hd(String.split(from_jid, "@"))
    thread_id = subscriber.thread
    msg_id = msg_id(from_user, to_user, thread_id, link) 
    stanza = Hedwig.Stanza.chat("#{to_user}@smalltalk.com", msg)

    {:xmlel, type, attr, [body]} = stanza
    #Switch message id from generated to our own
    attr =  [ {"id", msg_id}, {"from", from_jid}, {"fromName", channel_title} | :proplists.delete("id", attr) ]
    tId = xmlel(name: "thread", children: [ :exml.escape_cdata(thread_id) ])
    content_json = %{ id: link, title: title, channel_title: channel_title }
    attachment = xmlel(
      name: "content", 
      attrs: [{"content-type", "application/youtube"}],
      children: [ 
        :exml.escape_cdata(Poison.encode!(content_json)) 
      ]
    )

    stanza = {:xmlel, type, attr, [body, tId, attachment]}
    Hedwig.Client.reply(state.pid, stanza)
    SmalltalkCrawler.Subscription.channel_update_handled(subscriber)
    {:noreply, state}
  end

  defp msg_id(from, to, thread_id, link) do
    "#{from}#{to}#{thread_id}#{link}"
  end
end

