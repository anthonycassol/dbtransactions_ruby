require 'pg'
require 'csv'

def explicita(con)
    con.transaction do |con|
        CSV.foreach("data.csv") do |row|
            con.exec "INSERT INTO transactions (ProductName, BrandName, Asin) VALUES ('#{row[0]}', '#{row[1]}', '#{row[2]}')"
        end
    end
end

def implicita(con)
    CSV.foreach("data.csv") do |row|
        con.exec "INSERT INTO transactions (ProductName, BrandName, Asin) VALUES ('#{row[0]}', '#{row[1]}', '#{row[2]}')"
    end
end

def explicita_erro(con)
    i = 0
    random = rand(0..10000)   
    puts random      
    con.transaction do |con|
        CSV.foreach("data.csv") do |row|
            if random == i
                con.exec "INSER INTO transactions (ProductName, BrandName, Asin) VALUES ('#{row[0]}', '#{row[1]}', '#{row[2]}')"
            else
                con.exec "INSERT INTO transactions (ProductName, BrandName, Asin) VALUES ('#{row[0]}', '#{row[1]}', '#{row[2]}')"
            end
            i += 1
        end
    end
end

def implicita_erro(con)
    i = 0
    random = rand(0..10000)   
    puts random      
    CSV.foreach("data.csv") do |row|
        if random == i
            con.exec "INSER INTO transactions (ProductName, BrandName, Asin) VALUES ('#{row[0]}', '#{row[1]}', '#{row[2]}')"
        else
            con.exec "INSERT INTO transactions (ProductName, BrandName, Asin) VALUES ('#{row[0]}', '#{row[1]}', '#{row[2]}')"
        end
        i += 1
    end
end

begin
    con = PG.connect :dbname => 'transactions', :user => 'guhzanella'
    dbname = con.db;
    puts dbname;

    con.exec "DROP TABLE IF EXISTS transactions"
    con.exec "CREATE TABLE transactions (id SERIAL PRIMARY KEY, ProductName VARCHAR(300), BrandName VARCHAR(300), Asin VARCHAR(300))"

    time1 = Time.now
    implicita_erro(con)
    time2 = Time.now
    
    puts "Time: #{time2-time1} segundos"

rescue PG::Error => e
    puts e.message 
ensure
    con.close if con
end