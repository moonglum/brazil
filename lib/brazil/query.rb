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
    
    def order(*order_statements)
      raise "order statement already added" unless @order_statements.nil?
      @order_statements = order_statements
    end
    
    def limit(limit_statements)
      raise "limit statement already added" unless @limit_statement.nil?
      
      if limit_statements.has_key? :maximum
        raise "either use maximum or from and to" if limit_statements.has_key? :from or limit_statements.has_key? :to
        @limit_statement = limit_statements[:maximum]
      elsif limit_statements.has_key? :from and limit_statements.has_key? :to
        @limit_statement = "#{limit_statements[:from]}, #{limit_statements[:to]}"
      else
        raise "neither maximum nor from and to are declared" 
      end
    end
    
    def evaluate
      raise "From statement was not provided" if @collection_name.nil? or @collection_alias.nil?
      evaluation = "SELECT #{@collection_alias} FROM #{@collection_name} #{@collection_alias}"
      @joins.each do |join|
        evaluation += " #{join[:type].upcase} JOIN #{join[:right_collection]} ON #{join[:on]}" 
      end
      evaluation += " WHERE #{@where_statements.join ' && '}" if @where_statements.length > 0
      evaluation += " ORDER BY #{@order_statements.join ', '}" if @order_statements
      evaluation += " LIMIT #{@limit_statement}" if @limit_statement
      
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