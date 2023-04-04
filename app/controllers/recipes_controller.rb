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
        rows = []
        params.each do |param_name, param_value|
          # Extract the index from the parameter name
          if param_name =~ /^text_input_(\d+)$/
            index = $1.to_i
            # Initialize a new row if this is the first parameter for this index
            rows[index] ||= {}
            # Add the parameter value to the row
            rows[index][:ingredient] = param_value
          elsif param_name =~ /^number_input_(\d+)$/
            index = $1.to_i
            rows[index] ||= {}
            rows[index][:weight] = param_value
          elsif param_name =~ /^weight_unit_(\d+)$/
            index = $1.to_i
            rows[index] ||= {}
            rows[index][:unit] = param_value
          end
        end
        # Remove any rows that don't have all three values
        rows.reject! { |row| row.values.any?(&:blank?) }
        # Convert the rows to an array of permitted parameters
        rows.map { |row| ActionController::Parameters.new(row).permit(:ingredient, :weight, :unit) }
      end
      
    
end
