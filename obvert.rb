require "rack"

module Obvert
  class Application
    def call(env)
      request = Rack::Request.new(env)
      dispatch_to(request.path, request)
    end

    def dispatcher
      {}
    end

    private

    def dispatch_to(path, request)
      _, action = dispatcher.find { |route, _| route === request.path }

      if action
        action.bind(action.owner.new(request)).call
      else
        not_found
      end
    rescue => exception
      server_error(exception)
    end

    def server_error(exception)
      Rack::Response.new([exception.message, *exception.backtrace].join("\n"),
                         500, "Content-Type" => "text/plain")
    end

    def not_found
      Rack::Response.new("Page not found", 404, "Content-Type" => "text/plain")
    end
  end
end

