module Brazil
  class Query
    def initialize
      @where_statements = []
      @joins = []
      @geo_statements = []
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
      
      return self
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
      
      return self
    end
    
    def find_by_geocoordinates(geo_statements)
      raise "no reference point was assigned" unless geo_statements.has_key? :reference
      
      unless geo_statements[:attributes]
        geo_statements[:attributes] = ["#{@collection_alias}.x", "#{@collection_alias}.y"]
      end
      
      if geo_statements.has_key? :radius
        raise "you can't add maximum and radius at once" if geo_statements.has_key? :maximum
        @geo_statements << "WITHIN [#{geo_statements[:attributes].first}, #{geo_statements[:attributes].last}], #{geo_statements[:reference]}, #{geo_statements[:radius]}"
      elsif geo_statements.has_key? :maximum
        @geo_statements << "NEAR [#{geo_statements[:attributes].first}, #{geo_statements[:attributes].last}], #{geo_statements[:reference]}, #{geo_statements[:maximum]}"
      else
        raise "neither a radius nor a maximum was given" 
      end
      
      return self
    end
    
    def evaluate
      raise "From statement was not provided" if @collection_name.nil? or @collection_alias.nil?
      evaluation = "SELECT #{@collection_alias} FROM #{@collection_name} #{@collection_alias}"
      @joins.each { |join| evaluation += " #{join[:type].upcase} JOIN #{join[:right_collection]} ON #{join[:on]}" }
      evaluation += " WHERE #{@where_statements.join ' && '}" if @where_statements.length > 0
      evaluation += " ORDER BY #{@order_statements.join ', '}" if @order_statements
      evaluation += " LIMIT #{@limit_statement}" if @limit_statement
      @geo_statements.each { |geo_statement| evaluation += " #{geo_statement}"}
      
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