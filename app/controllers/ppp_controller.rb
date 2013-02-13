# The ping pong match controller used to add players/matches, 
# view player's game records, and edit the current scores.
#
# * Author: Austen Ito
class PppController < ApplicationController
  
  # The action triggered when the ppp application is requested.
  def index
  end
  
  # The action called when adding a player to the model.
  def add_player
  end
  
  # The action called when adding a 1-game match.  A 1-game match 
  # has 1 winner and 1 loser each with an associated score.  When creating a 
  # match, all players are listed.
  def add_1game_match
    @players = Player.find(:all, :order => "username").map {|u| [u.username]}    
  end
  
  # The action called when adding a 3-game match.  A 3-game match 
  # has 1 winner and 1 loser each with 3 associated scores.  When creating a 
  # match, all players are listed.
  def add_3game_match
    @players = Player.find(:all, :order => "username").map {|u| [u.username]}    
  end
  
  # The action triggered to view all existing players.
  def view_players
    @players = Player.get_all_players
  end 
  
  # Is called when creating a new player.  Players are initialized with a record 
  # of 0 wins and 0 losses.  Each player's rating is also initialized to the 
  # starting value of 1000.
  def create_player
    #Creates the team and player relationships.
    begin
      @player = Player.new(params[:player])
      @player.save!
    rescue ActiveRecord::RecordInvalid
      playerMap = params[:player]
      flash[:notice] = "The player name " + playerMap[:username] + " already exists"
      redirect_to :action => :add_player
    else
      team = Team.new(:team_name => "self", :player_id => @player.id)
      team.save!
      
      #Creates the sports and record relationships.
      sport = Sport.get_sport_with_name("Ping Pong")    
      if sport == nil
        sport = Sport.new(:sport_name => "Ping Pong")
        sport.save!
      end
      @record = Record.new(:sport_id => sport.id, :player_id => @player.id, :wins => 0, :losses => 0)
      @record.save!
      
      #Creates the inital rating
      rating = Rating.new(:player_id => @player.id, :sport_id => sport.id, :rating => 1000)
      rating.save!
      
      redirect_to :action => :view_players 
    end
  end
  
  # The action called when the view requests to create a 1-game match using the form 
  # information specified by the user.
  def create_1game_match
    create_match(1, :add_1game_match)
  end
  
  # The action called when the view requests to create a 3-game match using the form 
  # information specified by the user.
  def create_3game_match
    create_match(3, :add_3game_match)
  end
  
  # Is triggered when the user requests to view the information of a specific user. 
  def show_player_info
    #First, get the player and their teams.
    @player = Player.get_player(params[:username])
    self_team = Team.get_self_team(@player)
    
    # Second, map the games to all of the scores.
    game_to_scores = Hash.new
    scores = GameScore.get_score_with_team(self_team)
    for score in scores
      game = Game.get_game_with_id(score.game_id)
      game_scores = GameScore.get_scores_with_id(game.id)
      game_to_scores[game] = game_scores
    end
    
    #Third, map the scores to a contest
    contest_to_scores = Hash.new
    game_to_scores.each { |game, scores| 
      contest = Contest.get_contest_with_id(game.contest_id)
      if contest_to_scores[contest] == nil
        contest_to_scores[contest] = scores
      else
        mappedScores = contest_to_scores[contest]
        for score in scores
          if mappedScores.index(score) == nil
            mappedScores.insert(-1, score)
          end
        end
        contest_to_scores[contest] = mappedScores
      end
    }
    
    #Finally, sorted the contest information by time.
    sorted_contest_to_scores = contest_to_scores.sort {|a,b| a[0].created_at <=> b[0].created_at }
    @contestHistories = Array.new
    for i in 0..sorted_contest_to_scores.length - 1
      inner_array = sorted_contest_to_scores[i]
      for j in 0..inner_array.length - 1
        @contestHistories.insert(-1, ContestHistory.new(@player, inner_array[0], inner_array[1]))
        break;
      end
    end
  end
  
  # This action is called when the user requests to edit a specific match.
  def edit_match
    contest = Contest.get_contest_with_id(params[:contest])
    @games = contest.games
    
    if @games.length == 1
      redirect_to :action => :edit_1game_match, :contest => contest
    end 
    if @games.length == 3
      redirect_to :action => :edit_3game_match, :contest => contest
    end 
  end
  
  # Retrieves the 1-game match information the user will edit.
  def edit_1game_match 
    setup_edit_information 
    @winner_score1 = @winner_scores[0]
    @loser_score1 = @loser_scores[0]
  end
  
  # Saves the 1-game match using the information specified by the user.
  def save_1game_edit
    save_edit(1)
  end
  
  # Retrieves the 3-game match information the user will edit.
  def edit_3game_match
    setup_edit_information
    @winner_score1 = @winner_scores[0]
    @loser_score1 = @loser_scores[0]
    @winner_score2 = @winner_scores[1]
    @loser_score2 = @loser_scores[1]
    @winner_score3 = @winner_scores[2]
    @loser_score3 = @loser_scores[2]
  end
  
  # Saves the 3-game match using the information specified by the user.
  def save_3game_edit
    save_edit(3)
  end
  
  # Removes the specified contest, games, and scores from the model.  All records and ratings are then 
  # recalculated.
  #
  def remove_match
    contest = Contest.get_contest_with_id(params[:contest])  
    winning_scores = contest.get_team_scores(Team.get_team_with_id(contest.get_winner))
    losing_scores = contest.get_team_scores(Team.get_team_with_id(contest.get_loser))
    
    #First, remove all of the game scores.
    score_ids = Array.new
    for i in 0..winning_scores.length - 1 
      score_ids.insert(-1, winning_scores[i].id);
      score_ids.insert(-1, losing_scores[i].id);
    end
    GameScore.delete(score_ids)
    
    #Next, remove all games.
    game_ids = Array.new
    for game in contest.games
      game_ids.insert(-1, game.id)
    end
    Game.delete(game_ids)
    contest.destroy
    
    recalculate_data
    redirect_to :action => :show_player_info, :username => params[:player_name]
  end
  
  private
  # Creates a match with the specified amount of games.  After the match is
  # created, the controller redirects the user to the specified page.
  #
  # @param game_count the number of games in the match
  #
  # @param redirection_page the page this controller redirects the user to 
  # after the match is created.
  def create_match(game_count, redirection_page)
    #First, let's get the sport and winner/loser
    matchMap = params[:match]    
    ping_pong = Sport.get_sport_with_name("Ping Pong") 
    winner = Player.get_player(matchMap[:winner])
    loser = Player.get_player(matchMap[:loser])
    
    if is_valid_participants(winner, loser)
      #Then, let's create the Ping Pong contest.
      contest = Contest.new(:contest_name => winner.username + " vs. " + loser.username)
      contest.save!
      
      #Finally, create the games and associated scores.
      begin
        Game.save_games(game_count, contest, winner, loser, matchMap)
        Record.increment_win_record(winner, ping_pong)
        Record.increment_loss_record(loser, ping_pong)
        Rating.calculateRating(winner, loser, ping_pong)
        
      rescue Exception => e
        flash[:notice] = e.message
        redirect_to :action => redirection_page
      else
        flash[:notice] = "The match, " + winner.username + " vs. " + loser.username + ", was saved.";      
        if game_count == 1
          redirect_to :action => :add_1game_match
        else
          redirect_to :action => :add_3game_match
        end
      end
    else
      flash[:notice] ="The winner and loser cannot be the same person."
      redirect_to :action => redirection_page
    end
  end
  
  # Returns true if the specified winner and loser are valid participants.
  # 
  # @param winner the specified winner.
  # @param loser the specified loser.
  # @return true if both participants are valid, false if not.
  def is_valid_participants(winner, loser)
    if(winner == loser)
      return false
    end
    return true;
  end
  
  # Is called when setting up the information used to edit a match.  This method
  # assumes that the user has posted a contest to this controller, which can be used
  # to setup the information to edit.
  def setup_edit_information
    # First, get the contest selected by the user.
    contest_id = params[:contest]
    @contest = Contest.get_contest_with_id(contest_id)
    
    # Then, get the winner and loser.
    winning_team = Team.get_team_with_id(@contest.get_winner)
    losing_team = Team.get_team_with_id(@contest.get_loser)
    @winner = Player.get_player_with_id(winning_team.player_id)
    @loser = Player.get_player_with_id(losing_team.player_id)
    
    # Next, get the scores associated with the winner and loser.
    @winner_scores = @contest.get_team_scores(winning_team)
    @loser_scores = @contest.get_team_scores(losing_team)
    
    #Finally, add the winner and loser names to an array used for selection.
    @players = Array.new
    @players.insert(-1, @winner.username)
    @players.insert(-1, @loser.username)
  end
  
  # Is called when the user has requested an edit of a 1-game or 3-game match.
  # This method gathers the information edited by the user, and updates all records and ratings
  # associated with the edited information.  It should be noted that this method can take
  # a noticeably long time to complete because each rating is re-calculated.  Each rating must be 
  # re-calculated because each player's rating is dependent on previous ratings.  In future
  # implementations, the edit performance can be increased by only updating the relevant ratings
  # after the edited match.
  def save_edit(total_games)
    #First, get the posted information.
    contest_id = params[:contest]
    winner_name = params[:winner]["username"]
    loser_name = params[:loser]["username"]
    
    if is_valid_participants(winner_name, loser_name)
      # Setup the mapping used to check if the scores are valid.
      matchMap = Hash.new
      for i in 1..total_games
        matchMap["winner_score" + i.to_s] = params["winner_score" + i.to_s]["score"]
        matchMap["loser_score" + i.to_s] = params["loser_score" + i.to_s]["score"]
      end
      
      if Game.is_scores_valid(total_games, matchMap)
        #Second, get the teams associated with the winner/loser
        winning_team = Team.get_self_team(Player.get_player(winner_name))
        losing_team = Team.get_self_team(Player.get_player(loser_name))
        
        #Third, update the scores.
        contest = Contest.get_contest_with_id(contest_id)
        games = contest.games
        for i in 1..total_games
          winner_score = params["winner_score" + i.to_s]["score"]
          loser_score = params["loser_score" + i.to_s]["score"]    
          
          # If an empty score is entered, set it to 0.      
          if winner_score == ""
            winner_score = 0
          end
          if loser_score == ""
            loser_score = 0
          end
          GameScore.update_team_score(winning_team, games[i - 1], winner_score)
          GameScore.update_team_score(losing_team, games[i - 1], loser_score)
        end

        recalculate_data
        redirect_to :action => :view_players 
      else
        flash[:notice] ="The winner must more winning scores than losing scores."
        if total_games == 1
          redirect_to :action => :edit_1game_match, :contest => params[:contest]
        else 
          redirect_to :action => :edit_3game_match, :contest => params[:contest]
        end
      end
    else
      flash[:notice] ="The winner and loser cannot be the same person."
      if total_games == 1
        redirect_to :action => :edit_1game_match, :contest => params[:contest]
      else 
        redirect_to :action => :edit_3game_match, :contest => params[:contest]
      end
    end
  end
  
  # Recalculates the records and ratings of all players.
  #
  def recalculate_data
    # Fourth, reset all records and ratings
    Record.clear_all_records
    Rating.reset_all_ratings
    
    # Fifth, recalculate all records starting from the first match.
    ping_pong = Sport.get_sport_with_name("Ping Pong")
    winners = Contest.get_all_winners
    losers = Contest.get_all_losers
    Record.increment_all_winners(winners)
    Record.increment_all_losers(losers)
    
    # Finally, recalculate all ratings.
    for i in 0...winners.length
      Rating.calculateRating(winners[i], losers[i], ping_pong)
    end
  end
end
