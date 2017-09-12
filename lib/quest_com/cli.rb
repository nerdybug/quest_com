class QuestCom::CLI

  def call
    QuestCom::Handler.greet_user
    input = Readline.readline
    # binding.pry
    quest = QuestCom::Scraper.new(input).scrape_to_create_quest_object
    quest.show_top_comment
    # quest.initial_menu
  end

end
