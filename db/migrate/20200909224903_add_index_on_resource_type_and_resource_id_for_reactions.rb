class AddIndexOnResourceTypeAndResourceIdForReactions < ActiveRecord::Migration[6.0]
  def change
    add_index :reactions, [:resource_type, :resource_id]
  end
end
