# The class representing the rating of players.  The rating system used by this class is copied
# from: http://en.wikipedia.org/wiki/ELO_rating_system.
#
# * Author: Austen Ito
#
class Rating < ActiveRecord::Base
  belongs_to :player
  ActiveRecord::Base.default_timezone = :hst
  
  # Resets all ratings of the ping pong sport to the default value of 1000.0.  
  # This is done when an contest is edited  and all ratings effected by the 
  # change must be updated.
  #
  def self.reset_all_ratings
    Rating.delete_all
    sport = Sport.get_sport_with_name("Ping Pong")
    for player in Player.get_all_players
      Rating.new(:player_id => player.id, :sport_id => sport.id, :rating => 1000).save!
    end
  end
  
  # Calculates the ratings of the specified winner and loser of the specified sport.  The
  # newly calculated rating is then added to the model.  The winner and loser's existing
  # rating is not updated to provide a rating history for each player.
  #
  # @winner the winning player who rating is calculated.
  # @loser the losing player whose rating is calculated.
  # @sport the specified sport played.
  #
  def self.calculateRating(winner, loser, sport)
    #First, get the latest player and opponent ranking
    winner_rating = Rating.get_latest_rating(winner)
    loser_rating = Rating.get_latest_rating(loser)
    
    # Rating + 32(actual  - expected),  actual is win = 1 or loss = 0
    winner_exponent = (loser_rating.rating - winner_rating.rating) / 400.0
    winner_expected_value = 1.0 / (1.0 + 10.0 ** winner_exponent)
    new_winner_rating = winner_rating.rating + (32.0 * (1.0 - winner_expected_value))
    
    loser_exponent = (winner_rating.rating - loser_rating.rating) / 400.0
    loser_expected_value = 1.0 / (1.0 + 10.0 ** loser_exponent)
    new_loser_rating = loser_rating.rating + (32.0 * (0.0 - loser_expected_value))
    
    Rating.new(:player_id => winner.id, :sport_id => sport.id, :rating =>new_winner_rating).save!
    Rating.new(:player_id => loser.id, :sport_id => sport.id, :rating =>new_loser_rating).save!
  end
  
  # Returns the latest rating, based on timestamp, of the specified player.
  #
  # @param player the specified player whose rating is searched for.
  # @return the rating associated with the specified player or nil if no rating exists.
  #
  def self.get_latest_rating(player)
    ratings = Rating.get_all_ratings(player)
    return ratings[ratings.length - 1]
  end
  
  # Returns an array of all ratings associated with the specified player.  The array of
  # ratings is sorted in ascending order by when the rating was created.  The 
  # order of creation is used because batch updates of ratings may cause the timestamps
  # to be the same.
  #
  # @param player the specified player.
  # @return the ordered list of ratings or nil if no ratings exist.
  #
  def self.get_all_ratings(player)
    find(:all, :conditions => ["player_id = :player_id", {:player_id => player.id}], :order => :id)
  end
end
