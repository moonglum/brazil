require 'aql'

class Query
  include AQL

  def self.for_all(variable_name, in_collection: nil)
    query = Query.new(in_collection, variable_name)
  end

  def initialize(collection_name, variable_name)
    @collection_name = Node::Name.new(collection_name)
    @variable_name = Node::Name.new(variable_name)
    @content = []
  end

  def return_as(variable_name)
    @content << Node::Operation::Unary::Return.new(Node::Name.new(variable_name))
    self
  end

  def to_aql
    Node::Operation::For.new(@variable_name, @collection_name, Node::Block.new(@content)).aql
  end
end
