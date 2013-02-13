# The class which represents a sport players can participate in.
#
# * Author: Austen Ito
class Sport < ActiveRecord::Base

  # Returns the sport with the specified name.
  # 
  # @param name the specified name of the sport to find.
  # @return the associated sport or nil if it does not exist.
  #
  def self.get_sport_with_name(name)
    @sports = find(:first, :conditions => ["sport_name = :sport_name", {:sport_name => name}])
  end
end
