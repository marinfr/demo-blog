module Mutations
  class DeletePost < BaseMutation
    argument :id, ID, required: true

    field :post, Types::PostType, null: false

    def resolve(id:)
      { post: context[:current_user].posts.find(id).destroy! }
    end
  end
end