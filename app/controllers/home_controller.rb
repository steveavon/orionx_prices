require 'date'
require 'json'
require 'net/http'

class HomeController < ApplicationController
  def index
  	uri = URI.parse('http://api.orionx.io/graphql')

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
		  'marketCode': 'CHACLP',

		  'aggregation': 'd1'
		}

		query = {
			'query': query_str,
			'variables': variables
		}

		request.body = query.to_json

		time_stamp = DateTime.now.strftime('%s')

		digest = OpenSSL::Digest.new('sha1')

		request['Content-Type'] = 'application/json'
		request['X-ORIONX-TIMESTAMP'] = time_stamp
		request['X-ORIONX-APIKEY'] = ENV['ORIONX_API_KEY']
		request['X-ORIONX-SIGNATURE'] = OpenSSL::HMAC.hexdigest(digest, ENV['ORIONX_SECRET_KEY'], time_stamp + request.body)
		request['Content-Length'] = request.body.length

		@response = JSON.parse(http.request(request).body)
  end
end





