require_relative "obvert"
require_relative "controllers/blog_controller"

class Blog < Obvert::Application
  def dispatcher
    {
      "/" => BlogController.instance_method(:index)
    }
  end
end

