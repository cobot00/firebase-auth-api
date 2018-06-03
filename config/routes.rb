Rails.application.routes.draw do
  resources :session, only: %i[create]

  resources :user, only: %i[create destroy]
end
