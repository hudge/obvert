require File.expand_path("../../views/blog_index_view", __FILE__)
require File.expand_path("../../views/blog_woo_view", __FILE__)

class BlogController
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def index
    view = BlogIndexView.new(request["name"])

    view.render_to_response
  end

  def woo
    BlogWooView.render_to_response
  end
end

