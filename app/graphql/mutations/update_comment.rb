module Mutations
  class UpdateComment < BaseMutation
    argument :id,      ID,     required: true
    argument :content, String, required: true

    field :comment, Types::CommentType, null: false
    field :errors,  [String],           null: false

    def resolve(id:, content:)
      comment = context[:current_user].comments.find(id)

      comment.assign_attributes(
        content: CommentsController.helpers.strip_tags(content.strip)
      )

      if comment.valid?
        comment.save! if comment.changed?
      else
        comment.restore_attributes
      end

      { comment: comment, errors: comment.errors.full_messages }
    end
  end
end
