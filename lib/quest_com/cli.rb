class QuestCom::CLI

  def call
    QuestCom::Handler.greet_user
    input = Readline.readline
    # binding.pry
    quest = scrape_for_quest_data(input)
    quest.show_top_comment
    quest.initial_menu
  end

  def scrape_for_quest_data(user_input)
    scraper = QuestCom::Scraper.new(user_input)
    scraper.scrape_to_create_quest_object
  end

end
