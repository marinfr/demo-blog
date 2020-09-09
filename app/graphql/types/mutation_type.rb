module Types
  class MutationType < Types::BaseObject
    field :create_post, "Create a post for current user", mutation: Mutations::CreatePost
    field :update_post, "Update a post for current user", mutation: Mutations::UpdatePost
    field :delete_post, "Delete a post for current user", mutation: Mutations::DeletePost

    field :create_comment, "Create a comment for current user on a post", mutation: Mutations::CreateComment
    field :update_comment, "Update a comment for current user on a post", mutation: Mutations::UpdateComment
    field :delete_comment, "Delete a comment for current user on a post", mutation: Mutations::DeleteComment

    field :react_to_post,           "React to a post",           mutation: Mutations::ReactToPost
    field :delete_reaction_to_post, "Delete reaction to a post", mutation: Mutations::DeleteReactionToPost

    field :react_to_comment,           "React to a comment",           mutation: Mutations::ReactToComment
    field :delete_reaction_to_comment, "Delete reaction to a comment", mutation: Mutations::DeleteReactionToComment
  end
end
