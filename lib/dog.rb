require_relative "../config/environment.rb"

class Dog

    attr_accessor :name, :breed, :id

    def initialize(id: nil,name:,breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs(
                    id INTEGER primary key,
                    name TEXT,
                    breed TEXT
            )
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
        if self.id
            self.update
        else
            sql = <<-SQL
                    INSERT INTO DOGS (name,breed)
                    values (?,?);
                    SQL
            DB[:conn].execute(sql,self.name,self.breed)
             @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
         end
         self
    end

    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
        dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
            SELECT * from dogs where id = ?
            SQL
        dog = DB[:conn].execute(sql,id)[0]
        Dog.new_from_db(dog)
    end

    def self.new_from_db(row)
        new_dog = self.new(id:row[0],name:row[1],breed:row[2])
        new_dog
    end

    def self.find_or_create_by(name:, breed:)
        find = <<-SQL
            Select * from dogs where name=? and breed =?
            SQL
        dog = DB[:conn].execute(find,name,breed)
        if dog.empty?
            dog = self.create(name: name,breed: breed)
        else
            #first row only
            found = dog[0]
            dog = Dog.new(id:found[0],name:found[1],breed:found[2])
        end
        dog
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT * from dogs where name = ?
            SQL
        dog = DB[:conn].execute(sql,name)[0]
        Dog.new_from_db(dog)
    end

    def update
        sql = <<-SQL
         UPDATE dogs SET name = ?, breed = ?  WHERE id = ?
         SQL
         DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
