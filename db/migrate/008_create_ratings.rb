class CreateRatings < ActiveRecord::Migration
  def self.up
    create_table :ratings do |t|
      t.column :player_id, :integer
      t.column :sport_id, :integer
      t.column :rating, :float
      t.column :created_at, :datetime
    end
    execute "alter table ratings add constraint fk_ratings_sport_id foreign key (sport_id) references sports(id)"
    execute "alter table ratings add constraint fk_ratings_players foreign key (player_id) references players(id)"
  end
  
  def self.down
    drop_table :ratings
  end
end
