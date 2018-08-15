class HomeController < ApplicationController
	include OrionxApi
	include PriceStatistics
	include GetPrices
	
	def prices
		@currency = if params[:currency] then params[:currency] else 'BTCCLP' end
		@aggregation = if params[:aggregation] then params[:aggregation] else 'h1' end
		@sma_periods = if params[:sma_periods] then params[:sma_periods] else 8 end

		@crypto_short_name = @currency.chomp("CLP")

		crypto_internacional_usd_price_tmp = GetPrices.get_crypto_price_in_usd(@crypto_short_name)

		@crypto_internacional_usd_price = Functionalities.get_proper_round(crypto_internacional_usd_price_tmp)

		@usd_value_in_clp = GetPrices.get_usd_value_in_clp(@crypto_short_name)

	  historic_price, historic_vol = OrionxApi.market_history(@currency, @aggregation)

	  @rsi = PriceStatistics.rsi(historic_price)

	  if (historic_price.length > 0) and (historic_vol.length > 0)
		  @on_balance_volume = PriceStatistics.get_on_balance_volume(historic_price, historic_vol, @sma_periods.to_i)

		  @chart_price_data, @min, @max = PriceStatistics.chart_data(historic_price, @sma_periods.to_i)

		  @sma = PriceStatistics.sma(historic_price, @sma_periods.to_i)
		end
	end
end