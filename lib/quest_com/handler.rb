require 'readline'
include QuestCom
class QuestCom::Handler
  attr_reader :quest_data

  def initialize(quest_data)
    @quest_data = quest_data
  end

  def comments
    self.quest_data.all_comments # => array of Comment objects for the quest
  end

  def data
    self.quest_data # => QuestData object
  end

  # def assemble_list
  #   CLI.load_msg
  #   sleep 1
  #   counter = 0
  #   puts "List of all comments:\n\n"
  #   comments.collect do |comment|
  #     counter += 1
  #     puts "#{counter}. #{comment.snippet.strip}... posted on #{comment.date}"
  #     # => 1. Quest located at the west shore of Val'sharah... posted on 2016-09-18
  #   end
  # end

  def show_selected(input)
    CLI.load_msg
    index = input.to_i - 1
    selected = comments[index]
    clear_current_comment # => sets current attr to FALSE for all comments
    selected.current = TRUE
    selected.clean_body
    puts "#{selected.body}"
    # options: Info, List, New, Exit, Choose number
    CLI.menu(["I", "L", "N", "E", "C"])
  end

  # def show_top
  #   top = comments[0]
  #   top.current = TRUE
  #   top.clean_body
  #   puts "The top comment for this quest is:\n\n"
  #   puts "#{top.body}"
  #   # options: Info, List, New, Exit
  #   menu(["I", "L", "N", "E"])
  # end

  def info
    current_comment = find_current_comment
    # CLI.comment_info(current_comment)
    current_comment.show_info
    if current_comment == comments[0]
      # different options needed when viewing the highest rated comment
      # options: List, New, Exit
      CLI.menu(["L", "N", "E"])
    else
      # options: List, New, Exit, Choose number
      CLI.menu(["L", "N", "E", "C"])
    end
  end

  # def comment_info(comment)
  #   puts "\nThis comment was posted by #{comment.user} on #{comment.date} - rating: #{comment.rating}"
  # end

  def clear_current_comment
    comments.each {|comment| comment.current = FALSE}
  end

  def find_current_comment
    results = comments.select {|comment| comment.current == TRUE}
    current = results[0]
  end

  def menu(options)
    range = "1 - #{comments.length}"
    sleep 1
    puts "\n* * * Please select from the following: * * *\n\n"
    options.each do |opt|
      case opt
      when "I"
        puts "I = see more Information about this comment"
      when "L"
        puts "L = see a List of all comments"
      when "N"
        puts "N = search for a New quest's top comment"
      when "C"
        puts "OR enter the number of any comment from the numbered list to see its full text, #{range}"
      when "E"
        puts "E = Exit"
      end
    end
    input = Readline.readline
    analyze_input(input)
  end

  def analyze_input(input)
    # when input is a number within range of total comments
    if input.to_i <= comments.length && input.to_i != 0
      show_selected(input)
    end
    # when input is a letter
    case input.downcase
    when "i"
      info
    when "l"
      CLI.assemble_list(comments)
      # options: New, Exit, Choose number
      CLI.menu(["N", "E", "C"])
    when "n"
      CLI.start
    when "e"
      CLI.goodbye
    else
      binding.pry
      try_again
      # options: Info, List, New, Exit
      CLI.menu(["I", "L", "N", "E"])
    end
  end

  def try_again
    puts "* * * Invalid selection. * * *"
  end

  def self.snip(body)
    raw_snip = body.split(" ").first(30).join(" ")
    clean_snip = clean(raw_snip)
    clean_snip.split(/\s+/, 9)[0...8].join(' ')
  end

  def self.clean(text)
    array = ["npc", "quest", "item", "zone", "spell", "achievement"]
    body = mass_replace(array, text)
    # remove map link, keep coordinates
    replace_map_link = /\[\burl=.*?#map\]\[b\](?<coords>.*?)\[\/b\]\[\/url\]/
    body.gsub!(replace_map_link, 'Coordinates: \k<coords>')
    # remove link tags, keep actual link
    body.gsub!(/(\[url=)(.*?)(\].*?\[\/url\])/, '\2')
    # remove b, u, i, ul, li tags
    body.gsub!(/\[(b|u|i|ul|li)\]|\[(\/b|\/u|\/i|\/li|\/ul)\]/, '')
    # replace tables
    body.gsub!(/\[table.*?\[\/table\]/m, '(* * * detailed table best viewed on http://www.wowhead.com * * *)') # temporary
    # remove hr tags
    body.gsub!(/\[hr\]/, '')
    # replace quote tags
    body.gsub!(/(\[quote\]|\[\/quote\])/, '"')
    # replace spoiler tag
    body.gsub!(/\[spoiler\]/, 'SPOILER>>>')
    body.gsub!(/\[\/spoiler\]/, '<<<SPOILER')
    body
    # binding.pry
  end

  def self.replace_names(ids, body)
    # ids ex: npc=12345, quest=23456
    # scrape = Scraper.new
    ids.each {|id| body.gsub!(/\[\b#{id}\]/, "#{Scraper.find_name(id)}")}
    body
  end

  def self.find_and_replace(id, body)
    # id ex: npc, quest
    ids = body.scan(/(?<=\[)#{id}=\d+.*?(?=\])/)
    # ids ex: npc=12345, quest=23456
    body = replace_names(ids, body)
  end

  def self.mass_replace(array, body)
    # array ex: ["quest", "npc", "item", "zone"]
    array.each {|ele| find_and_replace("#{ele}", body)}
    body
  end

  def self.shorten(date)
    # take "2013-08-29T09:44:16-05:00" and give me "2013-08-29"
    date.gsub!(/T(.*)/, "")
    date
  end

end
