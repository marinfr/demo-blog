module Types
  class QueryType < Types::BaseObject
    field :posts, [Types::PostType], "Fetch all posts", null: false, extras: [:lookahead]

    field :post, Types::PostType, "Fetch a single post", null: false, extras: [:lookahead] do
      argument :id, ID, required: true
    end

    field :comment, Types::CommentType, "Fetch a single comment", null: false, extras: [:lookahead] do
      argument :id, ID, required: true
    end

    def posts(lookahead:)
      preloaded_posts(lookahead).all
    end

    def post(id:, lookahead:)
      preloaded_posts(lookahead).find(id)
    end

    def comment(id:, lookahead:)
      preloaded_comments(lookahead).find(id)
    end

    private

    def preloaded_posts(lookahead)
      models = []
      models << :author if lookahead.selects?(:author)

      if lookahead.selects?(:reactions)
        models << (
          lookahead.selection(:reactions).selects?(:user) ? { reactions: :user } : :reactions
        )
      end

      if lookahead.selects?(:comments)
        comment_relations = []
        comment_relations << :author if lookahead.selection(:comments).selects?(:author)

        if lookahead.selection(:comments).selects?(:reactions)
          comment_relations << (
            lookahead.selection(:comments).selection(:reactions).selects?(:user) ? { reactions: :user } : :reactions
          )
        end

        models << { comments: comment_relations }
      end

      models.empty? ? Post : Post.eager_load(*models)
    end

    def preloaded_comments(lookahead)
      models = []
      models << :author if lookahead.selects?(:author)

      if lookahead.selects?(:reactions)
        models << (
          lookahead.selection(:reactions).selects?(:user) ? { reactions: :user } : :reactions
        )
      end

      models.empty? ? Comment : Comment.eager_load(*models)
    end
  end
end
