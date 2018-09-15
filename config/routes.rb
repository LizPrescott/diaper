Rails.application.routes.draw do
  devise_for :users

  flipper_app = Flipper::UI.app(Flipper.instance) do |builder|
    builder.use Rack::Auth::Basic do |username, password|
      username == ENV["FLIPPER_USERNAME"] && password == ENV["FLIPPER_PASSWORD"]
    end
  end
  mount flipper_app, at: "/flipper"

  resources :admins do
    collection do
      post :invite_user
    end
  end

  namespace :admin do
    resources :canonical_items
    resources :organizations
    resources :users
    resources :barcode_items
  end
  resources :canonical_items

  namespace :api, defaults: { format: "json" } do
    namespace :v1 do
      resources :partner_requests, only: :create
      resources :partner_approvals, only: :create
    end
  end

  scope path: ":organization_id" do
    resources :users
    resource :organization do
      collection do
        get :manage
      end
    end

    resources :adjustments, except: %i(edit update)
    resources :transfers, only: %i(index create new show)
    resources :storage_locations do
      collection do
        post :import_csv
        post :import_inventory
      end
      member do
        get :inventory
      end
    end

    resources :distributions, except: %i(destroy) do
      get :print, on: :member
      post :reclaim, on: :member
      collection do
        get :pick_ups
      end
    end

    resources :barcode_items do
      get :find, on: :collection
    end
    resources :donation_sites do
      collection do
        post :import_csv
      end
    end
    resources :diaper_drive_participants, except: [:destroy] do
      collection do
        post :import_csv
      end
    end
    resources :items
    resources :partners do
      collection do
        post :import_csv
      end
    end

    resources :donations do
      collection do
        get :scale
        post :scale_intake
      end
      patch :add_item, on: :member
      patch :remove_item, on: :member
    end

    resources :purchases

    get "dashboard", to: "dashboard#index"
    get "csv", to: "data_exports#csv"
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "pages/:name", to: "static#page"
  root "static#index"
end
