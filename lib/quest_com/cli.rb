class QuestCom::CLI

  def call
    greet
    input = gets.strip
    # get_quest_name(input)
    quest = scrape_for_quest_data(input)
    show_top_comment(quest)
    # not yet gotten to displaying other options
  end

  def greet
    puts "Type in the exact quest name then hit ENTER to see its top comment from wowhead:"
  end

  # def get_quest_name(user_input)
  #   quest_name = user_input
  #   puts "You have searched for #{quest_name}" # only here for testing at the moment
  # end

  def scrape_for_quest_data(user_input) # in progress
    scraper = QuestCom::Scraper.new(user_input)
    scraper.scrape_to_create_quest_object
  end

  def show_top_comment(quest)
    top = quest.top_comment
    puts "#{top.body}"
  end
end
