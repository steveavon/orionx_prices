require 'httparty'

include Functionalities

module GetPrices
	def self.get_crypto_price_in_usd(crypto)
		crypto_price = nil

		if (['BTC', 'ETH', 'XRP', 'XLM', 'LTC', 'BCH', 'DASH'].include?(crypto))
			file_name = File.join(Dir.pwd, "/prices/", crypto.downcase)

			if (!File.exist?(file_name) or Functionalities.get_minutes_since_modification_of_file(file_name) > 15)
				crypto_id = Functionalities.get_crypto_id(crypto)

				if (crypto_id)
				response = HTTParty.get("https://api.coingecko.com/api/v3/coins/#{crypto_id}?localization=false")

					if (response.code == 200)
						crypto_price = JSON.parse(response.body)["market_data"]["current_price"]["usd"]

						File.open(file_name, 'w') { |file| file.write(crypto_price) }
					end
				end
			else
				crypto_price = File.open(file_name) { |f| f.readline }.to_f
			end
		end

		return crypto_price
	end

	def self.get_usd_value_in_clp(crypto)
		usd_in_clp = nil

		if (['BTC', 'ETH', 'XRP', 'XLM', 'LTC', 'BCH', 'DASH'].include?(crypto))
			file_name = File.join(Dir.pwd, "/prices/clp")

			if (!File.exist?(file_name) or Functionalities.minutes_since_modification_of_file(file_name) > 15)
				response = HTTParty.get("https://mindicador.cl/api/dolar")

				if (response.code == 200)
					usd_in_clp = JSON.parse(response.body)["serie"].first["valor"]

					File.open(file_name, 'w') { |file| file.write(usd_in_clp) }
				end
			else
				usd_in_clp = File.open(file_name) { |f| f.readline }.to_f
			end
		end

		return usd_in_clp.to_i
	end
end