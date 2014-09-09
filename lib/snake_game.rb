require 'gosu'
require_relative 'consts.rb'
require_relative 'snake.rb'
require_relative 'fruit.rb'

# Game window
class Game < Gosu::Window
  include Media

  MAX_FRUITS = 1
  
  def initialize width=800, height=600, fullscreen=false
    super
    self.caption = "Snake Game"

    @background_image = Gosu::Image.new self, media_path('space.png'), true
    @snake = Snake.new self 
    
    @font = Gosu::Font.new self, Gosu::default_font_name, 20 
    
    @fruits = []  
    
    @end_game = Gosu::Sample.new self, media_path('smb_mariodie.wav')
  end
  
  def button_down(id)
    case id
      when Gosu::KbReturn
        if @game_over
          # If the game is restarted, we need to update the cached high_score variable
          @high_score = @snake.score if @snake.score > high_score
          @snake = Snake.new self
          @game_over = false
        end
      when Gosu::KbEscape
        close
      when Gosu::KbP
        @paused = !@paused
      when Gosu::KbLeft
        @snake.direction = Direction::LEFT unless @paused or @game_over
      when Gosu::KbRight
        @snake.direction = Direction::RIGHT unless @paused or @game_over
      when Gosu::KbUp
        @snake.direction = Direction::UP unless @paused or @game_over
      when Gosu::KbDown
        @snake.direction = Direction::DOWN unless @paused or @game_over
    end
  end
  
  def update
    begin
      unless @paused or @game_over
        @snake.update
        @snake.grow @fruits
       
        # remove expired fruits
        @fruits.reject! { |fruit| fruit.expired? }
        
        if @fruits.size < MAX_FRUITS
          @fruits << Fruit.get_instance(self, @snake)
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
    elsif @paused
      @font.draw "PAUSED", width / 2 - 30, height / 2, ZOrder::UI, 1, 1, 0xffffff00
    else
      @background_image.draw 0, 0, ZOrder::Background
      @snake.draw
      @fruits.each(&:draw)
      @font.draw "Your Score: #{@snake.score}", 10, 10, ZOrder::UI, 1, 1, 0xffffff00
      @font.draw "High Score: #{high_score}", 10, 35, ZOrder::UI, 1, 1, 0xffffff00
    end
  end

  def high_score
    high_score_media = media_path('.high_score')
    if File.exists? high_score_media
      @high_score ||= File.open(high_score_media, 'r').read.to_i
    else
      0
    end
  end

  def save_score(score)
    File.open(media_path('.high_score'), 'w'){ |f| f.print score }
  end
end

