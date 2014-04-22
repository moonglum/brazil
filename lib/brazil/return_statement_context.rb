class Projection
  def initialize(name)
    @name = name
  end

  def method_missing(attribute_selector)
    [@name, attribute_selector]
  end
end

class ReturnStatementContext
  def method_missing(projection_name)
    Projection.new(projection_name)
  end
end
