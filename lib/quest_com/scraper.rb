# require 'open-uri'
# require 'nokogiri'
class QuestCom::Scraper

  def initialize(user_input)
    @user_input = user_input
  end

  def prepare_input_for_search(input)
    remove = %w(and of the with : . , ' ! ?) # array of items that are irrelevant to the search - may need to add
    removeRegex = Regexp.union(remove) # prapares the array for regex, example: /and|of|the|with/
    result = input.downcase
    result = result.gsub(removeRegex, '').squeeze(" ") # handle any extraneous spaces
  end

  def search_for_result_body(prepared_input) # may change to #find_result_of_name_search
    # utilize URI to hit a url and gather the response
    query = URI.escape(prepared_input) # => a%20binding%20contract
    url = URI.parse("http://www.wowhead.com/search?q=#{query}&opensearch")
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result_body = result.body
  end

  def parse_quest_id(result_body)
    parsedArray = Array(eval(result_body))
    names = parsedArray[1] # example => ["Imp-Binding Contract (Item)", "A Binding Contract (Quest)"]
    potential_matches = names.select {|name| name.include? "(Quest)"}

    if potential_matches.length == 1
      find_my_id = names.index("#{potential_matches[0]}").to_i
      # puts "The index for the quest is #{find_my_id}" # only here for testing at the moment
      quest_id = parsedArray[7][find_my_id][1]
      # puts "The quest ID is #{quest_id}" # only here for testing at the moment
      quest_id
    else
      puts "There is no match. Please try your query on wowhead.com" # temporary message
    end
  end

  def find_comments_on_quest_page(quest_id) # using Nokogiri
    html_comments = []
    url = "http://www.wowhead.com/quest=#{quest_id}/"
    doc = Nokogiri::HTML(open(url))
    comments_section = doc.search("div#user-comments").children

    comments_section.each do |element|
      if element.attr("class") == "user-post-"
        html_comments << element.inner_html
      end
    end
    html_comments # currently houses raw html data for each comment - need to clean up
    binding.pry
  end

  def scrape_to_create_quest_object
    # do the work to get from the user's input to creating a QuestData object
    prepared_input = prepare_input_for_search(@user_input)
    quest_id = parse_quest_id(search_for_result_body(prepared_input))
    sleep 5
    comments_data = find_comments_on_quest_page(quest_id)
    QuestCom::QuestData.new(quest_id, comments_data)
  end

end
