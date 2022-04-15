require './Bot'

bot_play = Bot.new
Telegram::Bot::Client.run(bot_play.key) do |bot|
	bot_play.bot = bot
  bot.listen do |message|
    case message.text
    when '/start'
	    bot_play.say(message, "Hello, #{message.from.first_name}")
	    bot_play.send_photo(message)
      answers =
        Telegram::Bot::Types::ReplyKeyboardMarkup
          .new(keyboard: [%w(Актёр Прогер)], one_time_keyboard: true)
    end
  end
end
