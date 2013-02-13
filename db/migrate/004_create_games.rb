class CreateGames < ActiveRecord::Migration
  def self.up
    create_table :games do |t|
    t.column :contest_id, :integer
    end
        execute "alter table games add constraint fk_games_contest_id foreign key (contest_id) references contests(id)"
  end

  def self.down
    drop_table :games
  end
end
