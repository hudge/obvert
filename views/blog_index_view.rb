require "rack"

class BlogIndexView
  attr_reader :name

  def initialize(name)
    @name = name || "John Doe"
  end

  def render_to_response
    Rack::Response.new("Hey there, #{name}")
  end
end
