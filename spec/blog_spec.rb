require "rack/test"
require File.expand_path("../../blog", __FILE__)

describe Blog do
  include Rack::Test::Methods

  def app
    Blog.new
  end

  it "greets the user by name" do
    get "/?name=Bob"
    last_response.body.should include("Bob")
  end

  it "greets the user as John Doe by default" do
    get "/"
    last_response.body.should include("John Doe")
  end

  it "supports regular expression routes" do
    get "/woooo"
    last_response.body.should include("And a woooo to you too!")
  end
end
