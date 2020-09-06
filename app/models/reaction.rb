class Reaction < ApplicationRecord
  self.inheritance_column = :_sti_disabled

  RESOURCE_TYPES = ["post", "comment"].freeze
  REACTION_TYPES = ["like", "smile", "heart"].freeze

  validates :resource_type, presence: true, inclusion: { in: RESOURCE_TYPES }
  validates :type,          presence: true, inclusion: { in: REACTION_TYPES }
end
