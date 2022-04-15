require './Bot'

bot_play = Bot.new
Telegram::Bot::Client.run(bot_play.key) do |bot|
	bot_play.bot = bot
  bot.listen do |message|
    case message.text
    when '/start'
	    bot_play.destroy
	    bot_play.say(message, "Hello, #{message.from.first_name}")
	    bot_play.send_photo(message)
	    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w(Актёр Прогер)], one_time_keyboard: true)
    when 'Актёр'
	    next if bot_play.statement == 2
	    if bot_play.statement == 1
		    bot_play.points += 1
		    bot_play.say(message, "Ты прав! Счёт: #{bot_play.points}, ошибок осталось: #{bot_play.mistakes}")
		    bot_play.say(message)
	    else
		    bot_play.mistakes -= 1
		    bot_play.say(message, "Ты не прав! Счёт: #{bot_play.points}, ошибок осталось: #{bot_play.mistakes}")
		    if bot_play.mistakes == 0
			    bot_play.say(message, "Ты проиграл со счётом #{bot_play.points}")
			    bot_play.destroy
			    break
		    end
	    end
	    bot_play.send_photo(message)
    when 'Прогер'
	    next if bot_play.statement == 2
	    if bot_play.statement == 0
		    bot_play.points += 1
		    bot_play.say(message, "Ты прав! Счёт: #{bot_play.points}, ошибок осталось: #{bot_play.mistakes}")
		    bot_play.say(message)
	    else
		    bot_play.mistakes -= 1
		    bot_play.say(message, "Ты прав! Счёт: #{bot_play.points}, ошибок осталось: #{bot_play.mistakes}")
		    if bot_play.mistakes == 0
			    bot_play.say(message, "Ты проиграл со счётом #{bot_play.points}")
			    bot_play.destroy
			    break
		    end
	    end
	    bot_play.send_photo(message)
    when '/stop'
	    bot_play.say(message, 'Bye!')
	    bot_play.destroy
	    break
    end
  end
end
