class QuestCom::QuestData
  attr_reader :quest_id, :all_comments

  def initialize(quest_id, comment_hash_array)
    @quest_id = quest_id
    @comment_data = comment_hash_array # array of comment hash data
    create_and_store_comments(@comment_data)
  end

  def create_and_store_comments(array_of_hashes)
    @all_comments = []
    array_of_hashes.each do |hash|
      @all_comments << QuestCom::Comment.new(hash)
    end
    order_comments
  end

  def reset
    @quest_id = nil
    @all_comments = []
  end

  def order_comments
    sorted = get_all_comments.sort_by {|comment| comment.rating}.reverse
    @all_comments = sorted
  end

  def all_comments_list
    counter = 0
    get_all_comments.collect do |comment|
      body = comment.body
      snippet = body.split(/\s+/, 9)[0...8].join(' ') # pulls out the first handful of words
      counter += 1
      puts "#{counter}. #{snippet.strip}... posted on #{comment.date}"
    end
    # options: pick number to see full comment, new search, exit; C, N, E
    menu(["N", "E", "C"])
  end

  def get_all_comments
    @all_comments
  end

  def show_top_comment
    top = get_all_comments[0]
    top.current = TRUE
    QuestCom::Handler.prints_top(top)
    menu(["I", "L", "N", "E"])
  end

  def show_selected(input)
    # make selected comment the CURRENT comment
    index = input.to_i - 1
    selected = get_all_comments[index]
    clear_current_comment
    selected.current = TRUE
    QuestCom::Handler.prints_top(selected)
    menu(["I", "L", "N", "E", "C"])
  end

  def info
    current = find_current_comment
    QuestCom::Handler.current_info(current)
    if current[0] == get_all_comments[0]
      menu(["L", "N", "E"])
    else
      menu(["L", "N", "E", "C"])
    end
  end

  def clear_current_comment
    get_all_comments.each {|comment| comment.current = FALSE}
  end

  def find_current_comment
    get_all_comments.select {|comment| comment.current == TRUE}
  end

  def menu(options)
    # take in an array of letters representing options to give the user
    QuestCom::Handler.puts_menu(options)
    input = Readline.readline
    analyze_input(input)
  end

  def analyze_input(input)
    if input <= get_all_comments.length.to_s
      show_selected(input)
    end

    case input.downcase
    when "i"
      info
    when "l"
      all_comments_list
    when "n"
      reset
      QuestCom::CLI.new.call
    when "e"
      QuestCom::Handler.goodbye
    else
      QuestCom::Handler.try_again
      menu(["I", "L", "N", "E"])
    end
  end

end
