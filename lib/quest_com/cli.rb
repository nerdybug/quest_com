require 'readline'

class CLI

  extend QuestCom

  def self.start
    # greet_user
    # input = get_input
    input = ARGV
    if ARGV == []
      search_greeting
      input = get_input
    end
    quest = from_input_to_quest(input)
    quest.show_top
  end

  def self.get_input
    Readline.readline
  end

  def self.search_greeting
    puts "* * * Type in the exact quest name and hit Enter to see its top comment from wowhead - or type exit to leave * * *"
  end

  def self.load_msg
    puts "* * * Loading...please wait. * * *\n\n"
  end

  def self.new_or_exit
    puts "\nWould you like to search again? Y/N"
    input = get_input
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
    puts "There is no match - please try your query at http://www.wowhead.com"
    sleep 1
    new_or_exit
  end

  def self.no_comments
    puts "This quest has no comments."
    sleep 1
    new_or_exit
  end

  def self.goodbye
    puts "* * * Thank you and goodbye. * * *"
    sleep 1
    exit
  end

  def self.menu(*args)
    # args => [options, optional_data]
    sleep 1
    puts "\n* * * Please select from the following: * * *\n\n"
    args[0].each do |opt|
      case opt
      when "I"
        puts "I = see more Information about this comment"
      when "L"
        puts "L = see a List of all comments"
      when "N"
        puts "N = search for a New quest's top comment"
      when "C"
        puts "OR enter the number of any comment from the numbered list to see its full text, 1 - #{args[1].length}"
      when "E"
        puts "E = Exit"
      end
    end
  end

  def self.assemble_list(comments)
    sleep 1
    counter = 1
    puts "List of all comments:\n\n"
    comments.collect do |comment|
      puts "#{counter}. #{comment.snippet.strip}... posted on #{comment.date}"
      # => 1. Quest located at the west shore of Val'sharah... posted on 2016-09-18
      counter += 1
    end
  end

  def self.comment_info(comment)
    puts "\nThis comment was posted by #{comment.user} on #{comment.date} - rating: #{comment.rating}"
  end

  def self.top(body)
    puts "The top comment for this quest is:\n\n"
    puts "#{body}"
  end

  def self.try_again
    puts "* * * Invalid selection. * * *"
  end

end
