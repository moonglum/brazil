require 'aql'
require 'brazil/document'
require 'brazil/return_statement_context'

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

  def return_as(variable_name = nil, &b)
    if block_given? and variable_name == nil
      document = Document.new
      context = ReturnStatementContext.new
      context.instance_exec(document, &b)
      @content << Node::Operation::Unary::Return.new(document.to_ast)
    else
      @content << Node::Operation::Unary::Return.new(Node::Name.new(variable_name))
    end
    self
  end

  def to_aql
    Node::Operation::For.new(@variable_name, @collection_name, Node::Block.new(@content)).aql
  end
end
