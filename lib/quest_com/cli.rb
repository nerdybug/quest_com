class QuestCom::CLI

  def call
    greet
    input = gets.strip
    quest = scrape_for_quest_data(input)
    show_top_comment(quest)
    top_options(quest)
  end

  def greet
    puts "Type in the exact quest name then hit ENTER to see its top comment from wowhead:"
  end

  def scrape_for_quest_data(user_input)
    scraper = QuestCom::Scraper.new(user_input)
    scraper.scrape_to_create_quest_object
  end

  def show_top_comment(quest)
    top = quest.top_comment
    puts "#{top.body}"
  end

  def top_options(quest)
  	puts "This quest has #{quest.all_comments.length - 1} more comments. Please select an option from the following:"
  	puts <<-HEREDOC
  		1. see more information about this comment
  		2. see a list of other comments
  		3. exit
  	HEREDOC
  	input = gets.strip

  	if input == "1"
  		top = quest.top_comment
  		top.more_information
      # if this is selected, the information shows but the program fully exits
  	elsif input == "2"
  		# not yet written
  	elsif input == "3"
  		exit
  	else
  		puts "That is not a valid response."
  		top_options(quest)
  	end
  end

end
