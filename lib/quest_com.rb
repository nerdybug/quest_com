require './lib/quest_com/version'
require './lib/quest_com/cli'
require './lib/quest_com/scraper'
require './lib/quest_com/quest_data'
require './lib/quest_com/comment'

require 'pry'

module QuestCom
  # extend self

  def prepare_input(input)
    if input.is_a? Array
      string_input = input.join(" ")
    elsif input.is_a? String
      string_input = input.downcase.squeeze(" ")
      if string_input == "exit"
        CLI.goodbye
      end
    end
    prepared_input = string_input
  end

  def find_quest_matches(parsed_array)
    names = parsed_array[1] # ex => ["Fragrant Dreamleaf (Item)", "Fragrant Dreamleaf (Quest)", "Fragrant Dreamleaf (Object)"]
    potential_matches = names.select {|name| name.include? "(Quest)"}

    if potential_matches.length == 1
      match_index = names.index("#{potential_matches[0]}").to_i
      quest_id = parsed_array[7][match_index][1] # per structure of server response => 43738
      quest_title = parsed_array[1][match_index]
      slug_title = quest_title.gsub('(Quest)', '').strip.downcase.gsub(' ', '-').gsub(/[^\w-]/, '')
      id_and_title = [quest_id, slug_title] # => [43738, "coastal-gloom"]
    elsif potential_matches.length > 1
      CLI.too_many_matches
    else
      CLI.no_matches
    end
  end

  def match_comments_variable(result_body)
    # comment data lives in var lv_comments0
    match = /var\s+lv_comments0\s+=\s+(\[.+\]);/.match(result_body)
    # the info at index 1 of the match has all the comment data by itself as javascript, nil = no comments
    if match == nil
      CLI.no_comments
    else
      match[1]
    end
  end

  def tidy_for_json(javascript)
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

  def get_snip(text)
    raw_snip = text.split(" ").first(30).join(" ")
    clean_snip = clean(raw_snip)
    clean_snip.split(/\s+/, 9)[0...8].join(' ')
  end

  def clean(text)
    array = ["npc", "quest", "item", "zone", "spell", "achievement"]
    text = mass_replace(array, text)
    # remove map link, keep coordinates
    replace_map_link = /\[\burl=.*?#map\]\[b\](?<coords>.*?)\[\/b\]\[\/url\]/
    text.gsub!(replace_map_link, 'Coordinates: \k<coords>')
    # remove link tags, keep actual link
    text.gsub!(/(\[url=)(.*?)(\].*?\[\/url\])/, '\2')
    # remove b, u, i, ul, li tags
    text.gsub!(/\[(b|u|i|ul|li)\]|\[(\/b|\/u|\/i|\/li|\/ul)\]/, '')
    # replace tables
    text.gsub!(/\[table.*?\[\/table\]/m, '(* * * detailed table best viewed on http://www.wowhead.com * * *)') # temporary
    # remove hr tags
    text.gsub!(/\[hr\]/, '')
    # replace quote tags
    text.gsub!(/(\[quote\]|\[\/quote\])/, '"')
    # replace spoiler tag
    text.gsub!(/\[spoiler\]/, 'SPOILER>>>')
    text.gsub!(/\[\/spoiler\]/, '<<<SPOILER')
    text
  end

  def mass_replace(array, text)
    # array ex: ["quest", "npc", "item", "zone"]
    array.each {|id| find_and_replace("#{id}", text)}
    text
  end

  def find_and_replace(id, text)
    # id ex: npc, quest
    ids = text.scan(/(?<=\[)#{id}=\d+.*?(?=\])/)
    # ids ex: npc=12345, quest=23456
    text = replace_names(ids, text)
  end

  def replace_names(ids, text)
    # ids ex: npc=12345, quest=23456
    ids.each {|id| text.gsub!(/\[\b#{id}\]/, "#{Scraper.find_name(id)}")}
    text
  end

  def shorten(date)
    date.gsub!(/T(.*)/, "")
    date
  end

  def analyze(*args)
    # args => ["request", data_to_use]
    if args.include?("quest_matches")
      find_quest_matches(args[1])
    elsif args.include?("find_comments")
      match_comments_variable(args[1])
    elsif args.include?("get_json")
      tidy_for_json(args[1])
    elsif args.include?("get_snippet")
      get_snip(args[1])
    elsif args.include?("clean_up")
      clean(args[1])
    elsif args.include?("fix_date")
      shorten(args[1])
    end
  end

  def from_input_to_quest(input)
    prepared_input = prepare_input(input) # module method
    CLI.load_msg
    result = Scraper.search_for_result_body(prepared_input)
    quest_id_and_title = Scraper.parse_quest_id_and_title(result)
    sleep 3
    array_of_hashes = Scraper.find_comments_on_quest_page(quest_id_and_title)
    QuestData.new(array_of_hashes)
  end
end
