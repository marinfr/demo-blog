class Post < ApplicationRecord
  belongs_to :author, class_name: User.to_s, foreign_key: :user_id
  has_many :comments, dependent: :destroy
  has_many :reactions, -> { where(resource_type: Reaction::POST) }, foreign_key: :resource_id, dependent: :delete_all

  validates :title,   presence: true, length: { minimum: 2, maximum: 255 }
  validates :content, presence: true, length: { minimum: 2, maximum: 8000 }

  Reaction::REACTION_TYPES.each do |type|
    define_method "#{type.pluralize}" do
      reactions.select { |reaction| reaction.public_send("#{type}?") }
    end
  end
end
