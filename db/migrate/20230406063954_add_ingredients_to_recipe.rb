class AddIngredientsToRecipe < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :ingredients, :text
  end
end
