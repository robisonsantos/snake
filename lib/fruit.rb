require 'gosu'
require_relative 'consts.rb'

module Fruit
  def self.get_instance(window)
    # 12% chance of getting a 2x fruit
    #  8% chance of getting a /2 fruit
    # 20% chance of getting a special fruit
    # 60% chance of getting a normal fruit
    chance = rand(100)
    return SuperDoubleFruit.new(window, 7500) if (0...12).member? chance
    return SuperHalfFruit.new(window, 7500) if (12...20).member? chance
    return SpecialFruit.new(window) if (20...40).member? chance

    NormalFruit.new(window)
  end

  class AbstractFruit
    def initialize(window)
      @x = rand * window.width
      @y = rand * window.height
    end

    def expired?
      false
    end
    
    def play
      @sound.play
    end
    
    def draw
      @image.draw @x - @image.width / 2.0,
                  @y - @image.height / 2.0,
                  ZOrder::Fruit
    end
  end

  class SuperDoubleFruit < AbstractFruit
    attr_reader :x, :y, :score

    def initialize(window, timeout)
      super(window)
      @image = Gosu::Image.new window, '../media/double_fruit.png', false
      @score = 5
      @created_at = Gosu::milliseconds
      @timeout = timeout
      @sound = Gosu::Sample.new window, '../media/smb_vine.wav'
    end
    
    def expired?
      (Gosu::milliseconds - @created_at) > @timeout
    end
  end

  class SuperHalfFruit < AbstractFruit
    attr_reader :x, :y, :score
    
    def initialize(window, timeout)
      super(window)
      @image = Gosu::Image.new window, '../media/half_fruit.png', false
      @score = 5
      @created_at = Gosu::milliseconds
      @timeout = timeout
      @sound = Gosu::Sample.new window, '../media/smb_pipe.wav'
    end

    def expired?
      (Gosu::milliseconds - @created_at) > @timeout
    end
  end

  class SpecialFruit < AbstractFruit
    attr_reader :x, :y, :score
    
    def initialize(window)
      super
      @image = Gosu::Image.new window, '../media/chery.png', false
      @score = 3
      @sound = Gosu::Sample.new window, '../media/smb_1-up.wav'
    end
  end

  class NormalFruit < AbstractFruit
    attr_reader :x, :y, :score

    def initialize(window)
      super
      @image = Gosu::Image.new window, '../media/fruit.png', false
      @score = 1
      @sound = Gosu::Sample.new window, '../media/smb_coin.wav'
    end
  end
end
