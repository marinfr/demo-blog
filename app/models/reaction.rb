class Reaction < ApplicationRecord
  self.inheritance_column = :_sti_disabled

  RESOURCE_TYPES = ["post", "comment"].freeze
  REACTION_TYPES = ["like", "smile", "heart"].freeze

  belongs_to :user

  validates :resource_type, presence: true, inclusion: { in: RESOURCE_TYPES }
  validates :type,          presence: true, inclusion: { in: REACTION_TYPES, message: "has to be either 'like', 'smile' or 'heart'" }

  before_create :remove_previous_reaction

  (RESOURCE_TYPES + REACTION_TYPES).each do |const|
    const_set(const.upcase, const)
  end

  REACTION_TYPES.each do |type|
    define_method "#{type}?" do
      self.type == type
    end
  end

  private

  def remove_previous_reaction
    Reaction.where(resource_type: resource_type, resource_id: resource_id, user_id: user_id).delete_all
  end
end
