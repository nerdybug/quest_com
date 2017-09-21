class QuestCom::CLI

  def call
    QuestCom::Handler.greet_user
    input = Readline.readline
    # binding.pry
    quest = QuestCom::Scraper.new.from_input_to_quest(input)
    quest.handle.show_top
    # quest.initial_menu
  end

end
