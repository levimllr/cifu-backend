Rails.application.routes.draw do
  post 'events', to: 'events#create'
  get 'begin_auth', to: 'auth#begin'
  get 'finish_auth', to: 'auth#finish'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
