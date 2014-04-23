require 'aql'

class Document
  include AQL

  def initialize
    @attributes = {}
  end

  def []=(attribute_name, right_side)
    @attributes[attribute_name] = right_side
  end

  def to_ast
    Node::Literal::Primitive::Composed::Document.new(@attributes.map do |key, value|
      Node::Literal::Composed::Document::Attribute.new(Node::Name.new(key), handle_right_side(value))
    end)
  end

  private

  def handle_right_side(right_side)
    if right_side.class == Array
      Node::Attribute.new(Node::Name.new(right_side.first), Node::Name.new(right_side.last))
    else
      Node::Literal::Primitive::String.new(right_side)
    end
  end
end

