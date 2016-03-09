defmodule SmalltalkCrawler.Subscription do
  use Ecto.Model
  import Ecto.Query
  require Logger

  schema "subscriptions" do 
  field :type, :string
  field :username, :string
  field :thread, :string
  field :channel, :string
  field :service, :string
  field :latest_update_sent, Ecto.DateTime
  timestamps
  end

  @required_fields ~w(type username thread channel service)
  @optional_fields ~w()

  def find_subscription(username, thread, channel) do
    query = from w in __MODULE__,
    where: w.username == ^username and w.thread == ^thread and w.channel == ^channel, 
    select: w

    SmalltalkCrawler.Repo.one(query)
  end

  def subscribed_channels() do
    query = from w in __MODULE__,
    distinct: [w.channel, w.service], 
    select: w

    SmalltalkCrawler.Repo.all(query)
  end

  def channel_subscribers(channel) do
    query = from w in __MODULE__,
    where: w.channel == ^channel, 
    select: w

    SmalltalkCrawler.Repo.all(query)
  end

  def subscribe(username, type, channel, service, thread) do
    model = %__MODULE__{}
    params = %{
      username: username, 
      type: type, 
      channel: channel, 
      service: service, 
      thread: thread 
    }
    changeset = model 
                |> cast(params, @required_fields, @optional_fields)

    if changeset.valid? do    
      SmalltalkCrawler.Repo.insert(changeset)
    else
      Logger.debug("Errors #{inspect changeset.errors}")
    end
  end

  def unsubscribe(username, channel, thread) do
    model = find_subscription(username, thread, channel)
    SmalltalkCrawler.Repo.delete(model)
  end
  
  #Channel crawler has found a new RSS feed item and sent a message about it to the client
  def channel_update_handled(subscriber) do
    changeset = subscriber
                #Update the latest_update_sent timestamp 
                |> cast(%{latest_update_sent: timestamp_tuple()}, ~w(latest_update_sent), ~w())
    if changeset.valid? do
      SmalltalkCrawler.Repo.update(changeset)
    else
      Logger.debug("Errors #{inspect changeset.errors}")
    end
  end

  defp timestamp_tuple() do
    {date, {h, m, s}} = :erlang.universaltime
    {date, {h, m, s, 0}}
  end
end
