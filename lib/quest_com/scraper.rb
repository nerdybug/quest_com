require 'net/http'
require 'uri'
require 'json'
require 'open-uri'
require 'nokogiri'

class Scraper
  extend QuestCom

  def self.hit_this_url(url)
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result_body = result.body
  end

  def self.search_for_result_body(prepared_input)
    query = URI.escape(prepared_input) # ex => a%20binding%20contract
    url = URI.parse("http://www.wowhead.com/search?q=#{query}&opensearch")
    result_body = hit_this_url(url) # => String ["coastal gloom", ["Coastal Gloom (Quest)"], [], [], [], [], [], [[5, 43738,0]]]
  end

  def self.parse_quest_id_and_title(result_body)
    parsed_array = Array(eval(result_body))
    # => Array ["coastal gloom", ["Coastal Gloom (Quest)"], [], [], [], [], [], [[5, 43738,0]]]
    find_quest_matches(parsed_array) # module method
    # => array with quest_id and slug_title to search with or prompts user if no matches or too many matches
  end

  def self.find_comments_on_quest_page(array)
    # array with two pieces of data, [0] is the id, [1] is the title
    url = URI.parse("http://www.wowhead.com/quest=#{array[0]}/#{array[1]}")
    result_body = hit_this_url(url)
    javascript = match_comments_variable(result_body) # module method
    parsable_json = tidy_for_json(javascript) # module method
    array_of_hashes = JSON.parse(parsable_json) # => array of hashes in tidy JSON
  end

  def self.find_name(id)
    id = URI.escape(id) # sometimes an id can be npc=12345 domain=legion
    url = URI.parse("http://www.wowhead.com/#{id}")
    doc = Nokogiri::HTML(open(url))
    sleep 0.25
    name = doc.css('h1.heading-size-1').text
  end

end
