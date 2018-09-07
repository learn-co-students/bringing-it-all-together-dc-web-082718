class Dog
    attr_accessor :name, :breed
    attr_reader :id

  def initialize(id=nil, hash)
    @id = id
    @name = hash[:name]
    @breed = hash[:breed]
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
    sql = <<-SQL
      DROP TABLE dogs
    SQL

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
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    new_dog = Dog.new(hash)
    new_dog.save
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL

    result = DB[:conn].execute(sql, id)[0]
    Dog.new(result[0], name:result[1], breed:result[2])
  end

  def self.find_or_create_by(hash)
    sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, hash[:name], hash[:breed])

    if row.empty?
      Dog.create(hash)
    else
      find_by_id(row[0][0])
    end
  end

  def self.new_from_db(row)
    id = row[0]
    hash = {name: row[1], breed: row[2]}
    Dog.new(id, hash)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE dogs.name = ?
    SQL

    row = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(row)
  end


end
