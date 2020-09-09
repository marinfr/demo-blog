module Types
  class ReactionType < Types::BaseObject
    description "A reaction"

    field :type, String,          null: false
    field :user, Types::UserType, null: false
  end
end
