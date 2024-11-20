# frozen_string_literal: true

# == Route Map
#
#                                   Prefix Verb   URI Pattern                                                                                       Controller#Action
#                              sidekiq_web        /sidekiq                                                                                          Sidekiq::Web
#                         new_user_session GET    /api/v1/users/sign_in(.:format)                                                                   users/sessions#new {:format=>:json}
#                             user_session POST   /api/v1/users/sign_in(.:format)                                                                   users/sessions#create {:format=>:json}
#                     destroy_user_session DELETE /api/v1/users/sign_out(.:format)                                                                  users/sessions#destroy {:format=>:json}
#                        new_user_password GET    /api/v1/users/password/new(.:format)                                                              devise/passwords#new {:format=>:json}
#                       edit_user_password GET    /api/v1/users/password/edit(.:format)                                                             devise/passwords#edit {:format=>:json}
#                            user_password PATCH  /api/v1/users/password(.:format)                                                                  devise/passwords#update {:format=>:json}
#                                          PUT    /api/v1/users/password(.:format)                                                                  devise/passwords#update {:format=>:json}
#                                          POST   /api/v1/users/password(.:format)                                                                  devise/passwords#create {:format=>:json}
#                                 me_users GET    /api/v1/users/me(.:format)                                                                        users#me {:format=>:json}
#                                    users PUT    /api/v1/users(.:format)                                                                           users#update {:format=>:json}
#                                          DELETE /api/v1/users(.:format)                                                                           users#destroy {:format=>:json}
#                                          POST   /api/v1/users(.:format)                                                                           users#create {:format=>:json}
#                                 products GET    /api/v1/products(.:format)                                                                        products#index {:format=>:json}
#                                          POST   /api/v1/products(.:format)                                                                        products#create {:format=>:json}
#                                  product GET    /api/v1/products/:id(.:format)                                                                    products#show {:format=>:json}
#                                          PATCH  /api/v1/products/:id(.:format)                                                                    products#update {:format=>:json}
#                                          PUT    /api/v1/products/:id(.:format)                                                                    products#update {:format=>:json}
#                                          DELETE /api/v1/products/:id(.:format)                                                                    products#destroy {:format=>:json}
#                             current_cart GET    /api/v1/cart/current(.:format)                                                                    carts#current {:format=>:json}
#                           add_items_cart POST   /api/v1/cart/add_items(.:format)                                                                  carts#add_items {:format=>:json}
#                        remove_items_cart DELETE /api/v1/cart/remove_items(.:format)                                                               carts#remove_items {:format=>:json}
#            rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                           action_mailbox/ingresses/postmark/inbound_emails#create
#               rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                              action_mailbox/ingresses/relay/inbound_emails#create
#            rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                           action_mailbox/ingresses/sendgrid/inbound_emails#create
#      rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#health_check
#            rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                           action_mailbox/ingresses/mandrill/inbound_emails#create
#             rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                                       action_mailbox/ingresses/mailgun/inbound_emails#create
#           rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#index
#                                          POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                          rails/conductor/action_mailbox/inbound_emails#create
#        new_rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/new(.:format)                                      rails/conductor/action_mailbox/inbound_emails#new
#            rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                                      rails/conductor/action_mailbox/inbound_emails#show
# new_rails_conductor_inbound_email_source GET    /rails/conductor/action_mailbox/inbound_emails/sources/new(.:format)                              rails/conductor/action_mailbox/inbound_emails/sources#new
#    rails_conductor_inbound_email_sources POST   /rails/conductor/action_mailbox/inbound_emails/sources(.:format)                                  rails/conductor/action_mailbox/inbound_emails/sources#create
#    rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                               rails/conductor/action_mailbox/reroutes#create
# rails_conductor_inbound_email_incinerate POST   /rails/conductor/action_mailbox/:inbound_email_id/incinerate(.:format)                            rails/conductor/action_mailbox/incinerates#create
#                       rails_service_blob GET    /rails/active_storage/blobs/redirect/:signed_id/*filename(.:format)                               active_storage/blobs/redirect#show
#                 rails_service_blob_proxy GET    /rails/active_storage/blobs/proxy/:signed_id/*filename(.:format)                                  active_storage/blobs/proxy#show
#                                          GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                        active_storage/blobs/redirect#show
#                rails_blob_representation GET    /rails/active_storage/representations/redirect/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations/redirect#show
#          rails_blob_representation_proxy GET    /rails/active_storage/representations/proxy/:signed_blob_id/:variation_key/*filename(.:format)    active_storage/representations/proxy#show
#                                          GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)          active_storage/representations/redirect#show
#                       rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                       active_storage/disk#show
#                update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                               active_storage/disk#update
#                     rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                                    active_storage/direct_uploads#create

require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  scope :api, defaults: { format: :json } do
    scope :v1 do
      devise_for :users, skip: [:registrations], controllers: { sessions: 'users/sessions' }

      resources :users, only: %i[create] do
        collection do
          get :me
          put :update
          delete :destroy
        end
      end

      resources :products

      resource :cart, only: [] do
        collection do
          get :current
          post :add_items
          delete :remove_items
        end
      end
    end
  end
end
