class CreateGameScores < ActiveRecord::Migration
  def self.up
    create_table :game_scores do |t|
    t.column :team_id, :integer
    t.column :game_id, :integer
    t.column :score, :integer
    end
    execute "alter table game_scores add constraint fk_game_scores_teams foreign key (team_id) references teams(id)"
    execute "alter table game_scores add constraint fk_game_scores_gane_id foreign key (game_id) references games(id)"
  end

  def self.down
    drop_table :game_scores
  end
end
