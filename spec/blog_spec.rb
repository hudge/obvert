require "rack/test"
require "rack"
require "mustache"

module Obvert

  def call(env)
    request = Rack::Request.new(env)

    action, arguments = dispatch(request)

    if action
      action.call(*arguments)
    else
      not_found
    end
  rescue => exception
    server_error(exception)
  end

  def dispatch(request)
    arguments = []

    _, action = routes.find { |(pattern, _)|
      case pattern
      when Regexp
        match = pattern.match(request.path)
        arguments = match.captures if match

        match
      else
        pattern == request.path
      end
    }

    [action, arguments] if action
  end

  def render_to_response(template_path, context)
    Rack::Response.new(Mustache.render(File.read(template_path), context))
  end

  def not_found
    Rack::Response.new("Not Found", 404)
  end

  def server_error(exception)
    Rack::Response.new(<<ERROR, 500, "Content-Type" => "text/plain")
Internal Server Error
#{exception.inspect}
#{exception.backtrace.join("\n")}
ERROR
  end

  def add_route(pattern, &blk)
    routes << [pattern, blk]
  end

  def routes
    @routes ||= []
  end
end

module Blog
  extend self, Obvert

  add_route("/")                { render_home_page }
  add_route(%r{/posts/([^/]+)}) { |id| find_and_render_post(id) }
  add_route("/broken")          { some_broken_code }

  def render_home_page
    render_to_response('templates/index.mustache', posts: posts)
  end

  def find_and_render_post(id)
    post = posts.find { |p| p.id == id }

    render_to_response('templates/post.mustache', post: post)
  end

  def posts
    @posts ||= []
  end

  def publish(post)
    posts << post
  end
end

class Post
  attr_reader :id, :title, :body

  def initialize(attributes)
    @id    = attributes.fetch(:id)
    @title = attributes.fetch(:title)
    @body  = attributes.fetch(:body)
  end
end

describe "A blog web application" do
  include Rack::Test::Methods

  def app
    Blog
  end

  before do
    Blog.publish(Post.new(id: "title-1", body: "Foo", title: "Title 1"))
    Blog.publish(Post.new(id: "title-2", body: "Foo", title: "Title 2"))
    Blog.publish(Post.new(id: "title-3", body: "Foo", title: "Title 3"))
  end

  describe "loading the home page" do
    before do
      get "/"
    end

    it "successfully returns a response" do
      last_response.should be_ok
    end

    it "returns an HTML page" do
      last_response.content_type.should == "text/html"
    end

    it "lists the entries" do
      last_response.body.should include("Title 1", "Title 2", "Title 3")
    end
  end

  describe "loading a post by ID" do
    before do
      get "/posts/title-1"
    end

    it "successfully returns a response" do
      last_response.should be_ok
    end

    it "contains the post title" do
      last_response.body.should include("<h1>Title 1</h1>")
    end

    it "contains the post body" do
      last_response.body.should include("Foo")
    end

    it "returns an HTML page" do
      last_response.content_type.should == "text/html"
    end
  end

  describe "accessing a missing route" do
    it "returns a 404" do
      get "/nonexistent"
      last_response.status.should == 404
    end
  end

  describe "accessing an error" do
    before do
      get "/broken"
    end

    it "returns a 500" do
      last_response.status.should == 500
    end

    it "contains the exception raised" do
      last_response.body.should include("NameError: undefined local variable or method")
    end

    it "contains the backtrace" do
      last_response.body.should include(":in")
    end

    it "responds in plain text" do
      last_response.content_type.should == "text/plain"
    end
  end
end
