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

		time_stamp = (DateTime.now.strftime('%Q').to_f / 1000).round(2)

		secret_key = "QzFnLfkgGao7iKsReGHhGGfTuNBH6e5f3n"

		hmac = OpenSSL::HMAC.hexdigest(digest, secret_key, time_stamp.to_s + request.body.gsub(/\\t/, ''))

		request['Content-Type'] = 'application/json'
		request['X-ORIONX-TIMESTAMP'] = time_stamp
		request['X-ORIONX-APIKEY'] = "GXYiMaZXNYDceaykZskqLCDsXiYLp5MDxE"
		request['X-ORIONX-SIGNATURE'] = hmac

		response = http.request(request)

		return JSON.parse(response.body)
	end

	def vol_chart(response)
		vol = []
		obv = []
		price = []

		data = response['data']['marketStats']

		data.each_with_index { |record, index|
			date = Time.at(record['fromDate'] * 0.001).strftime('%FT%T')

			if !record['close'] and index != 0
				volume = vol.last[1]
				close_price = price.last[1]
			else
				volume = (record['volume'] * 0.00000001).round(1)
				close_price = record['close']
			end

			vol.push([date, volume])
			price.push([date, close_price])
		}

		obv.push(vol.first)

		(1..vol.length - 1).each { |i|
			chg = price[i][1] - price[i-1][1]

			if chg > 0
				obv.push([price[i][0], obv.last[1] + vol[i][1]])
			elsif chg < 0
				obv.push([price[i][0], obv.last[1] - vol[i][1]])
			else
				obv.push([price[i][0], obv.last[1]])
			end
		}

		return obv
	end

	def chart_data(response)
		chart = []

		data = response['data']['marketStats']

		data.each_with_index { |record, index|
			date = Time.at(record['fromDate'] * 0.001).strftime('%FT%T')

			if !record['close'] and index != 0
				close_price = chart.last[1]
			else
				close_price = record['close']
			end

			chart.push([date, close_price])
		}

		values = chart.map { |row| row[1] }

		min = values.compact.min
		max = values.compact.max

		chart_min = min - (max - min) * 0.2
		chart_max = max + (max - min) * 0.2

		return chart, chart_min, chart_max
	end

	def sma(response, step)
		chart = []

		data = response['data']['marketStats']

		data.each_with_index { |record, index|
			date = Time.at(record['fromDate'] * 0.001).strftime('%FT%T')

			if !record['close'] and index != 0
				close_price = chart.last[1]
			else
				close_price = record['close']
			end

			chart.push([date, close_price])
		}

		values = chart.map { |row| row[1] }

		sma = []

		values.each_with_index { |value, index|
			if (index < step)
					sma.push(nil)
			else
				tmp_array = values[index - step .. index - 1].compact

				avg = tmp_array.inject{ |sum, el| sum + el }.to_f / tmp_array.size

				sma.push(avg)
			end
		}

		chart.each_with_index { |record, index|
			record[1] = sma[index]
		}

		min = values.compact.min
		max = values.compact.max

		chart_min = min - (max - min) * 0.2
		chart_max = max + (max - min) * 0.2

		return chart, chart_min, chart_max
	end

	def rsi(response)
		chart = []

		data = response['data']['marketStats']

		data.each_with_index { |record, index|
			date = Time.at(record['fromDate'] * 0.001).strftime('%FT%T')

			if !record['close'] and index != 0
				close_price = chart.last[1]
			else
				close_price = record['close']
			end

			chart.push([date, close_price])
		}

		values = chart.map { |row| row[1] }.compact

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
