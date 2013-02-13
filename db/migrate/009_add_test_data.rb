class AddTestData < ActiveRecord::Migration
  def self.up
    sport = Sport.create(:sport_name => "Ping Pong")    
    
    #Creates the players and initial values
    ai = Player.create(:username=> "Austen Ito")
    AddTestData.create_new_data(sport, ai)
    jn = Player.create(:username=> "Jim Newsham")
    AddTestData.create_new_data(sport, jn)
    ml = Player.create(:username=> "Mark Lee")
    AddTestData.create_new_data(sport, ml)
    ak = Player.create(:username=> "Aaron Kagawa")
    AddTestData.create_new_data(sport, ak)
    ck = Player.create(:username=> "Chad Kumabe")
    AddTestData.create_new_data(sport, ck)
    jw= Player.create(:username=> "James Wang")
    AddTestData.create_new_data(sport, jw)
    rp = Player.create(:username=> "Robert Pierce")
    AddTestData.create_new_data(sport, rp)
    ms = Player.create(:username=> "Matt Shawver")
    AddTestData.create_new_data(sport, ms)
    ky= Player.create(:username=> "Kenn Yuen")
    AddTestData.create_new_data(sport, ky)
  end
  
  def self.create_new_data(sport, player)
    Team.create(:team_name => "self", :player_id => player.id)
    Record.create(:sport_id => sport.id, :player_id => player.id, :wins => 0, :losses => 0)
    Rating.create(:player_id => player.id, :sport_id => sport.id, :rating => 1000)
  end
  
  
  def self.down
    Rating.delete_all
    Record.delete_all
    GameScore.delete_all
    Game.delete_all
    Contest.delete_all
    Team.delete_all
    Player.delete_all
    Sport.delete_all
  end
end
