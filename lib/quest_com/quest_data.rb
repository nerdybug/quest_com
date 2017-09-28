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

  # def assemble_list
  #   CLI.load_msg
  #   sleep 1
  #   counter = 1
  #   puts "List of all comments:\n\n"
  #   comments.collect do |comment|
  #     # counter += 1
  #     puts "#{counter}. #{comment.snippet.strip}... posted on #{comment.date}"
  #     # => 1. Quest located at the west shore of Val'sharah... posted on 2016-09-18
  #     counter += 1
  #   end
  # end

end
