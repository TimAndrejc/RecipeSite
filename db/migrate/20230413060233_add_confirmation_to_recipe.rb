class AddConfirmationToRecipe < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :confirmed, :boolean
  end
end
