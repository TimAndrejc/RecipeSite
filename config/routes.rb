Rails.application.routes.draw do
  get 'newsletters/new'
  get 'newsletters/create'
  devise_for :users
  resources :recipes
  resources :newsletters, only: [:new, :create]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "recipes#index"
  get '/MyRecipes', to: 'my_recipes#index'
  get '/Admin', to: 'recipes#admin', as: 'admin'
end
