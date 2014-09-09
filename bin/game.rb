require_relative '../lib/snake_game.rb'

## Main
# Params are: Width, Height, Fullscreen
Game.new(400, 400, ARGV.first == "full").show
