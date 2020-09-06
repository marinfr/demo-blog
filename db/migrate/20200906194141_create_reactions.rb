class CreateReactions < ActiveRecord::Migration[6.0]
  def change
    create_table :reactions do |t|
      t.integer :user_id, null: false
      t.integer :resource_id, null: false
      t.string :resource_type, null: false
      t.string :type, null: false
    end

    add_index :reactions, :user_id
  end
end
