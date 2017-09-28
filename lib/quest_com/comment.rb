class QuestCom::Comment
  attr_accessor :user, :body, :date, :rating, :current

  def initialize(hash)
    hash.each {|key, value| send("#{key}=", value)}
    fix_date
  end

  def fix_date
    self.date = QuestCom::Handler.shorten(self.date)
    # => QuestCom::Comment.date = "2013-08-29"
  end

  def clean_body
    self.body = QuestCom::Handler.clean(self.body)
  end

  def snippet
    QuestCom::Handler.snip(self.body)
  end

  def show_info
    CLI.comment_info(self)
  end
end
