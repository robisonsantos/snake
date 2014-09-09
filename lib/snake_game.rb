require 'gosu'
require_relative 'consts.rb'
require_relative 'snake.rb'
require_relative 'fruit.rb'

# Game window
class Game < Gosu::Window
  MAX_FRUITS = 1
  
  def initialize width=800, height=600, fullscreen=false
    super
    self.caption = "Snake Game"

    @background_image = Gosu::Image.new self, "../media/space.png", true
    @snake = Snake.new self 
    
    @font = Gosu::Font.new self, Gosu::default_font_name, 20 
    
    @fruits = []  
    
    @end_game = Gosu::Sample.new self, '../media/smb_mariodie.wav'
  end
  
  def button_down(id)
    close if id == Gosu::KbEscape
  end
  
  def update
    begin
      @snake.direction = Direction::LEFT if button_down? Gosu::KbLeft
      @snake.direction = Direction::RIGHT if button_down? Gosu::KbRight
      @snake.direction = Direction::UP if button_down? Gosu::KbUp
      @snake.direction = Direction::DOWN if button_down? Gosu::KbDown
      
      @snake.update
      @snake.grow @fruits
     
      # remove expired fruits
      @fruits.reject! { |fruit| fruit.expired? }
      
      if rand(100) < 4 and @fruits.size < MAX_FRUITS
        @fruits << Fruit.get_instance(self)
      end
    rescue Snake::GameOverException
      @game_over = true
      unless @playing
        @end_game.play
        @playing = true
      end
    end
  end
  
  def draw
    if @game_over
      @font.draw "GAME OVER - Score: #{@snake.score}", width / 2 - 70, height / 2, ZOrder::UI, 1, 1, 0xffffff00
    else
      @background_image.draw 0, 0, ZOrder::Background
      @snake.draw
      @fruits.each(&:draw)
      @font.draw "Score: #{@snake.score}", 10, 10, ZOrder::UI, 1, 1, 0xffffff00
    end
  end
end

