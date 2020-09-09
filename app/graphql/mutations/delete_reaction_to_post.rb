module Mutations
  class DeleteReactionToPost < BaseMutation
    argument :post_id, ID, required: true

    field :reaction, Types::ReactionType, null: true

    def resolve(post_id:)
      reaction = Post.find(post_id).reactions.find_by(user_id: context[:current_user].id)

      { reaction: reaction ? reaction.destroy! : nil }
    end
  end
end