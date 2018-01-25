require 'date'
require 'json'
require 'net/http'

class HomeController < ApplicationController
	def index
	end

	def prices
  	#begin
	  	if params[:currency]
	  		currency = params[:currency]
	  	else
	  		currency = 'XRPCLP'
	  	end

	  	if params[:aggregation]
	  		aggregation = params[:aggregation]
	  	else
	  		aggregation = 'd1'
	  	end

	  	response = market_history(currency, aggregation)

	  	@chart, @min, @max = chart_data(response)

	  	@sma_3, @min, @max = sma(response, 3)

	  	@sma_10, @min, @max = sma(response, 10)
	  #rescue Exception => e
	    #logger.info('Error: ' + e.message)

	    #@chart = nil
	  #end
	end
end





