class QuestCom::CLI

  def call
    greet
    input = gets.strip
    get_quest_name(input)
    scrape_for_id(input)
    # not yet gotten to collecting comments, displaying them or other options
  end

  def greet
    puts "Type in the exact quest name then hit ENTER to see its top comment from wowhead:"
  end

  def get_quest_name(user_input)
    quest_name = user_input
    puts "#{quest_name}" # for testing while building at the moment
  end

  def scrape_for_id(user_input)
    QuestCom::Scraper.new(user_input)
  end

end
