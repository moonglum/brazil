require 'aql'

class SortParameter
  include AQL

  attr_reader :name
  attr_reader :attribute_selector
  attr_reader :direction

  def initialize(name)
    @name = name
    @direction = Node::Operation::Unary::Direction::Ascending
  end

  def descending!
    @direction = Node::Operation::Unary::Direction::Descending
  end

  def [](attribute_selector)
    @attribute_selector = attribute_selector
    self
  end
end

class SortStatementContext
  include AQL

  def descending(projection)
    projection.descending!
  end

  def method_missing(sort_parameter)
    @sort_parameter = SortParameter.new(sort_parameter)
  end

  def to_ast
    foo = Node::Attribute.new(Node::Name.new(@sort_parameter.name), Node::Name.new(@sort_parameter.attribute_selector))
    direction = @sort_parameter.direction.new(foo)
    [direction]
  end
end
