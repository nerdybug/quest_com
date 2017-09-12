class QuestCom::Comment
  attr_accessor :current, :user, :body, :date, :rating

  def initialize(hash)
    hash.each {|key, value| send("#{key}=", value)}
    fix_date
    # top?
    clean_body
  end

  def fix_date
    # take "2013-08-29T09:44:16-05:00" and give me "2013-08-29"
    self.date.gsub!(/T(.*)/, "")
  end

  def more_information
    "posted by #{self.user} on #{self.date} - rating: #{self.rating}"

  end

  def clean_body
    self.body.gsub!(/\[npc=\d+\]/, "FIND_MY_NAME") # in progress
    self.body.gsub!(/\[url=\w+\W+\w+.\w+.\w+\/\w+=\d+#map\]\[b\]/, "(map coordinates: ")
    self.body.gsub!(/\[\/b\]\[\/url\]/, ")")
    self.body.gsub!(/\[url=.+\[\/url\]/, "") # change this as it FULLY removes links
    self.body.gsub!(/\[\w+=\d+\]/, "")
    # need handle for [table...]...[/table] replace using: (see comment on wowhead.com for table)
  end

end
