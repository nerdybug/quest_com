class QuestData
  attr_accessor :all_comments, :handler
  include QuestCom

  def initialize(comment_hash_array)
    create_and_save_comments(comment_hash_array)
    @handler = QuestCom::Handler.new(self)
  end

  def create_and_save_comments(comment_hash_array) # array_of_hashes
    @all_comments = []
    comment_hash_array.each do |hash|
      @all_comments << QuestCom::Comment.new(hash)
    end
    order_comments
  end

  def handle
    self.handler # => QuestCom::Handler object with the QuestData stored
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
  end

end
