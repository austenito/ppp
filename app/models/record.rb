# The class which represents the record of a player of a specific sport.  Records, unlike Ratings
# do not have history tracking.  This means that records are updated rather than new rows
# created each time a person's record is changed.
#
# * Author: Austen Ito
class Record < ActiveRecord::Base
  belongs_to :players
  
  # Increments the records of all winning players in the specified list of players.
  #
  # @param winners the list of winning players.
  #
  def self.increment_all_winners(winners)
    # First, find the amount of times each winner appears, 
    # which is the amount of contests the player has won.
    winner_ids_to_count = Hash.new
    for winner in winners
      if winner_ids_to_count[winner.id] == nil
        winner_ids_to_count[winner.id] = 1
      else
        winner_ids_to_count[winner.id] = winner_ids_to_count[winner.id] + 1
      end
    end
    
    # Next, set the amount of times a player has won.
    winner_records = Record.get_records_with_ids(winner_ids_to_count.keys)
    for winner_record in winner_records
      winner_record.wins = winner_ids_to_count[winner_record.player_id] 
      winner_record.save!
    end
  end
  
  # Increments the records of all losing players in the specified list of players.
  #
  # @param losers the list of losing players.
  #
  def self.increment_all_losers(losers)
    # First, find the amount of times each loser appears, 
    # which is the amount of contests the player has loss.
    loser_ids_to_count = Hash.new
    for loser in losers
      if loser_ids_to_count[loser.id] == nil
        loser_ids_to_count[loser.id] = 1
      else
        loser_ids_to_count[loser.id] = loser_ids_to_count[loser.id] + 1
      end
    end
    
    # Next, set the amount of times a player has loss.
    loser_records = Record.get_records_with_ids(loser_ids_to_count.keys)
    for loser_record in loser_records
      loser_record.losses = loser_ids_to_count[loser_record.player_id] 
      loser_record.save!
    end
  end
  
  # Increments the win record by 1 of the specified player of the specified sport.
  #
  # @param player The player whose record with be incremented.
  # @param sport the sport the specified player participated in.
  #
  def self.increment_win_record(player, sport)
    record = Record.get_record(player, sport)
    record.wins += 1
    record.save!
  end
  
  # Increments the loss record by 1 of the specified player of the specified sport.
  #
  # @param player The player whose record with be incremented.
  # @param sport the sport the specified player participated in.
  #
  def self.increment_loss_record(player, sport)
    record = Record.get_record(player, sport)
    record.losses += 1
    record.save!
  end
  
  # Clears all win and loss records by setting them to 0.
  def self.clear_all_records
    Record.update_all("wins = 0, losses = 0")
  end
  
  # Returns the record associated with the specified player and sport.
  # 
  # @param player the specified player.
  # @param sport the specified sport.
  # @return the associated record or nil if it does not exist.
  def self.get_record(player, sport)
    find(:first, :conditions => ["player_id = :player_id and sport_id = :sport_id", {:player_id => player.id, :sport_id => sport.id}])
  end
  
  # Returns the list of records with the specified record ids.
  # 
  # @param ids an array of record ids.
  # @param an array of records or nil if no records exist.
  def self.get_records_with_ids(ids)
    find(:all, :conditions => ["id in (:ids)", {:ids => ids}])
  end
end
