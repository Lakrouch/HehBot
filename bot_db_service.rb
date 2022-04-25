# frozen_string_literal: true

require 'pg'

# Documentation comment
class BotDbService
  def initialize(list)
    persons_table_create(list)
    records_table_create
    users_table_create
  end

  def persons_table_create(list)
    con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
    con.exec 'DROP TABLE IF EXISTS Persons'
    con.exec "CREATE TABLE Persons (Id INTEGER PRIMARY KEY, Role VARCHAR(10),
								Link VARCHAR(100), Path VARCHAR(5))"
    list.each do |row|
      line = row.split(',')
      line[2].gsub! '/', 'slash'
      line[2].gsub! ':', 'dual'
      line[2].gsub! '.', 'point'
      con.exec "INSERT INTO Persons
									VALUES (#{line[0].to_i}, '#{line[1]}', '#{line[2]}', '#{line[3]}')"
    end
  rescue PG::Error => e
    puts e.message
  ensure
    con&.close
  end

  def records_table_create
    con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
    con.exec 'DROP TABLE IF EXISTS Records'
    con.exec 'CREATE TABLE Records (id INTEGER PRIMARY KEY, score INTEGER)'
  rescue PG::Error => e
    puts e.message
  ensure
    con&.close
  end

  def users_table_create
    con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
    con.exec 'DROP TABLE IF EXISTS Users'
    con.exec 'CREATE TABLE Users (id INTEGER PRIMARY KEY, name VARCHAR(20))'
  rescue PG::Error => e
    puts e.message
  ensure
    con&.close
  end

  def tables_insert(id, name, score)
    con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
    con.exec "IF #{id} <> 0 THEN
									UPDATE Records SET score = #{score} WHERE id = #{id};
								ELSE
									INSERT INTO Records  VALUES(#{id}, #{score});
								END IF"
    con.exec "IF (SELECT COUNT(id) FROM Users WHERE id = #{id}) = 0 THEN
									INSERT INTO Users  VALUES(#{id}, '#{name}');
								END IF"
  rescue PG::Error => e
    puts e.message
  ensure
    con&.close
  end

  def tables_select
    con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
    query = 'SELECT (u.name, r.score) FROM Users u JOIN Records r ON r.id=u.id'
    con.exec query do |result|
      result.each do |row|
        puts row.values_at('name', 'score')
      end
    end
  rescue PG::Error => e
    puts e.message
  ensure
    con&.close
  end

  def take_random_person
    begin
      person = ''
      con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
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
      con&.close
    end
    person
  end
end
