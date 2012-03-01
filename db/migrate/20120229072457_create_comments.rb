class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string      :activity
      t.text        :content
      t.string      :user_name
      t.references  :commentable, :polymorphic => true

      t.timestamps
    end
  end
end
