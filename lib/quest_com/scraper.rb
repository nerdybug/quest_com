class QuestCom::Scraper

  def initialize(user_input)
    # save this as a variable that can be put out with the results: You searched for "#{user_input}"...
    @user_input = user_input
    prepared_input = prepare_input_for_search(user_input)
    parse_quest_id(search_for_result_body(prepared_input))
    # should move these calls to CLI?
  end

  def prepare_input_for_search(input)
    # does not yet handle anything with PUNCTUATION
    remove = %w(and of the with : . , ' ! ?) # array of items that are irrelevant to the search - may need to add
    removeRegex = Regexp.union(remove) # prapares the array for regex, example: /and|of|the|with/
    result = input.downcase
    result = result.gsub(removeRegex, '').squeeze(" ") # handle any extraneous spaces
  end

  def search_for_result_body(prepared_input)
    # utilize URI to hit a url and gather the response
    query = URI.escape(prepared_input) # => a%20binding%20contract
    url = URI.parse("http://www.wowhead.com/search?q=#{query}&opensearch")
    request = Net::HTTP::Get.new(url.to_s)
    result = Net::HTTP.start(url.host, url.port) {|http| http.request(request)}
    result.body
    # binding.pry
  end

  def parse_quest_id(result_body)
    find_my_id = nil
    parsedArray = Array(eval(result_body))
    names = parsedArray[1] # need to look here for "(Quest)" to be included
    # sample data for above: ["Imp-Binding Contract (Item)", "A Binding Contract (Quest)"]
    # binding.pry
    potential_matches = names.select {|name| name.include? "(Quest)"}
    # binding.pry
    if potential_matches.length == 1
      find_my_id = names.index("#{potential_matches[0]}")
      puts "The index for the quest is #{find_my_id}" # only here for testing at the moment
      quest_id = parsedArray[7][find_my_id.to_i][1]
      puts "The quest ID is #{quest_id}" # only here for testing at the moment
    else
      puts "There is no match. Please try your query on wowhead.com" # temporary
    end
    # need to create QuestData object once we have the right ID and give it that property
  end
end
