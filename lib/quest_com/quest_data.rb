class QuestCom::QuestData
  attr_reader :quest_id, :top_comment, :all_comments

  def initialize(quest_id, comment_hash_array)
    @quest_id = quest_id
    @comment_data = comment_hash_array # array of comment hash data
    puts "Hello, I am the Quest! My ID is #{@quest_id}. I have #{@comment_data.length} comments." # only here for testing at the moment
    create_and_store_comments(@comment_data)
    # binding.pry
  end

  # def all_comments
  #   @comments # array of Comment objects
  # end

  def create_and_store_comments(array_of_hashes)
    @all_comments = []
    array_of_hashes.each do |hash|
      @all_comments << QuestCom::Comment.new(hash)
    end
    @top_comment = @all_comments[0]
    @all_comments
    # binding.pry
  end

  # def top_comment
  #   # has the top comment and any information about that comment (comments on it, time, date, author)
  #   puts "#{@all_comments[0].body}" # should puts out the body of the first/top comment
  #   # formatting handles line breaks but puts out [npc=number] for links to wowhead npc pages
  #   # and also [url] for links and [b] for map coords
  # end

  def reset
    @quest_id = nil
    @top_comment = nil
    @all_comments = []
  end

  def other_comments
    puts "This will be a numbered list of the quest's other comments."
  end

  def show_top_comment
    top = top_comment
    puts "#{top.body}"
  end

  def options
  	puts "This quest has #{all_comments.length - 1} more comments. Please select an option from the following:"
    puts <<-HEREDOC
    1. see more information about this comment
    2. see a list of other comments
    3. search for another quest's top comment
    4. exit
  	HEREDOC
  	input = gets.strip

  	if input == "1"
  		top = top_comment
  		top.more_information
      # if this is selected, the information shows but the program fully exits
      # need something like #comment_options (just list of other comments, search again or exit)
  	elsif input == "2"
  		other_comments
    elsif input == "3"
      reset
  	elsif input == "4"
  		exit
  	else
  		puts "That is not a valid response."
  		options
  	end
  end

end
