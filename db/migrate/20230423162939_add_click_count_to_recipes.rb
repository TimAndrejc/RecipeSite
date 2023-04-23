class AddClickCountToRecipes < ActiveRecord::Migration[7.0]
  def change
    add_column :recipes, :click_count, :integer
  end
end
