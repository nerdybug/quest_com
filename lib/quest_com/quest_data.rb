class QuestCom::QuestData
  attr_reader :all_comments

  def initialize(comment_hash_array)
    # @quest_id = quest_id
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
    # @quest_id = nil
    @all_comments = []
  end

  def order_comments
    sorted = get_all_comments.sort_by {|comment| comment.rating}.reverse
    @all_comments = sorted
  end

  def all_comments_list
    comments = get_all_comments
    QuestCom::Handler.assemble_list(comments)
    # options: New search, Exit, Choose number of next comment to view
    menu(["N", "E", "C"])
  end

  def get_all_comments
    @all_comments
  end

  def show_top_comment
    top = get_all_comments[0]
    top.current = TRUE
    QuestCom::Handler.prints_top(top)
    # options: Info, List, New search, Exit
    menu(["I", "L", "N", "E"])
  end

  def show_selected(input)
    # make selected comment the CURRENT comment
    index = input.to_i - 1
    selected = get_all_comments[index]
    clear_current_comment
    selected.current = TRUE
    QuestCom::Handler.prints_top(selected)
    # options: Info, List, New search, Exit, Choose number of next comment to view
    menu(["I", "L", "N", "E", "C"])
  end

  def info
    current_comment = find_current_comment
    QuestCom::Handler.comment_info(current_comment)
    if current_comment == get_all_comments[0]
      # different options needed when viewing the highest rated first comment
      # options: List, New search, Exit
      menu(["L", "N", "E"])
    else
      # options: List, New search, Exit, Choose number of next comment to view
      menu(["L", "N", "E", "C"])
    end
  end

  def clear_current_comment
    get_all_comments.each {|comment| comment.current = FALSE}
  end

  def find_current_comment
    results = get_all_comments.select {|comment| comment.current == TRUE}
    current = results[0]
  end

  def menu(options)
    # take in an array of letters representing options to give the user
    QuestCom::Handler.puts_menu(options)
    input = Readline.readline
    analyze_input(input)
  end

  def analyze_input(input)
    # when input is a number within range of total comments
    if input <= get_all_comments.length.to_s
      show_selected(input)
    end
    # when input is a letter
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
