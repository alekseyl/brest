Rails.application.routes.draw do
  # authenticate :developer do
  get 'api/swagger_docs/v1/apidocs', to: 'apidocs#index'

  resources :apidocs, only: [:index]
  resources :items
  resources :promotions
  post '/cart/items_total', to: 'cart#items_total'

  root :to => redirect('api/swagger_docs/v1')
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
