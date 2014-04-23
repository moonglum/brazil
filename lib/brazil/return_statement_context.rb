require 'brazil/projection'

class ReturnStatementContext
  def method_missing(projection_name)
    Projection.new(projection_name)
  end
end
