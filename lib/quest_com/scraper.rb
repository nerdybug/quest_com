require 'net/http'
require 'uri'
require 'json'
require 'open-uri'
require 'nokogiri'

class Scraper
  include QuestCom

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
    analyze("quest_matches", parsed_array) # module method
    # => quest_id to search with or prompts user if no matches or too many matches
  end

  def find_comments_on_quest_page(quest_id)
    url = URI.parse("http://www.wowhead.com/quest=#{quest_id}/")
    result_body = hit_this_url(url)
    javascript = analyze("find_comments", result_body) # module method
    parsable_json = analyze("get_json", javascript) # module method
    comment_hash_array = JSON.parse(parsable_json) # => array of hashes in tidy JSON
  end

  def find_name(id)
    id = URI.escape(id) # sometimes an id can be npc=12345 domain=legion
    url = URI.parse("http://www.wowhead.com/#{id}")
    doc = Nokogiri::HTML(open(url))
    sleep 0.25
    name = doc.css('h1.heading-size-1').text
  end

  def from_input_to_quest(input)
    # do the work to get from the user's input to creating a QuestData object
    prepared_input = prepare_input(input) # module method
    CLI.load_msg
    quest_id = parse_quest_id(search_for_result_body(prepared_input))
    sleep 3
    comment_hash_array = find_comments_on_quest_page(quest_id)
    QuestData.new(comment_hash_array)
  end

end
