class MyRecipesController < ApplicationController
    def index
        @myRecipes = Recipe.where(user_id: current_user.id, confirmed: true)
        @myRecipesNotPosted = Recipe.where(user_id: current_user.id, confirmed: nil)
    end
end
