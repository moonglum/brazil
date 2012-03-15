module Brazil
  class Query
    
    def from(from_statement)
      from_statement = from_statement.to_s
      raise "Misformed From Statement" unless from_statement.match(/\w+ \w+/)
      raise "From statement already provided" unless @collection_name.nil? and @collection_alias.nil?
      
      @collection_name, @collection_alias = from_statement.scan(/(\w+) (\w+)/).first
      
      return self
    end
    
    def evaluate
      raise "From statement was not provided" if @collection_name.nil? or @collection_alias.nil?
      return "SELECT #{@collection_alias} FROM #{@collection_name} #{@collection_alias}"
    end
  end
end