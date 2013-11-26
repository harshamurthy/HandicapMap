class DirectionsController < ApplicationController
  def landing_page
  end

  def route
    @direction = Direction.new
    @direction.start = params[:start]
    @direction.destination = params[:destination]

    if @direction.start.present? && @direction.destination.present?
      @routes = @direction.accessible?
      render 'route'
    else
      redirect_to root_url, notice: 'Please make sure both fields are properly completed.'
    end
  end

end
