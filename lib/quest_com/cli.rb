class CLI
  # include QuestCom
  extend QuestCom

  def self.start
    greet_user
    input = Readline.readline
    # binding.pry
    quest = Scraper.new.from_input_to_quest(input)
    quest.handle.show_top
    # quest.initial_menu
  end

  def self.greet_user
    puts "* * * Type in the exact quest name and hit Enter to see its top comment from wowhead - or type exit to leave * * *"
  end

  def self.load_msg
    puts "* * * Loading...please wait. * * *\n\n"
  end

  def self.new_or_exit
    puts "\nWould you like to search again? Y/N"
    input = Readline.readline
    case input.downcase
    when "y"
      start
    when "n"
      goodbye
    end
  end

  def self.too_many_matches
    puts "There are too many matches - please narrow your search at http://www.wowhead.com"
    sleep 1
    new_or_exit
  end

  def self.no_matches
    puts "There is no match - please try your query at http://www.wowhead.com" # temporary message
    sleep 1
    new_or_exit
  end

  def self.no_comments
    puts "This quest has no comments."
    new_or_exit
  end

  def self.goodbye
    puts "* * * Thank you and goodbye. * * *"
    sleep 1
    exit
  end

end
