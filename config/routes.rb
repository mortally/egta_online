EgtMongoid::Application.routes.draw do

  devise_for :users
  resources :accounts
  resources :profiles
  resources :simulations, :except => :edit
  resources :schedulers, :only => [:index, :destroy]
  resources :game_schedulers do
    member do
      post :add_strategy, :remove_strategy
    end
  end

  match "/game_schedulers/:action/:id" => "game_schedulers"
  resources :simulators, :except => :edit do
    member do
      post :add_strategy, :remove_strategy
    end
  end
  match "/games" => "games#index"
  match "/games/show" => "games#show"
  match "/simulations/destroy" => "simulations#destroy"
  root :to => 'home#index'
end

