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
    for i in 1..5
      if @recipe["text_input_#{i}"] != nil
        @recipe["text_input_#{i}"] = @recipe["text_input_#{i}"].strip
        @recipe["weight_input_#{i}"] = @recipe["weight_input_#{i}"].strip
        if @recipe["text_input_#{i}"] != "" && @recipe["weight_input_#{i}"] != ""
          @recipe["text_input_#{i}"] = @recipe["text_input_#{i}"].capitalize
          @recipe["weight_input_#{i}"] = @recipe["weight_input_#{i}"].capitalize
          @recipe["weight_unit_#{i}"] = @recipe["weight_unit_#{i}"].capitalize
        else
          @recipe["text_input_#{i}"] = nil
          @recipe["weight_input_#{i}"] = nil
          @recipe["weight_unit_#{i}"] = nil
        end
      else
        @recipe["text_input_#{i}"] = nil
        @recipe["weight_input_#{i}"] = nil
        @recipe["weight_unit_#{i}"] = nil
      end
    end
    raise @recipe.inspect
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
      params.permit(:text_input_1, :text_input_2, :text_input_3, :text_input_4, :text_input_5, :weight_unit_1,
        :weight_unit_2, :weight_unit_3, :weight_unit_4, :weight_unit_5, :weight_input_1, :weight_input_2, :weight_input_3, :weight_input_4, :weight_input_5
      )
    end
end
