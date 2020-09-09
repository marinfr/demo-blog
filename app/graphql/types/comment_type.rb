module Types
  class CommentType < Types::BaseObject
    description "A blog post comment"

    field :id,         ID,                              null: false
    field :content,    String,                          null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    field :author,     Types::UserType,                 null: false
    field :reactions,  [Types::ReactionType],           null: false
  end
end
