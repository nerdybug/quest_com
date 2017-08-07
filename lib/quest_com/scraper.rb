class QuestCom::Scraper

  def initialize(user_input)
    # save this as a variable that can be put out with the results: You searched for "#{user_input}"...
    @user_input = user_input
    prepared_input = prepare_input_for_search(user_input)
    parse_quest_id(search_for_result_body(prepared_input))
  end

  def prepare_input_for_search(input)
    # does not yet handle anything with PUNCTUATION
    wordsToRemove = %w(and of the with) # array for words that are irrelevant to the search
    removeRegex = Regexp.union(wordsToRemove) # prapares the array for regex ex
    # => /and|of|the|with/
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
    parsedArray = Array(eval(result_body))
    names = parsedArray[1] # need to look here for "(Quest)" to be included
    # sample data for above: ["Imp-Binding Contract (Item)", "A Binding Contract (Quest)"]
    # binding.pry

  end

end
