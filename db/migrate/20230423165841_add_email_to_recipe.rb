class AddEmailToRecipe < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :email, :string
  end
end
