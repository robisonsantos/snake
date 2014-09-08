require 'gosu'
require 'byebug'

module Direction
  LEFT = :left
  RIGHT = :right
  UP = :up
  DOWN = :down
end

module ZOrder
  Background, Fruit, Snake, UI = *0..3
end

###
# Game window
class Game < Gosu::Window
  MAX_FRUITS = 1
  
  def initialize width=800, height=600, fullscreen=false
    super
    self.caption = "Snake Game"

    @background_image = Gosu::Image.new self, "media/space.png", true
    @snake = Snake.new self 
    
    @font = Gosu::Font.new self, Gosu::default_font_name, 20 
    
    @fruits = []  
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
      
      if rand(100) < 4 and @fruits.size < MAX_FRUITS
        @fruits << Fruit.new(self)
      end
    rescue Snake::GameOverException
      @game_over = true
    end
  end
  
  def draw
    if @game_over
      @font.draw "GAME OVER - Score: #{@snake.size}", width / 2 - 60, height / 2, ZOrder::UI, 1, 1, 0xffffff00
    else
      @background_image.draw 0, 0, ZOrder::Background
      @snake.draw
      @fruits.each(&:draw)
      @font.draw "Score: #{@snake.size}", 10, 10, ZOrder::UI, 1, 1, 0xffffff00
    end
  end
end

class Snake
  attr_writer :direction

  class GameOverException < Exception; end

  def initialize(window)
    @window = window
    @head = SnakeHead.new @window
    @body = []

    30.times { new_body }
    
    @direction = Direction::RIGHT
    @last_direction = Direction::RIGHT
  end  
   
  def size
    @body.size
  end
  
  def grow(fruits)
    fruits.reject! do |fruit| 
      if Gosu::distance(@head.cur_x, @head.cur_y, fruit.x, fruit.y) < 5
        new_body
      end
    end
  end
  
  def new_body
    @body << SnakeBody.new(@body.last || @head, @window)
  end
 
  def update
    raise GameOverException.new if @head.cur_x > @window.width  ||
                                   @head.cur_y > @window.height ||
                                   @head.cur_x < 0 ||
                                   @head.cur_y < 0
  
    if @last_direction != @direction
      point_of_change = [[@head.cur_x, @head.cur_y], @direction]
    end
    
    @last_direction = @direction
    @head.direction = @direction
    @head.update
    
    # if the direction has changed,
    # send the body the point where there was the change
    
    @body.each do |b|
      b.push_changes(point_of_change) if point_of_change
      b.update
    end
  end
  
  def draw
    @head.draw
    @body.each(&:draw)
  end
end

class SnakeLimb
  attr_reader :direction, :last_x, :last_y, :cur_x, :cur_y, :changes
  attr_writer :step
  def initialize(window)
    @window = window
    @image = Gosu::Image.new @window, 'media/snake.png', false
    @direction = Direction::RIGHT
    # position
    @cur_x, @cur_y, @last_x, @last_y = 0,0,0,0
    
    # velocity
    @@step = 1
  end
  
  def draw
    @image.draw @cur_x - @image.width / 2.0, 
                @cur_y - @image.height / 2.0, 
                ZOrder::Snake
  end
end

class SnakeHead < SnakeLimb
  attr_writer :direction

  def initialize(window)
    super
    @image = Gosu::Image.new @window, 'media/head.png', false
    @cur_x = window.width / 2
    @cur_y = window.height / 2
  end
  
  def update

     @last_x = @cur_x
     @last_y = @cur_y
     
     # goes right
     if @direction == Direction::RIGHT
      @cur_x += @@step
     end
     
     # goes up
     if @direction == Direction::UP
      @cur_y -= @@step
     end
     
     # goes left
     if @direction == Direction::LEFT
      @cur_x -= @@step
     end     
     
     # goes down
     if @direction == Direction::DOWN
      @cur_y += @@step
     end
  end
end

class SnakeBody < SnakeLimb
  def initialize(plimb, window)
    super window 
    @plimb = plimb

    # add the new piece in the right location
    if plimb.direction == Direction::RIGHT
      @cur_x = @plimb.cur_x - @image.width - 1
      @cur_y = @plimb.cur_y
    elsif plimb.direction == Direction::LEFT
      @cur_x = @plimb.cur_x + @image.width + 1
      @cur_y = @plimb.cur_y
    elsif plimb.direction == Direction::UP
      @cur_x = @plimb.cur_x
      @cur_y = @plimb.cur_y + @image.height + 1
    elsif plimb.direction == Direction::DOWN
      @cur_x = @plimb.cur_x
      @cur_y = @plimb.cur_y - @image.height - 1
    end

    @changes = plimb.changes.dup rescue []
    @direction = plimb.direction
  end
  
  def push_changes(change)
    @changes << change
  end
  
  def update
   
    @last_x = @cur_x
    @last_y = @cur_y
    
    # goes right
    if @direction == Direction::RIGHT
      @cur_x += @@step
    end
    
    # goes up
    if @direction == Direction::UP
      @cur_y -= @@step
    end
    
    # goes left
    if @direction == Direction::LEFT
      @cur_x -= @@step
    end
    
    # goes down
    if @direction == Direction::DOWN
      @cur_y += @@step
    end

    if @changes.first && @changes.first.first == [@cur_x, @cur_y]
      change = @changes.delete_at 0
      @direction = change.last
    end
  end
end

class Fruit
  attr_reader :x, :y
  
  def initialize(window)
    @image = Gosu::Image.new window, 'media/fruit.png', false
    @x = rand * window.width
    @y = rand * window.height
  end
  
  def draw
    @image.draw @x - @image.width / 2.0, 
                @y - @image.height / 2.0,
                ZOrder::Fruit
  end
end


## Main
# Params are: Width, Height, Fullscreen
Game.new(640, 480, ARGV.first == "full").show
