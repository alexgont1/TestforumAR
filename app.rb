require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:testforum.db"
#tables:
#posts [created_at, post_name TEXT, content TEXT]
#comments [created_at, content TEXT, post_id INTEGER]

before do
end

class Post < ActiveRecord::Base
  validates :post_name, presence: true, length: { minimum: 2 }
  validates :content, presence: true, length: { minimum: 2 }
end

class Comment < ActiveRecord::Base
  validates :content, presence: true, length: { minimum: 2 }
end

configure do
end

def post_info post_id
  #get post info
  @results = @db.execute 'SELECT * FROM Posts WHERE id = ?', [post_id]
  #put info about post to @row
  @row = @results[0]
  #select comments for our post
  @comments =  @db.execute 'SELECT * FROM Comments WHERE 
  post_id = ?', [post_id]
end

get '/' do
  @results = Post.order "created_at DESC"
  erb :index
end

get '/new' do
  @p = Post.new
  erb :new
end

post '/new' do
  @p = Post.new params[:post]
  
  if @p.save
    redirect to '/' #go to main page if OK
  else
    @error = @p.errors.full_messages.first
    erb :new
  end

end

#show info about post
get '/details/:post_id' do
  post_id = params[:post_id]

  post_info post_id

  erb :details
end

#get comment from server
post '/details/:post_id' do
  post_id = params[:post_id]

  content = params[:content]

  if content.length < 1
    @error = 'Type comment text'

    post_info post_id

    return erb :details
  end

  #save comment in DB
  @db.execute 'INSERT INTO Comments 
  (
    content,
    created_date,
    post_id
  )   VALUES (?, datetime(), ?)', 
  [
    content, 
    post_id
  ]

  redirect to ('/details/' + post_id)
end