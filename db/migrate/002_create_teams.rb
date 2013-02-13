class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.column :team_name, :string
      t.column :player_id, :integer
    end
    
    execute "alter table teams add constraint fk_teams_players foreign key (player_id) references players(id)"
  end
  
  def self.down
    drop_table :teams
  end
end
