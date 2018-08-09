module Functionalities
	def minutes_since_modification_of_file(file_name)
		return ((Time.now - File.mtime(file_name)) / 60).to_i
	end

	def get_crypto_id(crypto)
		case crypto
		when "BTC"
		  "bitcoin"
		when "ETH"
		  "ethereum"
		when "XRP"
		  "ripple"
		when "XLM"
			"stellar"
		when "LTC"
		  "litecoin"
		when "BCH"
		  "bitcoin-cash"
		when "DASH"
			"dash"
		else
			nil
		end
	end
end