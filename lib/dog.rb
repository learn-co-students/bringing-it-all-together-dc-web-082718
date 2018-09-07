

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  # def attributes()
  #   sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
  #   DB[:conn].execute(sql, name, breed)
  #
  # end

  def initialize (id: nil, name:, breed:) #delivering params by 'metaprogramming' (hash?) requires a keyword argument
    @id, @name, @breed = id, name, breed
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)"
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    insert_sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    retrieve_id_sql = "SELECT last_insert_rowid() FROM dogs"
    DB[:conn].execute(insert_sql, @name, @breed)

    @id = DB[:conn].execute(retrieve_id_sql).flatten(1)[0]
    self
  end

  def self.create (name:, breed:)
    dog = self.new(name: name, breed: breed)
    dog.save

  end

  def self.find_by_id (id)

    select_sql = "SELECT * FROM dogs WHERE dogs.id = ?"
    row = DB[:conn].execute(select_sql, id).flatten(1)
    # binding.pry
    self.new(id: row[0], name: row[1], breed: row[2])

  end

  def self.find_or_create_by (name:, breed:)
    select_sql = "SELECT * FROM dogs WHERE name = '#{name}' AND breed = '#{breed}'"
    dog = DB[:conn].execute(select_sql).flatten
    # binding.pry
    if dog.empty?
      self.create(name: name, breed: breed)
    else
      self.find_by_id(dog[0])
    end
  end

  def self.new_from_db (row)
    self.new(id: row[0], name: row[1], breed: row[2])

  end

  def self.find_by_name (name)
    select_sql = "SELECT * FROM dogs WHERE dogs.name = ?"
    row = DB[:conn].execute(select_sql, name).flatten(1)
    # binding.pry
    self.new(id: row[0], name: row[1], breed: row[2])
  end

  def update
    # update_sql = "UPDATE dogs SET dogs.name = '#{@name}', dogs.breed = '#{@breed}' WHERE dogs.id = '#{@id}'" #doesnt work here
    update_sql = "UPDATE dogs SET name = '#{@name}', breed = '#{@breed}' WHERE id = '#{@id}'" #doesnt work here
    # binding.pry
    DB[:conn].execute(update_sql)

  end

end
