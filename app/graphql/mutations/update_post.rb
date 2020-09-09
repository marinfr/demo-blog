module Mutations
  class UpdatePost < BaseMutation
    argument :id,      ID,     required: true
    argument :title,   String, required: true
    argument :content, String, required: true

    field :post,   Types::PostType, null: false
    field :errors, [String],        null: false

    def resolve(id:, title:, content:)
      post = context[:current_user].posts.find(id)

      post.assign_attributes(
        title:   title.strip,
        content: PostsController.helpers.sanitize(
          PostsController.helpers.normalize_content(content)
        )
      )

      if post.valid?
        post.save! if post.changed?
      else
        post.restore_attributes
      end

      { post: post, errors: post.errors.full_messages }
    end
  end
end