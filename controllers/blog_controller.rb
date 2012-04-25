require_relative "../views/blog_index_view"

class BlogController
  attr_reader :request

  def initialize(request)
    @request = request
  end

  def index
    view = BlogIndexView.new(request["name"])

    view.render_to_response
  end
end

