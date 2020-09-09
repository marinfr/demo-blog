module Mutations
  class DeleteReactionToComment < BaseMutation
    argument :comment_id, ID, required: true

    field :reaction, Types::ReactionType, null: true

    def resolve(comment_id:)
      reaction = Comment.find(comment_id).reactions.find_by(user_id: context[:current_user].id)

      { reaction: reaction ? reaction.destroy! : nil }
    end
  end
end