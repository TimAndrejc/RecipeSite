Rails.application.routes.draw do
  get 'newsletters/new'
  get 'newsletters/create'
  devise_for :users,
  controllers: {
     omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resources :recipes
  resources :newsletters, only: [:new, :create]
  # Defines the root path route ("/")
  root "recipes#index"
  get '/MyRecipes', to: 'my_recipes#index'
  get '/Admin', to: 'recipes#admin', as: 'admin'
  get '/RecipeSearch', to: 'recipes#search', as: 'search'
  post '/send_email', to: 'recipes#sendEmail', as: 'send_email'
  get '/pdf/:id', to: 'recipes#pdf', as: 'pdf'
end
