class QuestCom::Scraper

  def initialize(user_input)
    # save this as a variable that can be put out with the results: You searched for "#{user_input}"...
    @user_input = user_input

    # should move these calls to CLI?
  end

  def prepare_input_for_search(input)
    # does not yet handle anything with PUNCTUATION
    remove = %w(and of the with : . , ' ! ?) # array of items that are irrelevant to the search - may need to add
    removeRegex = Regexp.union(remove) # prapares the array for regex, example: /and|of|the|with/
    result = input.downcase
    result = result.gsub(removeRegex, '').squeeze(" ") # handle any extraneous spaces
  end

  def search_for_result_body(prepared_input) # find_result_of_name_search
    # utilize URI to hit a url and gather the response
    query = URI.escape(prepared_input) # => a%20binding%20contract
    url = URI.parse("http://www.wowhead.com/search?q=#{query}&opensearch")
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result_body = result.body
    # binding.pry
  end

  def parse_quest_id(result_body)
    parsedArray = Array(eval(result_body))
    names = parsedArray[1] # need to look here for "(Quest)" to be included
    # sample data for above: ["Imp-Binding Contract (Item)", "A Binding Contract (Quest)"]
    # binding.pry
    potential_matches = names.select {|name| name.include? "(Quest)"}
    # binding.pry
    if potential_matches.length == 1
      find_my_id = names.index("#{potential_matches[0]}").to_i
      puts "The index for the quest is #{find_my_id}" # only here for testing at the moment
      quest_id = parsedArray[7][find_my_id][1]
      puts "The quest ID is #{quest_id}" # only here for testing at the moment
      quest_id
    else
      puts "There is no match. Please try your query on wowhead.com" # temporary
    end
  end

  def find_data_from_quest_page(quest_id)
    url = URI.parse("http://www.wowhead.com/q=#{quest_id}/")
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result.body
  end

  def scrape_to_create_quest_object
    # do the work to get from the user's input to creating a QuestData object
    prepared_input = prepare_input_for_search(@user_input)
    quest_id = parse_quest_id(search_for_result_body(prepared_input))
    page_data = find_data_from_quest_page(quest_id)
    QuestCom::QuestData.new(quest_id, page_data)
    # binding.pry
  end
end
