class QuestCom::Comment
  attr_accessor :current, :top_comment, :commentv2, :number, :id, :nreplies, :sticky, :user, :body, :date,
  :rating, :indent, :roles, :deleted, :outofdate, :userRating, :replies, :lastEdit
# of particular importance are: current, top_comment, number, nreplies, user, body, date, rating
# current is the Comment object currently being viewed
# top_comment will be true or false
# number is the numeral for its position on the page starting at 0
# nreplies is how many replies the comment has
# user is the wowhead user's name who posted the comment
# body is the content of the comment itself - needs review for formatting errors
# date is the day when the comment was posted, gsub with regex will remove the timestamp
# rating is the actual rate for the comment as wowhead.com automatically sorts the display under highest rated


  def initialize(hash)
    hash.each {|key, value| send("#{key}=", value)}
    fix_date
    top?
  end

  def fix_date
    # take "2013-08-29T09:44:16-05:00" and give me "2013-08-29"
    self.date = self.date.gsub(/T(.*)/, "")
  end

  def more_information
    "posted by #{self.user} on #{self.date} - rating: #{self.rating}"

  end

  # def comment_menu
  #   puts <<-HEREDOC
  #   1. see more information about this comment
  #   2. see a list of other comments
  #   3. search for another quest's top comment
  #   4. exit
  # 	HEREDOC
  # end

  def top?
    # if a comment is the top comment, it will also me the current comment
    if self.number == 0
      self.top_comment = true
      self.current = self
    else
      self.top_comment = false
    end
  end

  # def snippet
  #   self.body.split(/\s+/, n+1)[0...n].join(' ')
  # end

end
