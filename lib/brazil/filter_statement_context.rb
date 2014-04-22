require 'aql'

class Attribute
  include AQL
  attr_reader :operator

  def initialize(bound_variable, attribute_name)
    @attribute = Node::Attribute.new(Node::Name.new(bound_variable.variable_name), Node::Name.new(attribute_name))
  end

  def ==(val)
    @operator = Node::Operator::Binary::Equality.new(
      @attribute,
      Node::Literal::Primitive::String.new(val)
    )
  end
end

class BoundVariable
  attr_reader :variable_name

  def initialize(variable_name)
    @variable_name = variable_name
  end

  def [](attribute_name)
    @attribute = Attribute.new(self, attribute_name)
  end

  def to_ast
    @attribute.operator
  end
end

class FilterStatementContext
  # Inject known variables as BoundVariables, raise error for others
  def method_missing(identifier_name)
    @statement = BoundVariable.new(identifier_name)
  end

  def to_ast
    @statement.to_ast
  end
end
