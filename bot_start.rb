# frozen_string_literal: true

require './bot'

bot_play = Bot.new
loop do
  Telegram::Bot::Client.run(bot_play.key) do |bot|
    bot_play.bot = bot

    bot.listen do |message|
      bot_play.reaction_on_message(message)
    rescue NoMethodError
      next
    end
  end
end
