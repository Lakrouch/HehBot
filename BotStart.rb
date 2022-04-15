require './Bot'

bot_play = Bot.new
loop do
	Telegram::Bot::Client.run(bot_play.key) do |bot|
		bot_play.bot = bot
		begin
			bot.listen do |message|
				case message.text
				when '/start'
					bot_play.start(message)
				when 'Actor'
					if bot_play.statement == 2
						bot_play.start(message)
						next
					end
					bot_play.when_actor(message)
					break if bot_play.statement == 2
					bot_play.send_photo(message)
				when 'Dev'
					if bot_play.statement == 2
						bot_play.start(message)
						next
					end
					bot_play.when_dev(message)
					break if bot_play.statement == 2
					bot_play.send_photo(message)
				when '/stop'
					if bot_play.statement == 2
						next
					end
					bot_play.say(message, "Bye!")
					bot_play.statement = 2
					break
				end
			rescue => NoMethodError
				next
			end
		end
	end
end