module Brazil
  class Query
    def initialize
      @where_statements = []
      @joins = []
    end
    
    def from(from_statement)
      from_statement = from_statement.to_s
      raise "Misformed From Statement" unless from_statement.match(/\w+ \w+/)
      raise "From statement already provided" unless @collection_name.nil? and @collection_alias.nil?
      
      @collection_name, @collection_alias = from_statement.scan(/(\w+) (\w+)/).first
      
      return self
    end
    
    def where(where_statement)
      @where_statements << where_statement
      
      return self
    end
    
    def left_join(right_collection, argument_hash)
      join("left", right_collection, argument_hash)
    end
    
    def right_join(right_collection, argument_hash)
      join("right", right_collection, argument_hash)
    end
    
    def inner_join(right_collection, argument_hash)
      join("inner", right_collection, argument_hash)
    end
    
    def evaluate
      raise "From statement was not provided" if @collection_name.nil? or @collection_alias.nil?
      evaluation = "SELECT #{@collection_alias} FROM #{@collection_name} #{@collection_alias}"
      @joins.each do |join|
        evaluation += " #{join[:type].upcase} JOIN #{join[:right_collection]} ON #{join[:on]}" 
      end
      evaluation += " WHERE #{@where_statements.join ' && '}" if @where_statements.length > 0
      
      return evaluation
    end
    
    private
    
    def join(type, right_collection, argument_hash)
      raise "on statement missing" unless argument_hash.class == Hash and argument_hash.has_key? :on
      @joins << {type: type, right_collection: right_collection, on: argument_hash[:on]}
      
      return self
    end
  end
end