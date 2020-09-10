class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id
  has_many :reactions, -> { where(resource_type: Reaction::COMMENT) }, foreign_key: :resource_id, dependent: :delete_all

  validates :content, presence: true, length: { minimum: 2, maximum: 8000 }

  Reaction::REACTION_TYPES.each do |type|
    define_method "#{type.pluralize}" do
      reactions.select { |reaction| reaction.public_send("#{type}?") }
    end
  end
end
