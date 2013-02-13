class CreateSports < ActiveRecord::Migration
  def self.up
    create_table :sports do |t|
    t.column :sport_name, :string
    end
  end

  def self.down
    drop_table :sports
  end
end
