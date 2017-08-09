class QuestCom::QuestData
  attr_reader :quest_id

  def initialize(quest_id, page_data)
    # takes in a scraped quest's information (result_body, quest_id)
    @quest_id = quest_id
    @data = page_data
    puts "Hello, I am the Quest! My ID is #{@quest_id}." # only here for testing at the moment
    # binding.pry
  end

  def find_all_comments
    # finds all of the comments...ALL OF THEM
    # example usage once those are stored as a reader variable @comments
      # quest_match = QuestCom::QuestData.new(quest_id)
      # quest_match.all_comments => puts out every comment on that quest
  end

  def find_top_comment
    # has the top comment and any information about that comment (comments on it, time, date, author)
  end

end
