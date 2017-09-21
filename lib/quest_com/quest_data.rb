class QuestCom::QuestData
  attr_reader :all_comments, :handler

  def initialize(comment_hash_array)
    # @quest_id = quest_id
    @comment_data = comment_hash_array # array of comment hash data
    create_and_save_comments(@comment_data)
    @handler = QuestCom::Handler.new(self)
  end

  def create_and_save_comments(array_of_hashes)
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

  def handle
    self.handler # => QuestCom::Handler object with the QuestData stored
  end

  def order_comments
    sorted = get_all_comments.sort_by {|comment| comment.rating}.reverse
    @all_comments = sorted
  end

  # def all_comments_list
  #   # comments = get_all_comments
  #   # QuestCom::Handler.assemble_list(comments)
  #   # handle = QuestCom::Handler.new(self)
  #   handle.assemble_list
  #   # options: New search, Exit, Choose number of next comment to view
  #   menu(["N", "E", "C"])
  # end

  def get_all_comments
    @all_comments
  end

  # def show_top_comment
  #   top = get_all_comments[0]
  #   top.current = TRUE
  #   top.clean_body
  #   QuestCom::Handler.prints_top(top)
  #   # options: Info, List, New search, Exit
  #   menu(["I", "L", "N", "E"])
  # end

  # def show_selected(input)
  #   # make selected comment the CURRENT comment
  #   handle.load_msg
  #   index = input.to_i - 1
  #   selected = get_all_comments[index]
  #   clear_current_comment
  #   selected.current = TRUE
  #   QuestCom::Handler.prints_selected(selected)
  #   # options: Info, List, New search, Exit, Choose number of next comment to view
  #   menu(["I", "L", "N", "E", "C"])
  # end

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

  # def menu(options)
  #   # take in an array of letters representing options to give the user
  #   handle.puts_menu(options)
  #   input = Readline.readline
  #   analyze_input(input)
  # end

  # def analyze_input(input)
  #   # when input is a number within range of total comments
  #   if input <= get_all_comments.length.to_s
  #     handle.show_selected(input)
  #   end
  #   # when input is a letter
  #   case input.downcase
  #   when "i"
  #     info
  #   when "l"
  #     all_comments_list
  #   when "n"
  #     reset
  #     QuestCom::CLI.new.call
  #   when "e"
  #     handle.goodbye
  #   else
  #     handle.try_again
  #     menu(["I", "L", "N", "E"])
  #   end
  # end

end
