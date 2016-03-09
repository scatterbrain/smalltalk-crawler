defmodule SmalltalkCrawler.Repo.Migrations.Subscriptions do
  use Ecto.Migration

  def up do
    create table(:subscriptions) do
      add :type, :string, null: false
      add :username, :string, null: false
      add :thread, :string, null: false
      add :channel, :string, null: false
      add :service, :string, null: false
      add :latest_update_sent, :datetime
      timestamps
    end

    create index(:subscriptions, [:channel])
    create index(:subscriptions, [:username])
    create index(:subscriptions, [:thread, :username, :channel], unique: true)    
  end
  
  def down do
    drop table(:subscriptions)
  end 
end
