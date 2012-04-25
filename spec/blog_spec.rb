require "rack/test"
require_relative "../blog"

describe Blog do
  include Rack::Test::Methods

  def app
    Blog.new
  end

  it "greets the user by name" do
    get "/", name: "Bob"
    last_response.body.should include("Bob")
  end

  it "greets the user as John Doe by default" do
    get "/"
    last_response.body.should include("John Doe")
  end
end
