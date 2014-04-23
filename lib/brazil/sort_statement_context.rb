require 'aql'

class SortParameter
  include AQL

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

  def to_ast
    @direction.new(Node::Attribute.new(Node::Name.new(@name), Node::Name.new(@attribute_selector)))
  end
end

class SortStatementContext
  include AQL

  def initialize
    @sort_parameters = []
  end

  def descending(projection)
    projection.descending!
  end

  def method_missing(sort_parameter)
    sort_parameter = SortParameter.new(sort_parameter)
    @sort_parameters << sort_parameter
    sort_parameter
  end

  def to_ast
    @sort_parameters.map(&:to_ast)
  end
end
