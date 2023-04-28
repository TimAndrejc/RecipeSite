class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /recipes or /recipes.json
  def index
    @recipes = Recipe.all.order("created_at DESC")
    @recipes = @recipes.where("confirmed = ?", true)
    @trending_recipes = Recipe.where('click_count > ?', 0).order(click_count: :desc).limit(3).where("confirmed = ?", true)
  end
  
  def admin
    @recipes = Recipe.select(:id, :title, :click_count)
    @trending_recipes = Recipe.where('click_count > ?', 0).order(click_count: :desc).limit(3).where("confirmed = ?", true)
    @count = Recipe.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight).count
  end

  def sendEmail
    RecipeMailer.hot_recipe_email.deliver_now
    redirect_to admin_path, notice: "Emails sent"
  end
  def pdf
    @recipe = Recipe.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        pdf_html = render_to_string(:file => "#{Rails.root}/app/views/recipes/pdf.html.erb", :layout => false)
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        send_data pdf, :filename => 'recipe.pdf', :type => 'application/pdf', :disposition => 'inline'
      end
    end
  end
  
  # GET /recipes/1 or /recipes/1.json
  def show
    @recipe = Recipe.find(params[:id])
    @recipe.update(click_count: (@recipe.click_count || 0) + 1) 
    
  end
  def search 
    @recipes = Recipe.all.where("confirmed = ?", true)
    if params.present?
      if params[:search].present?
        @recipes = @recipes.where("UPPER(title) LIKE ?", "%#{params[:search].upcase}%")
      end
      if params[:difficulty].present?
        @recipes = @recipes.where("difficulty = ?", params[:difficulty])
      end
      if params[:sort].present?
        if params[:sort] == "newest"
          @recipes = @recipes.order("created_at DESC")
        elsif params[:sort] == "oldest"
          @recipes = @recipes.order("created_at ASC")
        elsif params[:sort] == "difficulty"
          @recipes = @recipes.order("difficulty ASC")
        elsif params[:sort] == "clicks"
          @recipes = @recipes.order("click_count DESC")
        end
      end
      @search_results = @recipes
    end
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
    if params['recipe'].present?
      if params['recipe']['csv_file'].present?
        csv_file = params['recipe']['csv_file']
        csv_file = csv_file.read
        csv_file = csv_file.split("\r ")

        for i in 0..csv_file.length-1
         csv_file[i] = csv_file[i].split(",")
        end
        for i in 0..csv_file.length-1
          for j in 0..csv_file[i].length-1
           csv_file[i][j] = csv_file[i][j].strip
          end
        end
        for i in 0..csv_file.length-1
         @recipe["text_input_#{i+1}"] = csv_file[i][0]
         @recipe["number_input_#{i+1}"] = csv_file[i][1]
         @recipe["weight_unit_#{i+1}"] = csv_file[i][2]
        end
      end
    end 
    if( @recipe["text_input_1"].blank? || @recipe["number_input_1"].blank? || @recipe["weight_unit_1"].blank? )
      redirect_to root_path, notice: "Please fill in at least one ingredient"
    else
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
    redirect_to "/MyRecipes", notice: "Your recipe is being created"
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
      format.html { redirect_to "/MyRecipes", notice: "Recipe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def authenticate_admin!
      if current_user.admin != true
        redirect_to root_path, notice: 'You are not an admin'
      end
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
                      :weight_unit_1, :weight_unit_2, :weight_unit_3, :wxweight_unit_4, :weight_unit_5, :weight_unit_6,
                      :weight_unit_7, :weight_unit_8, :weight_unit_9, :weight_unit_10, :csv_file

                    )
      end
      def edit_params
        params.require(:recipe).permit(:title, :difficulty, :confirmed)
      end
      def send_to_recipe(recipe_id)
        redirect_to recipe_path(recipe_id)
      end
      
end
