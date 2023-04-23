class RecipeMailer < ApplicationMailer
    def recipe_email(recipe)
      @recipe = recipe
      @user = @recipe.user
      mail(to: @user.email, subject: 'Recipe from ChefBot')
    end
end
    
