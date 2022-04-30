# frozen_string_literal: true

require 'telegram/bot'
require 'dotenv'
require './bot_db_service'

# class with logic implementation
class Bot
  attr_accessor :mistakes, :points, :key, :bot, :statement

  def initialize
    Dotenv.load
    @mistakes = 2
    @points = 0
    @key = ENV['API_KEY']
    @current_path = "#{File.dirname(__FILE__)}/Data"
    @photo_path = "#{@current_path}/Persons_photos/"
    @statement = 2
    @chat_id = 0
    @bot_db_service = BotDbService.new(File.new("#{@current_path}/persons.yml"))
    @user = ' '
  end

  def send_photo
    photo = take_photo
    bot.api.send_photo(chat_id: @chat_id,
                       photo: Faraday::UploadIO.new((@photo_path + photo).strip, 'image/jpeg'))
    key_board = [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Actor', callback_data: 'Actor'),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Dev', callback_data: 'Dev')
    ]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: key_board)
    bot.api.send_message(chat_id: @chat_id, text: 'Who is this?', reply_markup: markup)
  end

  def take_photo
    @person = @bot_db_service.take_random_person
    @statement = @person[1] == 'Actor' ? 1 : 0
    "#{@person[0]}.#{@person[3]}"
  end

  def decode(str)
    str.gsub! 'slash', '/'
    str.gsub! 'dual', ':'
    str.gsub! 'point', '.'
    str
  end

  def say(text = decode(@person[2]), id = @chat_id)
    @bot.api.send_message(chat_id: id, text: text)
  end

  def destroy
    @mistakes = 2
    @statement = 2
  end

  def start(message)
    @statement = 1
    @chat_id = message.chat.id
    @user = message.from.first_name
    say("Hello, #{message.from.first_name}")
    send_photo
  end

  def when_true
    @points += 1
    say("Correct! Your score: #{@points}, miss left: #{@mistakes}")
    say
  end

  def when_false(who_is)
    @mistakes -= 1
    if @mistakes.zero?
      say("You lose! Your score: #{@points}")
      destroy
    else
      say("Miss! It's a #{who_is}! Your score: #{@points}, miss left: #{@mistakes}")
    end
  end

  def when_lose
    records_insert
    @points = 0
  end

  def when_actor
    @statement == 1 ? when_true : when_false('dev')
    @statement != 2 ? send_photo : when_lose
  end

  def when_dev
    @statement.zero? ? when_true : when_false('actor')
    @statement != 2 ? send_photo : when_lose
  end

  def records
    say 'Our top-five:'
    records_select = @bot_db_service.tables_select
    records_select.each { |row| say "#{row.values_at('name').to_s[2..-3]}: #{row.values_at('score').to_s[2..-3]} " }
  end

  def records_insert
    say('Type /start to play again')
    @bot_db_service.tables_insert(@chat_id, @user, @points)
  end

  def reaction_on_message(message)
    case message.text
    when '/start'
      start(message)
    when '/records'
      records
    when '/stop'
      say('Bye!', message.chat.id)
    else
      say("I don't understand you", message.chat.id)
    end
  end

  def reaction_on_query(message)
    message.data.to_s == 'Actor' ? when_actor : when_dev
  end
end
