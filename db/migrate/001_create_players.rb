class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
    t.column :username, :string
    t.column :password, :string
    t.column :email, :string
    end
  end

  def self.down
    drop_table :players
  end
end
