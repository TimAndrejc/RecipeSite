class RecipeMailer < ApplicationMailer
    def recipe_email(recipe)
      @recipe = recipe
      @user = @recipe.user
      mail(to: @user.email, subject: 'Recipe from ChefBot')
    end
    def failed(recipe)
      @recipe = recipe
      @user = current_user
      mail(to: @user.email, subject: 'Recipe failed to Create')
    end
end
    
