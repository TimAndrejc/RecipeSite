class RecipeMailer < ApplicationMailer
    def recipe_email(recipe)
      @recipe = recipe
      @user = @recipe.user
      mail(to: @user.email, subject: 'Recipe from ChefBot')
    end
    
    def hot_recipe_email
      @users = User.all      
      @users.each do |user|
        @user = user
        @recipe = Recipe.where("confirmed = ?", true).order(click_count: :desc).limit(1).first
        mail(to: @user.email, subject: 'Hot Recipe from ChefBot')
      end
    end
end
    
