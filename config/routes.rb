Rails.application.routes.draw do
  devise_for :users

  root 'pages#home'

  resource :pages, only: [] do
    member do
      get 'login'
    end
  end
end
