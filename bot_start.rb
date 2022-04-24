# frozen_string_literal: true

require './bot'

bot_play = Bot.new
loop do
  Telegram::Bot::Client.run(bot_play.key) do |bot|
    bot_play.bot = bot
    bot.listen do |message|
      case message
      when Telegram::Bot::Types::CallbackQuery
          bot_play.reaction_on_query(message)
      when Telegram::Bot::Types::Message
        bot_play.reaction_on_message(message)
      end
    rescue NoMethodError
      next
    end
  end
end
