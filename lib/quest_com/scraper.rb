class QuestCom::Scraper

  def initialize(user_input)
    @user_input = user_input
  end

  def prepare_input_for_search(input)
    remove_regex = /\b(and|of|the|with)\b|[!?.,-_=;:&\(\)\[\]]/
    # binding.pry
    result = input.downcase
    result = result.gsub(remove_regex, '').squeeze(" ")
  end

  def hit_this_url(url)
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result_body = result.body
  end

  def search_for_result_body(prepared_input)
    query = URI.escape(prepared_input) # => a%20binding%20contract
    url = URI.parse("http://www.wowhead.com/search?q=#{query}&opensearch")
    result_body = hit_this_url(url)
  end

  def parse_quest_id(result_body)
    parsedArray = Array(eval(result_body))
    names = parsedArray[1] # example => ["Imp-Binding Contract (Item)", "A Binding Contract (Quest)"]
    potential_matches = names.select {|name| name.include? "(Quest)"}

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

  def find_comments_on_quest_page(quest_id)
    url = URI.parse("http://www.wowhead.com/quest=#{quest_id}/")
    result_body = hit_this_url(url)
    # to find the hash of comment data, we look for a match of var lv_comments0
    match = /var\s+lv_comments0\s+=\s+(\[.+\]);/.match(result_body)
    # the info at index 1 of the match has all the comment data by itself as javascript
    javascript = match[1]
    parsable_json = tidy_for_json(javascript)
    comment_hash_array = JSON.parse(parsable_json) # this gives an array of hashes in tidy JSON
  end

  def scrape_to_create_quest_object
    # do the work to get from the user's input to creating a QuestData object
    prepared_input = prepare_input_for_search(@user_input)
    quest_id = parse_quest_id(search_for_result_body(prepared_input))
    sleep 3
    comment_hash_array = find_comments_on_quest_page(quest_id)
    QuestCom::QuestData.new(quest_id, comment_hash_array)
  end

end
