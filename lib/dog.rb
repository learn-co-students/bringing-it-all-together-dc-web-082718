class Dog

  attr_accessor :name, :breed
  attr_reader :id

  def initialize(dog_hash, id = nil)
    @name = dog_hash[:name]
    @breed = dog_hash[:breed]
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed) VALUES (? , ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    @id = id
    self
  end

  def self.create(dog_hash)
    dog = Dog.new(dog_hash)
    dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
    SELECT * FROM dogs where id = ?
    SQL
    row = DB[:conn].execute(sql, id)[0]
    Dog.new_from_db(row)
  end


  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ? AND breed = ?;
    SQL
    row = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
    if row.empty?
      Dog.create(dog_hash)
    else
      find_by_id(row[0][0])
    end
  end

  def self.new_from_db(row)
    id = row[0]
    dog_hash = {name: row[1], breed: row[2]}
    Dog.new(dog_hash, id)
  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM dogs WHERE name = ?
    SQL
    row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(row)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id =?;"
    DB[:conn].execute(sql, self.name, self.breed,self.id )
  end

end
