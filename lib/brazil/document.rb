require 'aql'

class Document
  include AQL

  def initialize
    @attributes = {}
  end

  def []=(attribute_name, document_selector)
    @attributes[attribute_name] = document_selector
  end

  def to_ast
    Node::Literal::Primitive::Composed::Document.new(@attributes.map do |key, value|
      val = Node::Attribute.new(Node::Name.new(value.first), Node::Name.new(value.last))
      Node::Literal::Composed::Document::Attribute.new(Node::Name.new(key), val)
    end)
  end
end

