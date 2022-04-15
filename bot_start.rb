# frozen_string_literal: true

require './bot'

bot_play = Bot.new
loop do
  Telegram::Bot::Client.run(bot_play.key) do |bot|
    bot_play.bot = bot

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
        next if bot_play.statement == 2

        bot_play.say(message, 'Bye!')
        bot_play.statement = 2
        break
      end
    rescue StandardError => e
      next
    end
  end
end
