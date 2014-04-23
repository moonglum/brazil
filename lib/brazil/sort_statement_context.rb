require 'aql'
require 'brazil/projection'

class SortStatementContext
  include AQL

  def method_missing(projection_name)
    @projection = Projection.new(projection_name)
  end

  def to_ast
    foo = Node::Attribute.new(Node::Name.new(@projection.name), Node::Name.new(@projection.attribute_selector))
    direction = Node::Operation::Unary::Direction::Ascending.new(foo)
    [direction]
  end
end
