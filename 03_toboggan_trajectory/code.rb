Slope = Struct.new(:right, :down)
Position = Struct.new(:row, :column)

class Cursor
  attr_reader :position

  def initialize
    @position = Position.new(1, 1)
  end

  def move(slope)
    row = position.row + slope.down
    column = position.column + slope.right
    @position = Position.new(row, column)
  end
end

class Map
  attr_reader :pattern

  def initialize(pattern)
    @pattern = pattern
  end

  def content_on(position)
    if content = raw_content_on(position)
      Content.new(content)
    else
      extend_pattern!
      content_on(position)
    end
  end

  def bottom?(position)
    pattern.count == position.row
  end

  private

  def raw_content_on(position)
    pattern[position.row - 1][position.column - 1]
  end

  def extend_pattern!
    @pattern = pattern.map { |row| row.concat(row) }
  end
end

class Content
  def initialize(representation)
    @representation = representation
  end

  def tree?
    @representation == "#"
  end
end

class Trajectory
  attr_reader :map, :slope, :positions, :contents

  def initialize(map, slope)
    @map = map
    @slope = slope
    @positions = calculate_positions
    @contents = positions.map { |position| map.content_on(position) }
  end

  def trees_count
    contents.count(&:tree?)
  end

  private

  def calculate_positions(positions = [], cursor = Cursor.new)
    return positions if map.bottom?(cursor.position)
    cursor.move(slope)
    positions << cursor.position
    calculate_positions(positions, cursor)
  end
end

pattern = File.read("input.txt").lines.map(&:chomp)
map = Map.new(pattern)
slope = Slope.new(3, 1)
trajectory = Trajectory.new(map, slope)
puts trajectory.trees_count

puts "........................."

map = Map.new(pattern)
slopes = [
  Slope.new(1, 1),
  Slope.new(3, 1),
  Slope.new(5, 1),
  Slope.new(7, 1),
  Slope.new(1, 2)
]
trajectories = slopes.map { |slope| Trajectory.new(map, slope) }
counts = trajectories.map(&:trees_count)
puts counts
puts counts.reduce(&:*)
