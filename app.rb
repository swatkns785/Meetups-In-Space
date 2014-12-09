require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'
require 'sinatra/reloader'
require 'pry'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @meetups = Meetup.all
  #binding.pry
  erb :index
end

get '/create_meetup' do

  erb :create_meetup
end

post '/create_meetup' do
  new_meetup = Meetup.create(title: params[:title], description: params[:description], location: params[:location], start_date: params[:start_date], start_time: params[:start_time], created_by: current_user.id)

  redirect "/meetup/#{new_meetup.id}"

end

get '/meetup/:id' do
  @meetup = Meetup.find_by id: params[:id]
  @user = User.find_by id: @meetup.created_by

  @all_attendees = Attendee.all.where(meetup_id: @meetup.id)
  @other_attendees = Array.new
  @all_attendees.each do |attendee|
    unless attendee.user_id == session[:user_id]
      @other_attendees << User.find_by(id: attendee.user_id)
    end
  end
  erb :show_meetup
end

post '/add_attendee' do
  Attendee.create(meetup_id: params[:meetup], user_id: current_user.id)

  redirect "/meetup/#{params[:meetup]}"
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
