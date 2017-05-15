Rails.application.routes.draw do
  get 'longestword/game' => 'longestword#game'
  get 'longestword/score' => 'longestword#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
