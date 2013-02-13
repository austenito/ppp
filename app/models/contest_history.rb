# The class which wraps the information used to display a player's match information wuch as 
# the player, contest, and associated scores.
# 
# * Author: Austen Ito
class ContestHistory
  attr_reader :contest
  
  # Initializes this object with the specified player, contest, and list of scores.
  # 
  # @param player the specified player.
  # @param contest the specified contest.
  # @param scores the scores associated with the specified player and contest
  def initialize(player, contest, scores)
    @player = player
    @contest = contest
    @scores = scores
  end
  
  # Returns the opponents of the contest's specified player.
  #
  # @return an array of opoonents.
  def get_opponents
    #First, get the unique opponent ids.
    opponent_ids = Array.new  
    team =  Team.get_self_team(@player)    
    for score in @scores
      if (score.team_id != team.id) && (opponent_ids.index(score.team_id) == nil)
        opponent_ids.insert(-1, score.team_id)
      end
    end
    
    #Next, get the players associated with the ids.
    opponents = Array.new
    for opponent_id in opponent_ids
      team = Team.get_team_with_id(opponent_id)
      opponents.insert(-1, Player.get_player_with_id(team.player_id));
    end
    
    return opponents
  end
  
  # Returns a list of games with the specified scores.
  #
  # @return an array of games.
  def get_games
    games = Array.new
    for score in @scores
      game = Game.get_game_with_id(score.game_id)
      if games.index(game) == nil
        games.insert(-1, game)
      end
    end
    return games
  end
  
  # Returns a list of scores associated with the specified game.
  #
  # @return the array of associated scores.
  def get_scores(game)
    scores = Array.new
    for score in @scores
      if game.id == score.game_id
        
        #Orders the scores with this player's history first.
        team =  Team.get_self_team(@player)    
        if score.team_id == team.id
          scores.insert(scores.length - 1, score)
        else
          scores.insert(-1, score)
        end
      end
    end
    return scores
  end
  
  # Returns a formatted version of the wrapped contest's timestamp.  This timestamp appears
  # in the format: 'Tuesday 10, 2007 - 14:05:25'
  # 
  # @return the formatted timestamp.
  def get_timestamp
    timestamp = @contest.created_at
    timestamp.strftime "%A %d, %Y - %H:%M:%S"
  end
end