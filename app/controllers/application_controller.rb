require 'date'
require 'json'
require 'net/http'

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

	def market_history(currency, aggregation)
	  uri = URI.parse('http://api2.orionx.io/graphql')

		http = Net::HTTP.new(uri.host, uri.port)

		request = Net::HTTP::Post.new(uri.path)

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

		time_stamp = DateTime.now.strftime('%s')

		digest = OpenSSL::Digest.new('sha512')

		request['Content-Type'] = 'application/json'
		request['X-ORIONX-TIMESTAMP'] = time_stamp
		request['X-ORIONX-APIKEY'] = ENV['ORIONX_API_KEY']

		hmac = OpenSSL::HMAC.new(ENV['ORIONX_SECRET_KEY'], OpenSSL::Digest.new('sha512'))
		hmac.update(time_stamp + request.body)

		request['X-ORIONX-SIGNATURE'] = 
		request['Content-Length'] = request.body.length

		return JSON.parse(http.request(request).body)
	end

	def chart_data(response)
		chart = []

		data = response['data']['marketStats']

		data.each_with_index { |record, index|
			date = Time.at(record['fromDate'] * 0.001).strftime('%FT%T')

			if !record['close'] and index != 0
				puts index
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
end
