module PriceStatistics
	def self.get_on_balance_volume(price, vol, sma_periods)
		obv = []

		obv.push([vol[0][0], vol[0][1].round(1)])

		(1..vol.length - 1).each { |i|
			change = price[i][1] - price[i - 1][1]

			if change > 0
				obv.push([price[i][0], (obv.last[1] + vol[i][1]).round(1)])
			elsif change < 0
				obv.push([price[i][0], (obv.last[1] - vol[i][1]).round(1)])
			else
				obv.push([price[i][0], (obv.last[1]).round(1)])
			end
		}

		return obv.drop(sma_periods)
	end

	def self.chart_data(price, sma_periods)
		values = price.map { |row| row[1] }

		min = values.min * (1 - 0.02)
		max = values.max * (1 + 0.02)

		return price.drop(sma_periods), min, max
	end

	def self.sma(price, step)
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

		return sma
	end

	def self.rsi(price)
		values = price.map { |row| row[1] }

		gain = []
		loss = []

		values.each_with_index do |value, i|
	  	if i != values.size - 1
				change = values[i + 1] - values[i]

				if (change > 0)
					gain.push(change)
					loss.push(0)
				elsif (change < 0)
					loss.push(-change)
					gain.push(0)
				else
					gain.push(0)
					loss.push(0)
				end
	  	end
		end

		avg_gain = []
		avg_loss = []

		avg_gain.push(gain[0, 14].inject{ |sum, el| sum + el }.to_f / gain[0, 14].size)
		avg_loss.push(loss[0, 14].inject{ |sum, el| sum + el }.to_f / gain[0, 14].size)

		(14 .. gain.size - 1).each_with_index do |i|
			avg_gain.push((avg_gain.last * 13 + gain[i]) / 14)
		end

		(14 .. loss.size - 1).each_with_index do |i|
			avg_loss.push((avg_loss.last * 13 + loss[i]) / 14)
		end

		rs = avg_gain.zip(avg_loss).map{ |x, y| x / y }

		rsi = rs.map{ |x| 100 - (100 / (1 + x)) }

		return rsi.last
	end
end