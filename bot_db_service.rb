require 'pg'

class Bot_db_service
	def initialize(list)
		db_create(list)
	end

	def db_create(list)
		begin
			con = PG.connect :dbname => ENV['DB_NAME'], :user => ENV['USER']
			con.exec "DROP TABLE IF EXISTS Persons"
			con.exec "CREATE TABLE Persons (Id INTEGER PRIMARY KEY, Role VARCHAR(10),
								Link VARCHAR(100), Path VARCHAR(5))"
			list.each { |row|
				line = row.split(',')
				line[2].gsub! "/", "slash"
				line[2].gsub! ":", "dual"
				line[2].gsub! ".", "point"
				con.exec "INSERT INTO Persons
									VALUES (#{line[0].to_i}, '#{line[1]}', '#{line[2]}', '#{line[3]}')"
			}
		rescue PG::Error => e
			puts e.message
		ensure
			con.close if con
		end
	end

	def get_random_person
		begin
			person =''
			con = PG.connect :dbname => ENV['DB_NAME'], :user => ENV['USER']
			query = "SELECT * FROM Persons
					 ORDER BY RANDOM()
					 LIMIT 1"
			con.exec query do |result|
				result.each do |row|
					person = row.values_at('id', 'role', 'link', 'path')
				end
			end
		rescue PG::Error => e
			puts e.message
		ensure
			con.close if con
		end
		return person
	end
end
