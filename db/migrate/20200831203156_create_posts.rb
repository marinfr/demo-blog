class CreatePosts < ActiveRecord::Migration[6.0]
  def change
    create_table :posts do |t|
      t.integer :user_id
      t.string :title, null: false, default: ""
      t.text :content, null: false
      t.timestamps null: false
    end

    add_index :posts, :user_id
  end
end
