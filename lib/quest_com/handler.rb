class QuestCom::Handler

  def self.greet_user
    puts "Type in the exact quest name then hit ENTER to see its top comment from wowhead:"
  end

  def self.prepare_input(input)
    remove_regex = /\b(and|of|the|with)\b|[!?.,-_=;:&\(\)\[\]]/
    result = input.downcase
    result.gsub!(remove_regex, '')
    result.squeeze(" ")
  end

  def self.analyze_matches(parsedArray, names, potential_matches)
    if potential_matches.length == 1
      find_my_id = names.index("#{potential_matches[0]}").to_i
      quest_id = parsedArray[7][find_my_id][1]
      quest_id
    else
      puts "There is no match. Please try your query on wowhead.com" # temporary message
      # flesh this out a bit - specific text for no match vs too many matches?
      # what if the quest HAS NO COMMENTS as well
    end
  end

  def self.tidy_for_json(javascript)
    # remove key/values that do not matter for the purpose of this program
    javascript.gsub!(/\b(replies|lastEdit):(\[.*?\])/, '')
    javascript.gsub!(/(\bcommentv2|number|id|nreplies|sticky|indent|roles|deleted|outofdate):.*?,/, '')
    javascript.gsub!(/\b,userRating:\d+,+/, '')

    # locate unescaped double quotes to properly escape
    javascript.gsub!(/(?<!\\)(?:\\{2})*\K"/, '\"')
    # the user, body and date values are surrounded with single quotes that need to be double
    user_body_date_regex = /\b(?<key>user|body|date):(?<startQuote>')(?<value>(?:[^']|(?<=\\)')+)(?<endQuote>')/
    javascript.gsub!(user_body_date_regex, '\k<key>:"\k<value>"')
    # find each key and surround it with double quotes to make json parser happy
    javascript.gsub!(/(?<=[{,])([\w]+):/, '"\1":')
    javascript
  end

  def self.puts_menu(options)
    sleep 1
    puts "\nPlease select from the following:"
    options.each do |opt|
      case opt
      when "I"
        puts "I = see more Information about this comment"
      when "L"
        puts "L = see a List of all comments"
      when "N"
        puts "N = search for a New quest's top comment"
      when "C"
        puts "OR enter the number of any comment from the numbered list to see its full text"
      when "E"
        puts "E = Exit"
      end
    end
  end

  def self.prints_top(top)
    puts "\nThe top comment for this quest is:\n\n" # only here for testing at the moment
    puts "\"#{top.body}\""
  end

  def self.prints_selected(selected)
    puts "\"#{selected.body}\""
  end

  def self.current_info(current)
    puts "#{current[0].more_information}"
  end

  def self.try_again
    puts "Invalid selection."
  end

  def self.goodbye
    puts "Thank you and goodbye."
    exit
  end

end
