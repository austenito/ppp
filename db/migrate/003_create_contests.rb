class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
    t.column :contest_name, :string
    t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :contests
  end
end
