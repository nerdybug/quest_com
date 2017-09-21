class QuestCom::Comment
  attr_accessor :current, :user, :body, :date, :rating

  def initialize(hash)
    hash.each {|key, value| send("#{key}=", value)}
    fix_date
    # clean_body
  end

  def fix_date
    self.date = QuestCom::Handler.shorten(self.date)
  end

  def clean_body
    self.body = QuestCom::Handler.clean(self.body)
  end

  def snippet
    # clean_body
    snip = QuestCom::Handler.snip(self.body)
  end
end
