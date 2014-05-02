require 'aql'
require 'brazil/document'
require 'brazil/return_statement_context'
require 'brazil/filter_statement_context'
require 'brazil/sort_statement_context'

class Query
  include AQL

  def self.for_all(variable_name, in_collection: nil)
    Query.new(in_collection, variable_name)
  end

  def initialize(collection_name, variable_name)
    @collection_name = Node::Name.new(collection_name)
    @variable_name = Node::Name.new(variable_name)
    @content = []
  end

  def and_for_all(variable_name, in_collection:)
    @content << Node::Operation::For.new(Node::Name.new(variable_name), Node::Name.new(in_collection), Node::Block.new([]))
    self
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

  def filter_by(&b)
    context = FilterStatementContext.new
    context.instance_eval(&b)
    @content << Node::Operation::Unary::Filter.new(context.to_ast)
    self
  end

  def sort_by(&b)
    context = SortStatementContext.new
    context.instance_eval(&b)
    @content << Node::Operation::Nary::Sort.new(context.to_ast)
    self
  end

  def limit(limit, offset_by: 0)
    @content << Node::Operation::Limit.new(Node::Literal.build(limit), Node::Literal.build(offset_by))
    self
  end

  def to_aql
    Node::Operation::For.new(@variable_name, @collection_name, Node::Block.new(@content)).aql
  end
end
