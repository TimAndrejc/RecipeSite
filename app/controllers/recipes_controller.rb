class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /recipes or /recipes.json
  def index
    @recipes = Recipe.all
  end

  # GET /recipes/1 or /recipes/1.json
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes or /recipes.json
  def create
    @recipe = recipe_new_params
    @ingredients = []
    for i in 1..10
      if @recipe["text_input_#{i}"].present? && @recipe["number_input_#{i}"].present? && @recipe["weight_unit_#{i}"].present?
        @ingredients << [@recipe["text_input_#{i}"], @recipe["number_input_#{i}"], @recipe["weight_unit_#{i}"]]
      end
    end
    if @ingredients == []
      redirect_to new_recipe_path, notice: "Please fill in at least one ingredient"
    end
    for i in 0..@ingredients.length-1
      @ingredients[i] = @ingredients[i].join(" ")
    end
    @example = 
    '{ 
    "recipeTitle": "Eggs",
    "ingredients": "eggs 2, milk 1 cup, salt 1/2 tsp, pepper 1/2 tsp",
    "instructions": "1. Beat eggs, milk, salt, and pepper in a bowl. 2. Heat a nonstick skillet over medium heat. 3. Add butter to pan; swirl to coat. 4. Pour egg mixture into pan; cook 2 minutes or until almost set. 5. Gently lift edges of omelet with a spatula, tilting pan to allow uncooked portion to flow underneath. 6. Cook 1 minute or until set. 7. Fold omelet in half. 8. Slide onto a plate. 9. Serve immediately."
    } '
    @ingredients = @ingredients.join(", ")
    data = { "messages": [{"role": "user", "content": "I have "+ @ingredients + ". What can I make with that, I have spices. No need to use every ingredient or all of the amount STICK TO THE INGREDIENTS PROVIDED! Respond with the title of the recipe, ingredient list and instructions only. example of response: "+@example}], "max_tokens": 256,  "model": "gpt-3.5-turbo"}
    require 'net/http'
    require 'json'
    # Set up the API endpoint URL and the API key
    url = URI("https://api.openai.com/v1/chat/completions")
    api_key = ""
    # Set up the request headers and body
    headers = { "Content-Type": "application/json", "Authorization": "Bearer #{api_key}" }
    response = Net::HTTP.post(url, data.to_json, headers)
    result = response.body
    @contentofAPI = JSON.parse(result, {symbolize_names: true})[:choices][0][:message][:content]
    @contentofAPI = JSON.parse(@contentofAPI, {symbolize_names: true})
    @recipe = Recipe.new(title: @contentofAPI[:recipeTitle], instructions: @contentofAPI[:instructions], ingredients: @contentofAPI[:ingredients])
    @recipe.user = current_user
    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1 or /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to recipe_url(@recipe), notice: "Recipe was successfully updated." }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1 or /recipes/1.json
  def destroy
    @recipe.destroy

    respond_to do |format|
      format.html { redirect_to recipes_url, notice: "Recipe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipe_params
      params.require(:recipe).permit(:title, :instructions, :difficulty)
    end

    private
    def recipe_params
      params.require(:recipe).permit(:title, :instructions, :difficulty)
    end
    def authenticate_user!
      if user_signed_in?
        super
      else
        redirect_to new_user_session_path, notice: 'Please sign in'
      end
    end
      def recipe_new_params
        params.permit(:text_input_1, :text_input_2, :text_input_3, :text_input_4, :text_input_5, :text_input_6,
                      :text_input_7, :text_input_8, :text_input_9, :text_input_10,
                      :number_input_1, :number_input_2, :number_input_3, :number_input_4, :number_input_5, :number_input_6,
                      :number_input_7, :number_input_8, :number_input_9, :number_input_10,
                      :weight_unit_1, :weight_unit_2, :weight_unit_3, :weight_unit_4, :weight_unit_5, :weight_unit_6,
                      :weight_unit_7, :weight_unit_8, :weight_unit_9, :weight_unit_10
                    )
      end
      
    
end
