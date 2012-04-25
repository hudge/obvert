require "rack"

module Obvert
  class Application
    def call(env)
      request = Rack::Request.new(env)
      dispatch_to(request.path, request)
    end

    def dispatch_to(path, request)
      _, action = dispatcher.find { |route, _| route === request.path }

      if action
        action.bind(action.owner.new(request)).call
      else
        Rack::Response.new('Page not found', 404, "Content-Type" => "text/plain")
      end
    rescue => e
      Rack::Response.new(e.message, 500, "Content-Type" => "text/plain")
    end

    def dispatcher
      {}
    end
  end
end

class Blog < Obvert::Application
  def dispatcher
    {
      "/" => BlogController.instance_method(:index)
    }
  end
end

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

class BlogIndexView
  attr_reader :name

  def initialize(name)
    @name = name || "John Doe"
  end

  def render_to_response
    Rack::Response.new("Hey there, #{name}")
  end
end
