require 'sinatra'
require 'data_mapper'

get '/' do
	redirect '/submit'
end

get '/submit' do

end

post '/submit' do
	paper = Paper.new
	
end

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/websubrev.db")
class Paper
	include DataMapper::Resource
	property :id, Serial
	property :abstract, Text, :required => true
	property :comments, Text
	
	has n, :authors, :through => Resource, :required => true
	has n, :keywords
end

class Author
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
	property :email, String, :format => :email_address, :required => true

	has n :papers, :through => Resource
end

class Affiliation
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
end

class Keyword
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
end

class Category
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
end

# DataMapper.finalize.auto_migrate!
DataMapper.finalize.auto_upgrade!