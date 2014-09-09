# This file holds the constants and enums
# used on other files

module Direction
  LEFT = :left
  RIGHT = :right
  UP = :up
  DOWN = :down
end

module ZOrder
  Background, Fruit, Snake, UI = *0..3
end

module Media
  def media_path(media)
    File.join(File.dirname(__FILE__), '../media', media)
  end
end
