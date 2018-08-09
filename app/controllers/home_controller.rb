class HomeController < ApplicationController
	include OrionxApi
	include PriceStatistics
	include GetPrices
	
	def prices
		@currency = if params[:currency] then params[:currency] else 'BTCCLP' end
		@aggregation = if params[:aggregation] then params[:aggregation] else 'h1' end
		@sma_periods = if params[:sma_periods] then params[:sma_periods] else 3 end

		@crypto_short_name = @currency.chomp("CLP")

		usd_internacional_price_tmp = get_crypto_price(@crypto_short_name)

		@usd_internacional_price = case usd_internacional_price_tmp 
			when 0..1 then usd_internacional_price_tmp.round(3)
			when 1..10 then usd_internacional_price_tmp.round(2)
			when 10..100 then usd_internacional_price_tmp.round(1)
			else usd_internacional_price_tmp.round(0)
		end

		@usd_in_clp = get_usd_in_clp(@crypto_short_name)

	  historic_price, historic_vol = market_history(@currency, @aggregation)

	  @rsi = rsi(historic_price)

	  if (historic_price.length > 0) and (historic_vol.length > 0)
		  @vol = vol_data_for_chart(historic_price, historic_vol, @sma_periods.to_i)

		  @chart, min, max = chart_data(historic_price, @sma_periods.to_i)

		  @sma, min_sma, max_sma = sma(historic_price, @sma_periods.to_i)

		  tmp_min = [min, min_sma].min
		  tmp_max = [max, max_sma].max

		  @min = tmp_min - tmp_min * 0.005
		  @max = tmp_max + tmp_max * 0.005
		end
	end
	
	def app
	end
end