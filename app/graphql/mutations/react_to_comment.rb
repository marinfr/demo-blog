module Mutations
  class ReactToComment < BaseMutation
    argument :comment_id, ID,     required: true
    argument :type,       String, required: true

    field :reaction, Types::ReactionType, null: true
    field :errors,   [String],            null: false

    def resolve(comment_id:, type:)
      reaction = Comment.find(comment_id).reactions.find_or_initialize_by(
        user_id: context[:current_user].id,
        type:    type
      )

      if reaction.persisted?
        { reaction: reaction }
      else
        { reaction: reaction.save ? reaction : nil }
      end.merge(errors: reaction.errors.full_messages)
    end
  end
end