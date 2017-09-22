class QuestCom::QuestData
  attr_accessor :all_comments, :handler

  def initialize(comment_hash_array)
    # @quest_id = quest_id
    create_and_save_comments(comment_hash_array)
    @handler = QuestCom::Handler.new(self)

  end

  def create_and_save_comments(comment_hash_array)
    @all_comments = []
    comment_hash_array.each do |hash|
      self.all_comments << QuestCom::Comment.new(hash)
    end
    order_comments
  end

  def handle
    self.handler # => QuestCom::Handler object with the QuestData stored
  end

  def order_comments
    sorted = self.all_comments.sort_by {|comment| [-comment.rating, comment.date]}
    self.all_comments = sorted
  end

end
