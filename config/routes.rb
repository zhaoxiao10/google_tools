GoogleTools::Application.routes.draw do

  resources :websites do
    resources :keywords, :shallow => true do
      get :crawler, :on => :member
      get :flotr, :on => :member
      collection do
        get :batchnew
        get :batchcrawler
        post :batchadd
        get :export
        post :doexport
      end
    end
  end

  devise_for :users

  #root :to => 'high_voltage/pages#show', :id => 'welcome'
  root :to => 'websites#index', :id => 'welcome'

end
