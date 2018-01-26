require 'date'
require 'json'
require 'net/http'

class HomeController < ApplicationController
	def prices
  	begin
	  	if params[:currency]
	  		@currency = params[:currency]
	  	else
	  		@currency = 'BTCCLP'
	  	end

	  	if params[:aggregation]
	  		@aggregation = params[:aggregation]
	  	else
	  		@aggregation = 'h1'
	  	end

	  	if params[:sma_periods]
	  		@sma_periods = params[:sma_periods]
	  	else
	  		@sma_periods = 3
	  	end

	  	response = market_history(@currency, @aggregation)

	  	@chart, min, max = chart_data(response)

	  	@sma, min_sma, max_sma = sma(response, @sma_periods.to_i)

	  	@min = [min, min_sma].min
	  	@max = [max, max_sma].max
	  rescue Exception => e
	    logger.info('Error: ' + e.message)

	    @chart = nil
	  end
	end
end





