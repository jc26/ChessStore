class ChangePictureInItems < ActiveRecord::Migration
  def change
    change_column :items, :picture, :string, :null => true
  end
end
