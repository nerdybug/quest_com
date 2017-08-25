class QuestCom::Comment
  attr_accessor :commentv2, :number, :id, :nreplies, :sticky, :user, :body, :date,
  :rating, :indent, :roles, :deleted, :outofdate, :userRating, :replies, :lastEdit
# of particular importance are: number, nreplies, user, body, date, rating
# number is the numeral for its position on the page starting at 0
# nreplies is how many replies the comment has
# user is the wowhead user's name who posted the comment
# body is the content of the comment itself - needs review for formatting errors
# date is the day when the comment was posted, gsub with regex will remove the timestamp
# rating is the actual rate for the comment as wowhead.com automatically sorts the display under highest rated

  def initialize(hash)
    hash.each {|key, value| send("#{key}=", value)}
    fix_date
  end

  def fix_date
    # take "2013-08-29T09:44:16-05:00" and give me "2013-08-29"
    self.date = self.date.gsub(/T(.*)/, "")
  end

  def more_information
    # neatly display additional details about a comment
    # <<-HEREDOC
    puts "Date posted: #{self.date}"
    puts "Comment author: #{self.user}"
    puts "Rating: #{self.rating}"
    # HEREDOC
  end
end
