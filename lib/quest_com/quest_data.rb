class QuestCom::QuestData
  attr_reader :quest_id

  def initialize(quest_id, comment_hash_array)
    @quest_id = quest_id
    @comment_data = comment_hash_array # array of comment objects made with OpenStruct
    puts "Hello, I am the Quest! My ID is #{@quest_id}. I have #{@comment_data.length} comments." # only here for testing at the moment
    # binding.pry
  end

  def all_comments
    # temporary

  end

  def top_comment
    # has the top comment and any information about that comment (comments on it, time, date, author)
    puts "#{@comment_data[0]["body"]}" # should puts out the body of the first/top comment
    # formatting handles line breaks but puts out [npc=number] for links to wowhead npc pages
    # and also [url] for links and [b] for map coords
  end

end
