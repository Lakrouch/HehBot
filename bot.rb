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
    kb = [
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Actor', callback_data: 'Actor'),
      Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Dev', callback_data: 'Dev')
    ]
    markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)
    bot.api.send_message(chat_id: @chat_id, text: 'Who is this?', reply_markup: markup)
  end

  def take_photo
    @person = @bot_db_service.take_random_person
    @statement = @person[1] == 'Actor' ? 1 : 0
    "#{@person[0]}.#{@person[3]}"
  end

  def uncode(str)
    str.gsub! 'slash', '/'
    str.gsub! 'dual', ':'
    str.gsub! 'point', '.'
    str
  end

  def say(text = uncode(@person[2]), id = @chat_id)
    @bot.api.send_message(chat_id: id, text: text)
  end

  def destroy
    @mistakes = 2
    @points = 0
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
    say("Miss! It's a #{who_is}! Your score: #{@points}, miss left: #{@mistakes}")
    if @mistakes.zero?
      say("You lose! Your score: #{@points}")
      destroy
    end
  end

  def when_actor
    if @statement == 1
      when_true
    else
      when_false('dev')
    end
    if @statement != 2
      send_photo
    else
      records_insert
    end
  end

  def when_dev
    if @statement.zero?
      when_true
    else
      when_false('actor')
    end
    if @statement != 2
      send_photo
    else
      records_insert
    end
  end

  def records
    @bot_db_service.tables_select
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
    case message.data.to_s
    when 'Actor'
      when_actor
    when 'Dev'
      when_dev
    end
  end
end
