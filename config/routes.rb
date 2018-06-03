Rails.application.routes.draw do
  resources :session, only: %i[create]
  put '/session', to: 'session#update'

  resources :user, only: %i[create destroy]
end
