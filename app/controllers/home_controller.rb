class HomeController < ApplicationController
  def index
    render plain: "Hello from Rails on ECS!"
  end
end
