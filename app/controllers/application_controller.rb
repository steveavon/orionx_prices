require 'uri'
require 'date'
require 'json'
require 'openssl'
require 'net/http'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

	def market_history(currency, aggregation)
	  uri = URI.parse('https://api2.orionx.io/graphql')

		http = Net::HTTP.new(uri.host, uri.port)

		request = Net::HTTP::Post.new(uri.path)

		http.use_ssl = true

		query_str = '
			query getMarketStats($marketCode: ID!, $aggregation: MarketStatsAggregation!) {
				marketStats(marketCode: $marketCode, aggregation: $aggregation) {
					_id
					open
					close
					high
					low
					volume
					count
					fromDate
					toDate
					__typename
				}
			}
		'

		variables = {
		  'marketCode': "#{currency}",

		  'aggregation': "#{aggregation}"
		}

		query = {
			'query': query_str,

			'variables': variables
		}

		request.body = query.to_json

		request.body.gsub!(/\\t/, '')

		digest = OpenSSL::Digest.new('sha512')

		time_stamp = (DateTime.now.strftime('%Q').to_f / 1000)

		secret_key = "QzFnLfkgGao7iKsReGHhGGfTuNBH6e5f3n"

		hmac = OpenSSL::HMAC.hexdigest(digest, secret_key, time_stamp.to_s + request.body.gsub(/\\t/, ''))

		request['Content-Type'] = 'application/json'
		request['X-ORIONX-TIMESTAMP'] = time_stamp
		request['X-ORIONX-APIKEY'] = "GXYiMaZXNYDceaykZskqLCDsXiYLp5MDxE"
		request['X-ORIONX-SIGNATURE'] = hmac

		response = http.request(request)

		data = JSON.parse(response.body)['data']['marketStats']

		index = 0

		(0..data.length - 1).each { |i|
			if !data[i]['close']
				index += 1
			else
				break
			end
		}

		price = []
		vol = []

		data[index..data.length - 1].each_with_index { |record, index|
			date = Time.at(record['fromDate'] * 0.001).strftime('%FT%T')

			if !record['close']
				close_price = price.last[1]
			else
				close_price = record['close']
			end

			volume = (record['volume'] * 0.00000001)

			vol.push([date, volume])
			price.push([date, close_price])
		}

		return price, vol
	end

	def vol_chart(price, vol)
		obv = []

		obv.push([vol[0][0], vol[0][1].round(1)])

		(1..vol.length - 1).each { |i|
			chg = price[i][1] - price[i - 1][1]

			if chg > 0
				obv.push([price[i][0], (obv.last[1] + vol[i][1]).round(1)])
			elsif chg < 0
				obv.push([price[i][0], (obv.last[1] - vol[i][1]).round(1)])
			else
				obv.push([price[i][0], (obv.last[1]).round(1)])
			end
		}

		return obv
	end

	def chart_data(price)
		values = price.map { |row| row[1] }

		min = values.min
		max = values.max

		price_min = min - (max - min) * 0.2
		price_max = max + (max - min) * 0.2

		return price, price_min, price_max
	end

	def sma(price, step)
		values = price.map { |row| row[1] }

		sma = []

		values.each_with_index { |value, index|
			if (index < step)
					sma.push([price[index][0], nil])
			else
				tmp_array = values[index - step .. index - 1]

				avg = tmp_array.inject{ |sum, el| sum + el }.to_f / tmp_array.size

				sma.push([price[index][0], avg])
			end
		}

		min = values.min
		max = values.max

		price_min = min - (max - min) * 0.2
		price_max = max + (max - min) * 0.2

		return sma, price_min, price_max
	end

	def rsi(price)
		values = price.map { |row| row[1] }

		up = []

		down = []

		(0..values.length - 2).each do |i|
			chg = values[i + 1] - values[i]

			if (chg > 0)
				up.push(chg)
				down.push(0)
			elsif (chg < 0)
				down.push(-chg)
				up.push(0)
			else
				up.push(0)
				down.push(0)
			end
		end

		tmp_up = up.last(14)
		tmp_down = down.last(14)

		avgU = tmp_up.inject{ |sum, el| sum + el }.to_f / tmp_up.size
		avgD = tmp_down.inject{ |sum, el| sum + el }.to_f / tmp_down.size

		rs = avgU / avgD

		rsi = 100 - 100 / (1 + rs)

		return rsi
	end
end
