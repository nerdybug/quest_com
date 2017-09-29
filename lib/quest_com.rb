require './lib/quest_com/version'
require './lib/quest_com/cli'
require './lib/quest_com/scraper'
require './lib/quest_com/quest_data'
require './lib/quest_com/comment'
require './lib/quest_com/handler'

require 'pry'

module QuestCom
  # extend self

  def prepare_input(input)
    result = input.downcase
    if result == "exit"
      CLI.goodbye
    end
    remove_regex = /\b(and|of|the|with)\b|[!?.,-_=;:&\(\)\[\]]/
    result.gsub!(remove_regex, '')
    result.squeeze(" ")
  end

  def find_quest_matches(parsed_array)
    names = parsed_array[1] # ex => ["Fragrant Dreamleaf (Item)", "Fragrant Dreamleaf (Quest)", "Fragrant Dreamleaf (Object)"]
    potential_matches = names.select {|name| name.include? "(Quest)"}

    if potential_matches.length == 1
      find_my_id = names.index("#{potential_matches[0]}").to_i
      quest_id = parsed_array[7][find_my_id][1] # per structure of server response
      quest_id # => 43738
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

  # def order_comments(quest_obj) # arg: QuestData object
  #   comments = quest_obj.all_comments
  #   sorted = comments.sort_by {|comment| [-comment.rating, comment.date]}
  #   quest_obj.all_comments = sorted
  # end

  def analyze(*args)
    # args => ["request", data_to_use]
    if args.include?("quest_matches")
      find_quest_matches(args[1])
    elsif args.include?("find_comments")
      match_comments_variable(args[1])
    elsif args.include?("get_json")
      tidy_for_json(args[1])
    end
  end

  def from_input_to_quest(input)
    prepared_input = prepare_input(input) # module method
    CLI.load_msg
    result = Scraper.search_for_result_body(prepared_input)
    quest_id = Scraper.parse_quest_id(result)
    sleep 3
    comment_hash_array = Scraper.find_comments_on_quest_page(quest_id)
    QuestData.new(comment_hash_array)
  end
end
