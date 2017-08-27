class QuestCom::QuestData
  attr_reader :quest_id, :all_comments

  def initialize(quest_id, comment_hash_array)
    @quest_id = quest_id
    @comment_data = comment_hash_array # array of comment hash data
    puts "Hello, I am the Quest! My ID is #{@quest_id}. I have #{@comment_data.length} comments." # only here for testing at the moment
    create_and_store_comments(@comment_data)
    # binding.pry
  end

  def create_and_store_comments(array_of_hashes)
    @all_comments = []
    array_of_hashes.each do |hash|
      @all_comments << QuestCom::Comment.new(hash)
    end
    @all_comments
    # binding.pry
  end

  def reset
    @quest_id = nil
    @all_comments = []
  end

  def all_comments_list
    puts "This will be a numbered list of all of the quest's comments." # here for testing
    comments = get_all_comments
    counter = 0
    comments.collect do |comment|
      body = comment.body
      result = body.gsub(/\[url=.+\[\/url\]/, "") # this needs to be somewhere that tidies the comment body
      new_result = result.split(/\s+/, 9)[0...8].join(' ') # pulls out the first handful of words
      counter += 1
      puts "#{counter}. #{new_result.strip}... #{comment.more_information}"
      # binding.pry
    end
    # options: pick number to see full comment, new search, exit; C, N, E
    menu(["N", "E", "C"])
  end

  def get_all_comments
    self.all_comments
  end

  def show_top_comment
    comments = get_all_comments
    comments.select do |comment|
      if comment.top_comment
        puts "#{comment.body}" # needs format tweaking still
      end
    end
  end

  def find_current_comment
    comments = get_all_comments
    comments.select {|comment| comment.current == comment}
  end

  def initial_menu
    menu(["I", "L", "N", "E"])
    input = gets.strip
    analyze_input(input)
  end

  def menu(options)
    # take in an array of letters representing options to give the user
    puts "\nPlease select from the following:"
    options.each do |opt|
      case opt
      when "I"
        puts "I = see more Information about this comment"
      when "L"
        puts "L = see a List of all comments"
      when "N"
        puts "N = search for a New quest's top comment"
      when "C"
        puts "Or enter the number of any comment from the list to see its full text"
      when "E"
        puts "E = Exit"
      end
    end
    input = gets.strip
    analyze_input(input)
  end

  def analyze_input(input)
    case input.downcase
    when "i"
      current = find_current_comment
      puts "#{current[0].more_information}"
      menu(["L", "N", "E"])
    when "l"
      all_comments_list
    when "n"
      reset
      QuestCom::CLI.new.call
    when "e"
      exit
    else
      puts "Invalid selection."
      initial_menu
    end
    # add in way to handle numeral entered from list of comments...
  end

end
