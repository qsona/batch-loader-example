class Post < ApplicationRecord
  belongs_to :user


  class << self
    def load_posts(ids)
      Post.where(id: ids)
    end

    def load_user(post)
      BatchLoader.for(post.user_id).batch do |user_ids, loader|
        User.where(id: user_ids).each { |user| loader.call(user.id, user) }
      end
    end

    def a(ids)
      posts = load_posts([1, 2, 3])  #      Posts      SELECT * FROM posts WHERE id IN (1, 2, 3)
                                     #      _ ↓ _
                                     #    ↙   ↓   ↘
      users = posts.map do |post|    #   BL   ↓    ↓
        load_user(post)              #   ↓    BL   ↓
      end

      users
    end
  end

end
