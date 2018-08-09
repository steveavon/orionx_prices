require 'httparty'

module GetPrices
	def get_crypto_price(crypto)
		crypto_price = nil

		valor = (crypto == 'BTC')

		if crypto == 'BTC'
			file_name = Dir.pwd + "/prices/" + crypto.downcase

			if !File.exist?(file_name) or ((File.mtime(file_name) - Time.now) / 60).to_i.abs > 15
				puts "consultando API precio btc"
				response = HTTParty.get("https://api.coingecko.com/api/v3/coins/bitcoin?localization=false")

				crypto_price = JSON.parse(response.body)["market_data"]["current_price"]["usd"]

				File.open(file_name, 'w') { |file|
					file.write(crypto_price)
				}
			else
				puts "consultando archivo precio btc"
				crypto_price = File.open(file_name) { |f|
					f.readline
				}.to_i
			end
		end

		return crypto_price
	end

	def get_usd_in_clp(crypto)
		usd_in_clp = nil

		if crypto == 'BTC'
			file_name = Dir.pwd + "/prices/clp"

			if !File.exist?(file_name) or ((File.mtime(file_name) - Time.now) / 60).to_i.abs > 15
				puts "consultando API precio usd"
				response = HTTParty.get("https://mindicador.cl/api/dolar")

				usd_in_clp = JSON.parse(response.body)["serie"].first["valor"]

				File.open(file_name, 'w') { |file|
					file.write(usd_in_clp)
				}
			else
				puts "consultando archivo precio usd"
				usd_in_clp = File.open(file_name) { |f|
					f.readline
				}.to_i
			end
		end

		return usd_in_clp.to_i
	end
end