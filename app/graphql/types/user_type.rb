module Types
  class UserType < Types::BaseObject
    description "A blog user"

    field :email, String, null: false
  end
end
