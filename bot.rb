# frozen_string_literal: true

require 'telegram/bot'

# Class with logic realisation
class Bot
  attr_accessor :mistakes, :points, :key, :bot, :statement

  def initialize
    @mistakes = 2
    @points = 0
    @key = '5217763625:AAF79QpWHdGlfueS4dQ0nsOzVFdZHZwrS6E'
    @current_path = "#{File.dirname(__FILE__)}/Data"
    @photo_path = "#{@current_path}/Persons_photos/"
    @statement = 2
  end

  def send_photo(message)
    photo = take_photo
    bot.api.send_photo(chat_id: message.chat.id,
                       photo: Faraday::UploadIO.new(@photo_path + photo, 'image/jpeg'))
  end

  def take_photo
    persons = []
    file = File.new("#{@current_path}/persons.yml")
    file.each do |line|
      persons << line
    end
    @person = persons[rand(0...persons.length)].split(',')
    @statement = @person[0] == 'Актёр' ? 1 : 0
    @person[2]
  end

  def say(message, text = @person[1])
    @bot.api.send_message(chat_id: message.chat.id, text: text)
  end

  def destroy
    @mistakes = 2
    @points = 0
    @statement = 2
  end

  def start(message)
    destroy
    say(message, "Hello, #{message.from.first_name}")
    send_photo(message)
    Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [%w[Actor Dev]], one_time_keyboard: true)
  end

  def when_actor(message)
    if @statement == 1
      @points += 1
      say(message, "Correct! Your score: #{@points}, miss left: #{@mistakes}")
      say(message)
    else
      @mistakes -= 1
      say(message, "Miss! It's a Dev! Your score: #{@points}, miss left: #{@mistakes}")
      if @mistakes.zero?
        say(message, "You lose! Your score: #{@points}")
        destroy
      end
    end
  end

  def when_dev(message)
    if @statement.zero?
      @points += 1
      say(message, "Correct! Your score: #{@points}, miss left: #{@mistakes}")
      say(message)
    else
      @mistakes -= 1
      say(message, "Miss! It's an Actor! Your score: #{@points}, miss left: #{@mistakes}")
      if @mistakes.zero?
        say(message, "You lose! Your score: #{@points}")
        destroy
      end
    end
  end
end
