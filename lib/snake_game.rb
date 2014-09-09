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
      if @game_over
        if button_down? Gosu::KbReturn
          @snake = Snake.new self
          @game_over = false
        end
      else
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
      end
    rescue Snake::GameOverException
      @game_over = true
      @end_game.play
    end
  end
  
  def draw
    if @game_over
      save_score @snake.score if @snake.score > high_score
      @font.draw "GAME OVER", width / 2 - 70, height / 2 - 25, ZOrder::UI, 1, 1, 0xffffff00
      @font.draw "Your Score: #{@snake.score}", width / 2 - 70, height / 2 , ZOrder::UI, 1, 1, 0xffffff00
      @font.draw "High Score: #{high_score}", width / 2 - 70, height / 2 + 25, ZOrder::UI, 1, 1, 0xffffff00

    else
      @background_image.draw 0, 0, ZOrder::Background
      @snake.draw
      @fruits.each(&:draw)
      @font.draw "Your Score: #{@snake.score}", 10, 10, ZOrder::UI, 1, 1, 0xffffff00
      @font.draw "High Score: #{high_score}", 10, 35, ZOrder::UI, 1, 1, 0xffffff00
    end
  end

  def high_score
    if File.exists? '.high_score'
      @high_score ||= File.open('.high_score', 'r').read.to_i
    else
      0
    end
  end

  def save_score(score)
    File.open('.high_score', 'w').print(score)
  end
end

