# frozen_string_literal: true

require 'pg'

# Documentation comment
class BotDbService
  def initialize(list)
    @con = PG.connect dbname: ENV['DB_NAME'], user: ENV['USER']
    persons_table_create(list)
    records_table_create
    users_table_create
  end

  def persons_table_create(list)
    @con.exec 'DROP TABLE IF EXISTS Persons'
    @con.exec 'CREATE TABLE Persons (Id INTEGER PRIMARY KEY, Role VARCHAR(10), Link VARCHAR(100), Path VARCHAR(5))'
    list.each do |row|
      line = row.split(',')
      line[2].gsub! '/', 'slash'
      line[2].gsub! ':', 'dual'
      line[2].gsub! '.', 'point'
      @con.exec "INSERT INTO Persons
									VALUES (#{line[0].to_i}, '#{line[1]}', '#{line[2]}', '#{line[3]}')"
    end
  end

  def records_table_create
    @con.exec 'DROP TABLE IF EXISTS Records'
    @con.exec 'CREATE TABLE Records (id INTEGER PRIMARY KEY, score INTEGER)'
  end

  def users_table_create
    @con.exec 'DROP TABLE IF EXISTS Users'
    @con.exec 'CREATE TABLE Users (id INTEGER PRIMARY KEY, name VARCHAR(20))'
  end

  def tables_insert(id, name, score)
    count = @con.exec "SELECT COUNT(id) FROM Records WHERE id = #{id};"
    if (count[0]['count']).to_i != 0
      saved = @con.exec "SELECT score FROM Records WHERE id = #{id};"
      @con.exec "UPDATE Records SET score = #{score} WHERE id = #{id};" unless saved > score
    else
      @con.exec "INSERT INTO Records  VALUES(#{id}, #{score});"
      @con.exec "INSERT INTO Users  VALUES(#{id}, '#{name}');"
    end
  end

  def tables_select
    @con.exec 'SELECT u.name, r.score FROM Users u JOIN Records r ON r.id=u.id LIMIT 5'
  end

  def take_random_person
    person = ''
    query = "SELECT * FROM Persons
					 ORDER BY RANDOM()
					 LIMIT 1"
    @con.exec query do |result|
      result.each do |row|
        person = row.values_at('id', 'role', 'link', 'path')
      end
    end
    person
  end
end
