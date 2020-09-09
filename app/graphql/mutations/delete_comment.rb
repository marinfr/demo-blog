module Mutations
  class DeleteComment < BaseMutation
    argument :id, ID, required: true

    field :comment, Types::CommentType, null: false

    def resolve(id:)
      { comment: context[:current_user].comments.find(id).destroy! }
    end
  end
end
