class QuestData
  attr_accessor :all_comments
  include QuestCom

  def initialize(array_of_hashes)
    create_and_save_comments(array_of_hashes)
  end

  def create_and_save_comments(array_of_hashes)
    @all_comments = []
    array_of_hashes.each do |hash|
      @all_comments << QuestCom::Comment.new(hash)
    end
    order_comments
  end

  def get_comments
    @all_comments
  end

  def order_comments
    sorted = get_comments.sort_by {|comment| [-comment.rating, comment.date]}
    self.all_comments = sorted
    # => array of Comment objects sorted by highest rating then lowest date
  end

  def show_top
    top = get_comments[0]
    top.current = TRUE
    body = top.clean_body
    CLI.top(body)
    # options: Info, List, New, Exit
    CLI.menu(["I", "L", "N", "E"], get_comments)
    user_picks(CLI.get_input)
  end

  def show_selected(input)
    CLI.load_msg
    index = input.to_i - 1
    selected = get_comments[index]
    clear_current_comment # => sets current attr to FALSE for all comments
    selected.current = TRUE
    selected.clean_body
    puts "#{selected.body}"
    # options: Info, List, New, Exit, Choose number
    CLI.menu(["I", "L", "N", "E", "C"], get_comments)
    user_picks(CLI.get_input)
  end

  def list_comments
    CLI.load_msg
    CLI.assemble_list(get_comments)
  end

  def clear_current_comment
    get_comments.each {|comment| comment.current = FALSE}
  end

  def find_current_comment
    results = get_comments.select {|comment| comment.current == TRUE}
    current = results[0]
  end

  def info
    current_comment = find_current_comment
    current_comment.show_info

    if current_comment == get_comments[0]
    # different options needed when viewing the highest rated comment
    # options: List, New, Exit
      CLI.menu(["L", "N", "E"])
      user_picks(CLI.get_input)
    else
    # options: List, New, Exit, Choose number
      CLI.menu(["L", "N", "E", "C"], get_comments)
      user_picks(CLI.get_input)
    end
  end

  def user_picks(input)
    # when input is a number, not 0
    if input.to_i != 0
      show_selected(input)
    end
    # when input is a letter
    case input.downcase
    when "i"
      info
    when "l"
      list_comments
      # options: New, Exit, Choose number
      CLI.menu(["N", "E", "C"], get_comments)
      user_picks(CLI.get_input)
    when "n"
      CLI.new_search
    when "e"
      CLI.goodbye
    else
      CLI.try_again
      # options: Info, List, New, Exit
      CLI.menu(["I", "L", "N", "E"])
      user_picks(CLI.get_input)
    end
  end

end
