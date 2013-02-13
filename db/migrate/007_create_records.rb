class CreateRecords < ActiveRecord::Migration
  def self.up
    create_table :records do |t|
      t.column :sport_id, :integer
      t.column :player_id, :integer
      t.column :wins, :integer
      t.column :losses, :integer
      
    end
      execute "alter table records add constraint fk_records_sport_id foreign key (sport_id) references sports(id)"
      execute "alter table records add constraint fk_records_players foreign key (player_id) references players(id)"
  end
  
  def self.down
    drop_table :records
  end
end
