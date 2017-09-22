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
    sorted = get_all_comments.sort_by {|comment| [-comment.rating, comment.date]}
    # sorted = get_all_comments.sort_by {|comment| comment.rating}.reverse
    @all_comments = sorted
  end

  def get_all_comments
    @all_comments
  end

end
