# The class represeting a team that players can be a part of.
#
# * Author: Austen Ito
class Team < ActiveRecord::Base
  has_many :players
  belongs_to :contest_scores
  attr_reader :team_id
  
  # Returns the first occurance of a team with the specified team id.
  #
  # @param team_id the specified team id used to find a team.
  # @return the team instance or nil if it does not exist.
  def self.get_team_with_id(team_id)
    teams = find(:first, :conditions => ["id = :id", {:id => team_id}])
  end
  
  # Returns the self team associated with the specified player. A self team is defined as
  # a team with only one person on it.  Each player has an associated self team that is used
  # when storing records in the model.
  #
  # @param player the specified player used to find the team.
  # @return the self team if it exists.
  def self.get_self_team(player)
    find(:first, :conditions => ["player_id = :player_id and team_name = :team_name", {:player_id => player.id, :team_name => "self"}])
  end
end
