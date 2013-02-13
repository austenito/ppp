# The class representing a player that is a participant in contests.  A player game belong
# to many teams and sports.  A player also has ratings and records for each sport.
#
# * Author: Austen Ito
class Player < ActiveRecord::Base
  belongs_to :teams
  has_many :ratings
  has_many :records
  attr_reader :player_id
  validates_presence_of :username
  
  # Returns an array of all players ordered by their name.
  # 
  # @return an array of all players.
  def self.get_all_players
    find(:all, :order => "username")
  end
  
  # Returns the first occurance of a player with the specified id.
  #
  # @param player_id the specified player id.
  # @return the player with the specified id or nil if the player does not exist.
  def self.get_player_with_id(player_id)
   find(:first, :conditions => ["id = :id", {:id => player_id}])
  end
  
  # Returns a player with the specified name.
  # 
  # @param player_name the specified player name used to find the player instance.
  # @return the player with the specified name or nil if it does not exist.
  def self.get_player(player_name)
    find(:first, :conditions => ["username = :username", {:username => player_name}])
  end
  
  protected
  
  # Validates if a player with the same user name already exists.  This object assumes that
  # player's names are unique.
  def validate
    errors.add(:username, "already exists.") if Player.get_player(username) != nil
  end
end
