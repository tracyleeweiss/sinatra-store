# gem install --version 1.3.0 sinatra
#require 'pry'
gem 'sinatra', '1.3.0'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'
#require "better_errors"

require "json"
require "open-uri"
require "uri"

# configure :development do
#   use BetterErrors::Middleware
#   BetterErrors.application_root = File.expand_path("..", __FILE__)
# end

before do
  @db = SQLite3::Database.new "store.sqlite3"
  @db.results_as_hash = true
end

get '/products/search' do
  @q = params[:q]
  file = open("http://search.twitter.com/search.json?q=#{URI.escape(@q)}")
  @results = JSON.load(file.read)
  erb :search_results
end

get '/products/search_google' do
  @q = params[:q]
  file = open("https://www.googleapis.com/shopping/search/v1/public/products?key=AIzaSyDPNcKZqJonuiYOCWJYmg5FtCvg57WqYdI&country=US&q=#{URI.escape(@q)}
", :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE)
  @results = JSON.load(file.read)
  erb :search_google
end
 
post '/new_product' do
  name = params[:product_name]
  price = params[:product_price]
  sql = "INSERT INTO products ('name', 'price') VALUES ('#{name}', '#{price}');"
  @rs = @db.execute(sql)
  @name = name
  erb :product_created
end

get '/new_product' do
   erb :new_product
end
 
get '/users' do
  db = SQLite3::Database.new "store.sqlite3" 
  @rs = @db.prepare('SELECT * FROM users;').execute
  erb :show_users
end
 
#index action (or list of all records)
 get '/products' do
  @rs = @db.prepare('SELECT * FROM products;').execute
  erb :show_products
end
#show action
get '/products/:id' do
  id = params[:id]
  sql = "SELECT * FROM products WHERE id = #{id};"
  @row = @db.get_first_row(sql)
  erb :product_id
end
 
 get '/products/:id/edit' do
  @id = params[:id]
  sql = "SELECT * FROM products WHERE id = #{@id};"
  @row = @db.get_first_row(sql)
  erb :edit_product
end

 post '/products/:id' do
  @id = params[:id]
  @price = params[:product_price]
  @name = params[:product_name]
  sql = "UPDATE products SET name = '#{@name}', price = '#{@price}' WHERE id = '#{@id}';"
  @row = @db.prepare(sql).execute

  @rs = @db.prepare("SELECT * FROM products WHERE id = '#{@id}';").execute

  erb :show_products

end

 post '/products/:id/destroy' do
  @id = params[:id]
  @price = params[:product_price]
  @name = params[:product_name]
  sql = "DELETE from products WHERE id = '#{@id}';"
  @row = @db.prepare(sql).execute

  @rs = @db.prepare("SELECT * FROM products WHERE id = '#{@id}';").execute

  erb :show_products

end

 get '/products/:id/destroy' do
  @id = params[:id]
  #@price = params[:product_price]
  #@name = params[:product_name]
  #sql = "DELETE from products WHERE id = '#{@id}';"
  #@row = @db.prepare(sql).execute
  sql = "SELECT * FROM products WHERE id = #{@id};"
  #@rs = @db.prepare("SELECT * FROM products WHERE id = '#{@id}';").execute
  @row = @db.get_first_row(sql)
  erb :destroy_product

end

# get '/products/:id/tweets' do
#   @id = params[:id]
#   sql = "SELECT name FROM products WHERE id = #{@id};"
#   @name = @db.get_first_value(sql)
#   file = open("http://search.twitter.com/search.json?@name=#{URI.escape(@name)}")
#   @results = JSON.load(file.read)
#   erb :search_results
# end



 
 get '/' do
  erb :home
end
 
 
 
 
 
=begin
 
  <form method='post' action='/create'>
    <input type='text' name='name' autofocus>
    <input type='text' name='photo'>
    <input type='text' name='breed'>
    <button>dog me!</button>
  </form>
 
 
  post '/create' do
  end
 
 
  redirect '/'
 
=end