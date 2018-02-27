Rails.application.routes.draw do
  root 'home#prices'

  get 'home/prices'

  get 'home/app'
end
