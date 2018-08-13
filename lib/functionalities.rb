module Functionalities
	def self.get_minutes_since_modification_of_file(file_name)
		seconds_since_modification_of_file = Time.now - File.mtime(file_name)

		minutes_since_modification_of_file = (seconds_since_modification_of_file / 60).to_i

		return minutes_since_modification_of_file
	end

	def self.get_crypto_id(crypto)
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

	def self.get_proper_round(number)
		case number
			when nil then  
			when 0..1 then number.round(3)
			when 1..10 then number.round(2)
			when 10..100 then number.round(1)
			else number.round(0)
		end 
	end
end