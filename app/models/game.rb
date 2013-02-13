# The class which represents a game which can have many associated game scores.  
# 
# * Author: Austen Ito
class Game < ActiveRecord::Base
  belongs_to :contests
  has_many :game_scores
  
  # Returns the first occurance of the game with the specified game id.
  # 
  # @param game_id the specified game id.
  # @return the game with the specified id or null if no such game exists.
  def self.get_game_with_id(game_id)
    games = find(:first, :conditions => ["id = :id", {:id => game_id}])
  end
  
  # Saves a group of games (which is specified by the game_count parameter) associated
  # with the specified contest.  The winner and loser are associated with the specified
  # contest.  The match_map parameter contains a mapping of winner and loser scores used to
  # save each game.
  
  # @param game_count the number of games to save.
  # @param contest the contest each saved game is associated with.
  # @param winner the winner of the specified contest.
  # @param loser the loser of the specified contest.
  # @param match_map the mapping of scores.
  def self.save_games(game_count, contest, winner, loser, match_map)
    games = Array.new
    game_scores = Array.new
    if Game.is_scores_valid(game_count, match_map)
      # Iterates through each game score pair and creates a game record.
      begin
        for i in 1..game_count
          game = Game.new(:contest_id => contest.id)
          games.insert(-1, game)
          game.save!
          
          winnerTeam = Team.get_self_team(winner);
          loserTeam = Team.get_self_team(loser);
          winnerScore = match_map["winner_score" + i.to_s]
          loserScore = match_map["loser_score" + i.to_s]
          
          winnerGameScore = GameScore.new(:team_id => winnerTeam.id, :game_id => game.id, :score => winnerScore.to_i)
          loserGameScore = GameScore.new(:team_id => loserTeam.id, :game_id => game.id, :score => loserScore.to_i)
          game_scores.insert(-1, winnerGameScore);
          game_scores.insert(-1, loserGameScore);
          winnerGameScore.save!
          loserGameScore.save!
        end
      rescue ActiveRecord::RecordInvalid
        #Rollback if there is a problem saving scores.
        DbHelper.rollback(game_scores);
        DbHelper.rollback(games);
        raise "Scores must be numbers."
      end
    else
      raise "The winner must have more winning scores than the loser."
    end
  end
  
  # Returns true if all of the scores in the associated games in the specified match map are valid.
  # 
  # @param game_count the amount of games played.
  # @param match_map the mapping of winner and loser scores.
  def self.is_scores_valid(game_count, match_map)
    winnerScores = Array.new
    loserScores = Array.new
    #First, seperate the scores.  Return false if there isn't the right amount of scores.
    for i in 1..game_count
      winnerScore = match_map["winner_score" + i.to_s]
      loserScore = match_map["loser_score" + i.to_s]
      winnerScores.insert(-1, winnerScore)
      loserScores.insert(-1, loserScore)    
    end
    
    #Second, calculate the amount of wins vs. losses.
    winCount = 0;
    lossCount = 0;
    for i in 0..winnerScores.length - 1
      if winnerScores[i].to_i > loserScores[i].to_i
        winCount += 1
      else
        lossCount += 1
      end
    end
    
    #Returns false if the loser won the match
    if game_count == 1 && winCount == lossCount
      return true;
    elsif winCount > lossCount
      return true
    end
    return false
  end
end
