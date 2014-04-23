class Projection
  attr_reader :name
  attr_reader :attribute_selector

  def initialize(name)
    @name = name
  end

  def [](attribute_selector)
    @attribute_selector = attribute_selector
    [@name, attribute_selector]
  end
end
