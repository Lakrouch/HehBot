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
	    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w(Actor Dev)], one_time_keyboard: true)
    when 'Actor'
	    next if bot_play.statement == 2
	    if bot_play.statement == 1
		    bot_play.points += 1
		    bot_play.say(message, "Correct! Your score: #{bot_play.points}, miss left: #{bot_play.mistakes}")
		    bot_play.say(message)
	    else
		    bot_play.mistakes -= 1
		    bot_play.say(message, "Miss! Your score: #{bot_play.points}, miss left: #{bot_play.mistakes}")
		    if bot_play.mistakes == 0
			    bot_play.say(message, "You lose! Your score: #{bot_play.points}")
			    bot_play.destroy
			    break
		    end
	    end
	    bot_play.send_photo(message)
    when 'Dev'
	    next if bot_play.statement == 2
	    if bot_play.statement == 0
		    bot_play.points += 1
		    bot_play.say(message, "Correct! Your score: #{bot_play.points}, miss left: #{bot_play.mistakes}")
		    bot_play.say(message)
	    else
		    bot_play.mistakes -= 1
		    bot_play.say(message, "Miss! Your score: #{bot_play.points}, miss left: #{bot_play.mistakes}")
		    if bot_play.mistakes == 0
			    bot_play.say(message, "You lose! Your score: #{bot_play.points}")
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
