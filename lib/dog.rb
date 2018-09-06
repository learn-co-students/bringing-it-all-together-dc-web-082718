class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @id = id
    @name = name
    @breed = breed
  end

  # Class Methods

  def self.create_table
    # Creates the dogs table with values of name and breed
    sql= <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    # DB[:conn].execute("DROP TABLE IF EXISTS dogs")
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end

  def self.create(attributes_hash)
    new_dog = self.new(name: attributes_hash[:name], breed: attributes_hash[:breed])
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, new_dog.name, new_dog.breed)
    new_dog.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    new_dog
  end

  def self.new_from_db(row)
    new_dog = self.new(
      name: row[1],
      breed: row[2],
      id: row[0]
    )
    new_dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    new_row = DB[:conn].execute(sql, id).first
    new_from_db(new_row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
    SQL
    new_row = DB[:conn].execute(sql, name).first
    new_from_db(new_row)
  end

  def self.find_or_create_by(name:, breed:)
    # Check if a dog with these exactly parameters exists in
    # the database already or not.
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, name, breed)[0]
    if row == nil
      create({name: name, breed: breed})
    elsif row[-2..-1] == [name, breed]
      new_from_db(row)
    else
      create({name: name, breed: breed})
    end

  end

  # Instance Methods

  def create_new_db_entry # Creates a new database entry from an object
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    self.id = DB[:conn].execute("SELECT last_insert_rowid()")[0][0]
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def save
    if self.id == nil
      create_new_db_entry
    else
      sql = <<-SQL
        UPDATE dogs
        WHERE id = ?
        SET name = ?, breed = ?
      SQL

      DB[:conn].execute(sql, self.id, self.name, self.breed)
    end

  end
end
