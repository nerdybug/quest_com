class QuestCom::CLI

  def call
    greet
    input = Readline.readline
    # binding.pry
    quest = scrape_for_quest_data(input)
    quest.show_top_comment
    quest.initial_menu
  end

  def greet
    puts "Type in the exact quest name then hit ENTER to see its top comment from wowhead:"
  end

  def scrape_for_quest_data(user_input)
    scraper = QuestCom::Scraper.new(user_input)
    scraper.scrape_to_create_quest_object
  end

end
