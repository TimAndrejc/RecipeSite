class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /recipes or /recipes.json
  def index
    @recipes = Recipe.all.order("created_at DESC")
    @recipes = @recipes.where("confirmed = ?", true)
    @trending_recipes = Recipe.where('click_count > ?', 0).order(click_count: :desc).limit(3)
    if params.present?
    
    end
  end

  # GET /recipes/1 or /recipes/1.json
  def show
    @recipe = Recipe.find(params[:id])
    @recipe.update(click_count: (@recipe.click_count || 0) + 1)  
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
  end

  # GET /recipes/1/edit
  def edit
    @recipe.confirmed = true
    @recipe.save
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
    @ingredients = @ingredients.join(", ")
    CreateRecipeJob.perform_later(@ingredients, current_user)

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
      format.html { redirect_to "/MyRecipes", notice: "Recipe was successfully destroyed." }
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
      def edit_params
        params.require(:recipe).permit(:title, :difficulty, :confirmed)
      end
      def send_to_recipe(recipe_id)
        redirect_to recipe_path(recipe_id)
      end
      
end
