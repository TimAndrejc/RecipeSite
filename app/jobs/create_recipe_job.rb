class CreateRecipeJob < ApplicationJob
  queue_as :default

  def perform(ingredients, current_user)
  begin
    @recipe.user = current_user
    @example = 
      '{ 
      "recipeTitle": "Eggs",
      "ingredients": "eggs 2 pc, milk 150 ml, salt 1/2 tsp, pepper 1/2 tsp",
      "instructions": "1. Beat eggs, milk, salt, and pepper in a bowl. 2. Heat a nonstick skillet over medium heat. 3. Add butter to pan; swirl to coat. 4. Pour egg mixture into pan; cook 2 minutes or until almost set. 5. Gently lift edges of omelet with a spatula, tilting pan to allow uncooked portion to flow underneath. 6. Cook 1 minute or until set. 7. Fold omelet in half. 8. Slide onto a plate. 9. Serve immediately."
      } '
      data = { "messages": [{"role": "user", "content": "I have "+ ingredients + ". What can I make with that, I have spices. No need to use every ingredient or all of the amount STICK TO THE INGREDIENTS PROVIDED! Respond with the title of the recipe, ingredient list and instructions only. example of response: "+@example}], "max_tokens": 512,  "model": "gpt-3.5-turbo"}
      require 'net/http'
      require 'json'
      # Set up the API endpoint URL and the API key
      url = URI("https://api.openai.com/v1/chat/completions")
      api_key = ENV["api_key"]
      # Set up the request headers and body
      headers = { "Content-Type": "application/json", "Authorization": "Bearer #{api_key}" }
      response = Net::HTTP.post(url, data.to_json, headers)
      result = response.body
      @contentofAPI = JSON.parse(result, {symbolize_names: true})[:choices][0][:message][:content]
      @contentofAPI = JSON.parse(@contentofAPI, {symbolize_names: true})
      @recipe = Recipe.new(title: @contentofAPI[:recipeTitle], instructions: @contentofAPI[:instructions], ingredients: @contentofAPI[:ingredients])
      @recipe.email = current_user.email
        if @recipe.save
          if @recipe.user.present?
            RecipeMailer.recipe_email(@recipe).deliver_now
          end
        end
  rescue => e
    @recipe = Recipe.new(title: "Failed to create recipe", instructions: e)
    @recipe.email = current_user.email
    RecipeMailer.failed(@recipe).deliver_now
  end
  end
end
