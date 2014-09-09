require 'gosu'
require_relative 'consts.rb'
require_relative 'fruit.rb'

class Snake
  attr_writer :direction
  attr_reader :score

  class GameOverException < Exception; end

  def initialize(window)
    @window = window
    @head = SnakeHead.new @window
    @body = []

    @direction = Direction::RIGHT
    @last_direction = Direction::RIGHT
    @score = 0
  end  
   
  def grow(fruits)
    fruits.reject! do |fruit| 
      if Gosu::distance(@head.cur_x, @head.cur_y, fruit.x, fruit.y) < 10
        fruit.play
        @score += fruit.score

        if fruit.is_a? Fruit::SuperHalfFruit
          @body.pop(@body.size / 2)
        elsif fruit.is_a? Fruit::SuperDoubleFruit
          @body.size.times { new_body }
        else
          fruit.score.times { new_body }
        end
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
                                   @head.cur_y < 0 ||
                                   @head.colision?(@body)
  
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
  include Media
  attr_reader :direction, :last_x, :last_y, 
              :cur_x, :cur_y, :changes
  attr_writer :step
 
  def initialize(window)
    @window = window
    @image = Gosu::Image.new @window, media_path('snake.png'), false
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
    @image = Gosu::Image.new @window, media_path('head.png'), false
    @cur_x = window.width / 2
    @cur_y = window.height / 2
  end
  
  def update
    @last_x = @cur_x
    @last_y = @cur_y
   
    case @direction
      when Direction::RIGHT
        @cur_x += @@step
      when Direction::UP
        @cur_y -= @@step
      when Direction::LEFT
       @cur_x -= @@step
      when Direction::DOWN
       @cur_y += @@step
    end
  end
  
  def colision?(body)
    body.any? { |b| Gosu::distance(@cur_x, @cur_y, b.cur_x, b.cur_y) < 5 }
  end
end

class SnakeBody < SnakeLimb
  def initialize(plimb, window)
    super window 
    @plimb = plimb

    case plimb.direction
      # add the new piece in the right location
      when  Direction::RIGHT
        @cur_x = @plimb.cur_x - @image.width - 1
        @cur_y = @plimb.cur_y
      when  Direction::LEFT
        @cur_x = @plimb.cur_x + @image.width + 1
        @cur_y = @plimb.cur_y
      when  Direction::UP
        @cur_x = @plimb.cur_x
        @cur_y = @plimb.cur_y + @image.height + 1
      when  Direction::DOWN
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

    case @direction
      when Direction::RIGHT
        @cur_x += @@step
      when Direction::UP
        @cur_y -= @@step
      when Direction::LEFT
        @cur_x -= @@step
      when Direction::DOWN
        @cur_y += @@step
    end

    if @changes.first && @changes.first.first == [@cur_x, @cur_y]
      change = @changes.delete_at 0
      @direction = change.last
    end
  end
end
