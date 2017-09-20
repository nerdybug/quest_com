class QuestCom::Handler

  def self.greet_user
    puts "***Type in the exact quest name then hit ENTER to see its top comment from wowhead:***"
  end

  def self.load_msg
    puts "Loading...please wait.\n\n"
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

  def self.match_comments_variable(result_body)
    # comment data lives in var lv_comments0
    match = /var\s+lv_comments0\s+=\s+(\[.+\]);/.match(result_body)
    # the info at index 1 of the match has all the comment data by itself as javascript
    match[1]
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
    puts "\n***Please select from the following:***"
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
    puts "The top comment for this quest is:\n\n"
    puts "\"#{top.body}\""
  end

  def self.prints_selected(selected)
    puts "\"#{selected.body}\""
  end

  def self.try_again
    puts "Invalid selection."
  end

  def self.goodbye
    puts "Thank you and goodbye."
    sleep 1
    exit
  end

  def self.comment_info(comment)
    puts "This comment was posted by #{comment.user} on #{comment.date} - rating: #{comment.rating}"
  end

  def self.assemble_list(comments)
    load_msg
    sleep 1
    counter = 0
    puts "List of all comments:\n\n"
    comments.collect do |comment|
      counter += 1
      puts "#{counter}. #{comment.snippet.strip}... posted on #{comment.date}"
    end
  end

  def self.snip(body)
    body.split(/\s+/, 9)[0...8].join(' ')
  end

  def self.clean(text)
    array = ["npc", "quest", "item", "zone", "spell", "achievement"]
    body = mass_replace(array, text)

    replace_map_link = /\[\burl=.*?#map\]\[b\](?<coords>.*?)\[\/b\]\[\/url\]/
    body.gsub!(replace_map_link, 'Coordinates: \k<coords>')
    body.gsub!(/\[url=.+\[\/url\]/, '')
    body.gsub!(/\[(b|ul|li)\]|\[(\/b|\/li|\/ul)\]/, '')
    body.gsub!(/\[table.*?\[\/table\]/m, '(table best viewed via http://www.wowhead.com)') # temporary
    body.gsub!(/\[hr\]/, '')
    body
    # binding.pry
  end

  def self.replace_names(ids, body)
    scrape = QuestCom::Scraper.new
    ids.each {|id| body.gsub!(/\[\b#{id}\]/, "#{scrape.find_name(id)}")}
    body
  end

  def self.find_and_replace(id, body)
    ids = body.scan(/(?<=\[)#{id}=\d+.*?(?=\])/)
    body = replace_names(ids, body)
  end

  def self.mass_replace(array, body)
    # ex array = ["quest", "npc", "item", "zone"]
    array.each {|ele| find_and_replace("#{ele}", body)}
    body
  end

  def self.shorten(date)
    # take "2013-08-29T09:44:16-05:00" and give me "2013-08-29"
    date.gsub!(/T(.*)/, "")
    date
  end

end
