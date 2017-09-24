class QuestCom::QuestData
  attr_accessor :all_comments, :handler

  def initialize(comment_hash_array)
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
    # => array of Comment objects sorted by highest rating then lowest date
  end

end
