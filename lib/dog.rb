require 'pry'
class Dog
  attr_accessor :id, :name, :breed

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
    self
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.breed)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
    SQL

    new_dog_row = DB[:conn].execute(sql, id)[0]
    hash = {:name => new_dog_row[1],
            :breed => new_dog_row[2],
            :id => new_dog_row[0]}
    Dog.new(hash)
  end

  def self.find_or_create_by(hash)
    hash[:id] = nil
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? AND breed = ?
    SQL

    new_dog_row = DB[:conn].execute(sql, hash[:name], hash[:breed])[0]
    if new_dog_row != nil
      hash[:id] = new_dog_row[0]
    end
    dog = Dog.new(hash)
    dog.save
  end

  def self.new_from_db(row)
    hash = {}
    hash[:id] = row[0]
    hash[:name] = row[1]
    hash[:breed] = row[2]
    Dog.new(hash)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    new_dog_row = DB[:conn].execute(sql, name)[0]
    # hash = {
    #         :id => new_dog_row[0],
    #         :name => name,
    #         :breed => new_dog_row[2]
    #       }

    self.new_from_db(new_dog_row)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end




end
