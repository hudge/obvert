require File.expand_path("../obvert", __FILE__)
require File.expand_path("../controllers/blog_controller", __FILE__)

class Blog < Obvert::Application
  def dispatcher
    {
      "/"      => proc { |request| BlogController.new(request).index },
      %r{/wo+} => proc { |request| BlogController.new(request).woo }
    }
  end
end

