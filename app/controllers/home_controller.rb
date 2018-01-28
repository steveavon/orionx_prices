require 'date'
require 'json'
require 'net/http'

class HomeController < ApplicationController
	def prices
  	#begin
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

	  	price, vol = market_history(@currency, @aggregation)

	  	@rsi = rsi(price)

	  	@vol = vol_chart(price, vol)

	  	@chart, min, max = chart_data(price)

	  	@sma, min_sma, max_sma = sma(price, @sma_periods.to_i)

	  	tmp_min = [min, min_sma].min
	  	tmp_max = [max, max_sma].max

	  	@min = tmp_min - tmp_min * 0.005
	  	@max = tmp_max + tmp_max * 0.005
	  #rescue Exception => e
	    #logger.info('Error: ' + e.message)

	    #@chart = nil
	  #end
	end
end





