require 'telegram/bot'


API_KEY = '5217763625:AAF79QpWHdGlfueS4dQ0nsOzVFdZHZwrS6E'.freeze
Telegram::Bot::Client.run(API_KEY) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.sendMessage(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    end
  end
end
