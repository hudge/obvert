require "rack"

class BlogWooView
  def self.render_to_response
    Rack::Response.new("And a woooo to you too!")
  end
end
