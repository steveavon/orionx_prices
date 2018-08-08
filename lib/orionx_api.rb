require 'uri'
require 'date'
require 'json'
require 'openssl'
require 'net/http'

module OrionxApi
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
end