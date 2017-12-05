class QuestCom::Comment
  attr_accessor :user, :body, :date, :rating, :current
  include QuestCom

  def initialize(hash)
    hash.each {|key, value| send("#{key}=", value)}
    fix_date
  end

  def fix_date
    self.date = shorten(self.date) # module method
    # => QuestCom::Comment.date = "2013-08-29"
  end

  def clean_body
    self.body = clean(self.body) # module method
  end

  def snippet
    get_snip(self.body) # module method
  end

  def show_info
    CLI.comment_info(self)
  end
end
