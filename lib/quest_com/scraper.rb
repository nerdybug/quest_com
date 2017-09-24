class QuestCom::Scraper

  def hit_this_url(url)
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result_body = result.body
  end

  def search_for_result_body(prepared_input)
    query = URI.escape(prepared_input) # ex => a%20binding%20contract
    url = URI.parse("http://www.wowhead.com/search?q=#{query}&opensearch")
    result_body = hit_this_url(url) # => String ["coastal gloom", ["Coastal Gloom (Quest)"], [], [], [], [], [], [[5, 43738,0]]]
  end

  def parse_quest_id(result_body)
    parsed_array = Array(eval(result_body))
    # => Array ["coastal gloom", ["Coastal Gloom (Quest)"], [], [], [], [], [], [[5, 43738,0]]]
    names = parsed_array[1] # ex => ["Fragrant Dreamleaf (Item)", "Fragrant Dreamleaf (Quest)", "Fragrant Dreamleaf (Object)"]
    potential_matches = names.select {|name| name.include? "(Quest)"}
    QuestCom::Handler.analyze_matches(parsed_array, names, potential_matches)
    # => quest_id to search with or prompts user re: no matches or too many matches
  end

  def find_comments_on_quest_page(quest_id)
    url = URI.parse("http://www.wowhead.com/quest=#{quest_id}/")
    result_body = hit_this_url(url)
    javascript = QuestCom::Handler.match_comments_variable(result_body)
    parsable_json = QuestCom::Handler.tidy_for_json(javascript)
    comment_hash_array = JSON.parse(parsable_json) # => array of hashes in tidy JSON
  end

  def find_name(id)
    id = URI.escape(id) # in case id is something like npc=12345 domain=legion
    url = URI.parse("http://www.wowhead.com/#{id}")
    doc = Nokogiri::HTML(open(url))
    sleep 0.25
    name = doc.css('h1.heading-size-1').text
  end

  def from_input_to_quest(input)
    # do the work to get from the user's input to creating a QuestData object
    prepared_input = QuestCom::Handler.prepare_input(input)
    QuestCom::Handler.load_msg
    quest_id = parse_quest_id(search_for_result_body(prepared_input))
    sleep 3
    comment_hash_array = find_comments_on_quest_page(quest_id)
    QuestCom::QuestData.new(comment_hash_array)
  end

end
