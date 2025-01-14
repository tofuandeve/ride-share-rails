Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'homepages#index'

  resources :drivers do
    resources :trips, only: :index
  end

  patch "/drivers/:id/toggle", to: "drivers#toggle", as: "toggle_active"

  resources :passengers do 
    resources :trips, only: [:index, :new]
  end
  
  resources :trips
  patch "/trips/:id/complete", to: "trips#complete", as: "complete"
end
