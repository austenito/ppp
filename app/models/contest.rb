# The class that is the top-level relationship to all games and scores.  Each contest has
# a timestamp, which indiciates the creation time.  This timestamp allows operations to
# be performed on each contest based on the order of their creation.  Operations include, but
# are not limited to occurance based operations such as rating calculations.
#
# * Author: Austen Ito
class Contest < ActiveRecord::Base
  has_many :games
  ActiveRecord::Base.default_timezone = :hst
  
  # Returns an array of all winners of all contests.
  #
  # @return an array of all winners.
  #
  def self.get_all_winners
    winners = Array.new
    for contest in Contest.get_all_contests
      winner = Player.get_player_with_id(Team.get_team_with_id(contest.get_winner).player_id)
      winners.insert(-1, winner)
    end
    return winners;
  end
  
  # Returns an array of all losers of all contests.
  #
  # @return an array of all losers.
  #
  def self.get_all_losers
    losers = Array.new
    for contest in Contest.get_all_contests
      loser = Player.get_player_with_id(Team.get_team_with_id(contest.get_loser).player_id)
      losers.insert(-1, loser)
    end
    return losers;
  end
  
  # Returns the team id of the winner of this contest.  
  #
  # @return the winning team of this contest.
  def get_winner
    id_to_wins = calculate_outcomes
    #Finally, return the team with the most wins.
    winning_team_id = nil;
    id_to_wins.each { |id, wins| 
      if(winning_team_id == nil) || id_to_wins[winning_team_id] < wins
        winning_team_id = id
      end   
    }
    
    return winning_team_id;
  end
  
  # Returns the team id of the loser of this contest.
  #
  # @return the losing team of this contest.
  def get_loser
    id_to_wins = calculate_outcomes
    #Finally, return the team with the most wins.
    losing_team_id = nil;
    id_to_wins.each { |id, wins| 
      if(losing_team_id == nil) || id_to_wins[losing_team_id] > wins
        losing_team_id = id
      end   
    }
    
    return losing_team_id;
  end
  
  # Returns a list of game scores associated with the specified team.
  #
  # @param team the team whose associated scores are retrieved.
  # @return an array of game scores.
  def get_team_scores(team)
    team_scores = Array.new
    for game in games
      scores = GameScore.get_team_game_scores(team, game)
      for score in scores
        team_scores.insert(-1, score)
      end
    end
    return team_scores
  end
  
  # Returns the first contest with specified contest id.  If the contest id does not exist,
  # nil is returned.
  #
  # @param contest_id the id of the contest to find.
  # @return the contest if it exists.
  def self.get_contest_with_id(contest_id)
    find(:first, :conditions => ["id = :id", {:id => contest_id}])
  end
  
  # Returns a list of all contests, which are ordered by their creation time.
  #
  # @return the ordered array of all contests.
  def self.get_all_contests
    find(:all, :order => :created_at)
  end
  
  # Returns a formatted version of the wrapped contest's timestamp.  This timestamp appears
  # in the format: 'Tuesday 10, 2007 - 14:05:25'
  # 
  # @return the formatted timestamp.
  def get_timestamp
    created_at.strftime "%A %d, %Y - %H:%M:%S"
  end
  
  private
  
  # Returns a list of all of this contest's winner's scores.  The returned scores is not the
  # list of the winning scores, but a list of the winning player's scores.  For example, 
  # a player can win this contest by winning 2 out of 3 games.  This method will return
  # all 3 of the player's scores.
  #
  # @return the array of this contest's winner's scores.
  def calculate_winner_scores
    winner_team_id = get_winner
    
    winner_scores = Array.new
    for game in games
      scores = GameScore.get_scores_with_id(game.id)
      for score in scores
        if score.team_id.to_s == winner_team_id
          winner_scores.insert(-1, score)
        end
      end
    end 
    
    return winner_scores
  end
  
  # The helper method that returns a hash of team id's -> number of wins in this contest.
  # 
  # @return an array of team id's -> wins.
  def calculate_outcomes
    id_to_wins = Hash.new
    
    #First, get all the games in this contest.
    for game in games
      #Then, associate all game scores with a team.
      id_to_score = Hash.new
      scores = GameScore.get_scores_with_id(game.id)
      for score in scores
        id_to_score[score.team_id] = score.score
      end
      
      #Next, find the id with the highest score in this game.
      winning_team_id = nil;
      id_to_score.each {|id, score|
        if(winning_team_id == nil) || id_to_score[winning_team_id] < score
          winning_team_id = id
        end
      }
      
      #Increment the amount of wins the team has.
      id_to_score.each_key { | id|
        if id_to_wins[id] == nil
          id_to_wins [id] = 0; #initialize the hash
        end
      }
      id_to_wins[winning_team_id] = id_to_wins[winning_team_id] + 1    
    end
    
    return id_to_wins
  end
end