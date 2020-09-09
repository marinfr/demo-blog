module Mutations
  class CreateComment < BaseMutation
    argument :post_id, ID,     required: true
    argument :content, String, required: true

    field :comment, Types::CommentType, null: true
    field :errors,  [String],           null: false

    def resolve(post_id:, content:)
      comment = Post.find(post_id).comments.new(
        content: content,
        user_id: context[:current_user].id
      )

      if comment.valid?
        comment.save!
        { comment: comment }
      else
        { comment: nil }
      end.merge(errors: comment.errors.full_messages)
    end
  end
end
