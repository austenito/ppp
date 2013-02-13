# The class which represents one score that belongs to a game.
#
# * Author: Austen Ito
class GameScore < ActiveRecord::Base
  has_many :teams
  belongs_to :games
  attr_reader :contest_score_id
  validates_numericality_of :score
  
  # Updates the specified team's score in the specified game.
  #
  # @param team the specified team.
  # @param game the specified game the team participated in.
  # @param new_score the updated scored.
  def self.update_team_score(team, game, new_score)
    score = find(:first, :conditions => ["team_id = :team_id and game_id = :game_id", {:team_id => team.id, :game_id => game.id}])  
    score.score = new_score
    score.save!
  end
  
  # Returns the first occurance of a score with the specified id.
  #
  # @param score_id the specified score id used to find the score instance.
  # @return the score with the specified id or nil if no score exists.
  def self.get_score(score_id)
    find(:first, :conditions => ["id = :id", {:id => score_id}])
  end
  
  # Returns an array of scores with the specified game id.
  #
  # @return the array of scores.
  def self.get_scores_with_id(game_id)
    find(:all, :conditions => ["game_id = :game_id", {:game_id => game_id}])
  end
  
  # Returns an array of scores with the specified team and game.
  #
  # @param team the specified team.
  # @param game the specified game.
  def self.get_team_game_scores(team, game)
    find(:all, :conditions => ["team_id = :team_id and game_id = :game_id", {:team_id => team.id, :game_id => game.id}])
  end
  
  # Returns the score instance associated with the specified team.
  #
  # @param team the specified team.
  # @return the score instance.
  def self.get_score_with_team(team)
    find(:all, :conditions => ["team_id = :team_id", {:team_id => team.id}])
  end
end
