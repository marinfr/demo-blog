module Mutations
  class CreatePost < BaseMutation
    argument :title,   String, required: true
    argument :content, String, required: true

    field :post,   Types::PostType, null: true
    field :errors, [String],        null: false

    def resolve(title:, content:)
      post = context[:current_user].posts.new(
        title:   title.strip,
        content: PostsController.helpers.sanitize(
          PostsController.helpers.normalize_content(content)
        )
      )

      if post.valid?
        post.save!
        { post: post }
      else
        { post: nil }
      end.merge(errors: post.errors.full_messages)
    end
  end
end