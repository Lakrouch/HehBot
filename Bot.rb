require 'telegram/bot'

class Bot
	attr_accessor :mistakes, :points, :key, :bot, :statement

	def initialize
		@mistakes = 2
		@points = 0
		@key = '5217763625:AAF79QpWHdGlfueS4dQ0nsOzVFdZHZwrS6E'.freeze
		@current_path = File.dirname(__FILE__)+"/Data"
		@photo_path = @current_path+"/Persons_photos/"
	end

	def send_photo(message)
		photo = get_photo
		bot.api.send_photo(chat_id: message.chat.id,
		                   photo: Faraday::UploadIO.new(@photo_path+photo, 'image/jpeg'))
	end

	def get_photo
		persons = []
		file = File.new(@current_path+"/persons.yml")
		file.each do |line|
			persons<<line
		end
		@person = persons[rand(0...persons.length)].split(',')
		@person[0] == 'Актёр' ? @statement = 1 : @statement= 0
		return @person[2]
	end

	def say(message,text=@person[1])
		@bot.api.send_message(chat_id: message.chat.id, text: text)
	end

	def destroy
		@mistakes = 2
		@points = 0
	end
end
