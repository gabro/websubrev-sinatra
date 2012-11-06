require 'sinatra'
require 'data_mapper'

get '/' do
	redirect '/submit'
end

get '/submit' do
	@title = 'New submission'
	erb :submission
end

post '/submit' do
	begin
		paper = Paper.new
		paper.title = params['title']
		paper.abstract = params['abstract']
		paper.comments = params['comments']
		category = params['category']
		paper.category = Category.first_or_create(:name => category) unless category.nil?

		authors = params['authors'].split(',').collect {|x| x.strip}
		emails = params['emails'].split(',').collect {|x| x.strip}
		affiliations = params['affiliations'].split(',').collect {|x| x.strip}

		authors_emails_aff = authors.zip(emails, affiliations)
		authors_emails_aff.each do |tuple|
			author = Author.first_or_create(:name => tuple[0])
			email = Email.first_or_create(:email => tuple[1]) unless tuple[1].nil?
			affiliation = Affiliation.first_or_create(:name => tuple[2]) unless tuple[2].nil?
			author.emails << email unless email.nil?
			author.affiliations << affiliation unless affiliations.nil?
			paper.authors << author
		end

		keywords = params['keywords'].split(',').collect {|x| x.strip}
		keywords.each do |kw|
			keyword = Keyword.first_or_create(:name => kw)
			paper.keywords << keyword
		end

		@message = 'Submission complete'
		erb :success if paper.save
	# rescue Exception => e
	# 	@error_message = e
	# 	erb :error
	end

end

# get '/submit/success' do
# 	@message = Submission complete
# 	erb :success
# end

# get '/sumibt/error'  do
# 	#
# end
 
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/websubrev.db")
class Paper
	include DataMapper::Resource
	property :id, Serial
	property :title, String, :required => true
	property :abstract, Text, :required => true
	property :comments, Text

	has n, :authors, :through => Resource
	has n, :keywords
	belongs_to :category, :required => false
end

class Author
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
	
	has n, :affiliations
	has n, :emails
	has n, :papers, :through => Resource
end

class Affiliation
	include DataMapper::Resource
	property :id, Serial
	property :name, String, :required => true
end

class Email
	include DataMapper::Resource
	property :id, Serial
	property :email, String, :format => :email_address, :required => true
	belongs_to :author
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

	has n, :papers
end

DataMapper.finalize.auto_migrate!
# DataMapper.finalize.auto_upgrade!