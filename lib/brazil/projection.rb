class Projection
  def initialize(name)
    @name = name
  end

  def [](attribute_selector)
    [@name, attribute_selector]
  end
end
