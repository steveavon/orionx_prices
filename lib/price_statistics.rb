module PriceStatistics
	def vol_data_for_chart(price, vol, sma_periods)
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

		return obv.drop(sma_periods)
	end

	def chart_data(price, sma_periods)
		values = price.map { |row| row[1] }

		min = values.min
		max = values.max

		price_min = min - (max - min) * 0.2
		price_max = max + (max - min) * 0.2

		return price.drop(sma_periods), price_min, price_max
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

		if (100 - 100 / (1 + rs)).to_f.nan? 
			rsi = 50
		else
			rsi = 100 - 100 / (1 + rs)
		end

		return rsi
	end
end