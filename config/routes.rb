Rails.application.routes.draw do
  resources :session, only: %i[create]
end
