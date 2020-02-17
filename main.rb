require 'sinatra'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'
require 'v8'
require 'coffee-script'
require './song'
require './sinatra/auth'

configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
    set :email_address => 'not_a_real_email@gmail.com',
        :email_user_name => 'not_a_real_user_name',
        :email_password => 'not_a_real_password',
        :email_domain => 'localhost.localdomain'
end

configure :production do
    DataMapper.setup(:default, ENV["DATABASE_URL"])
    set :email_address => 'smtp.sendgrid.net',
        :email_user_name => ENV['SENDGRID_USERNAME'],
        :email_password => ENV['SENDGRID_PASSWORD'],
        :email_domain => 'heroku.com'
end

helpers do
    def css(*stylesheets) # the * signifies that this function can take any number of arguments.
        stylesheets.map do |stylesheet|
            "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel =\"stylesheet\" />" # this generates
        end.join # the .join here translates multiple inputs into a combined string file which can be injected into the .slim file. Without it we'd end up with an array of text files.    
    end

    def current?(path='/')
        (request.path==path || request.path==path+'/') ? "current" : nil
    end

    def set_title
        @title ||= "Songs By Sinatra"
    end

    def send_message
        Pony.mail(
            :from => params[:name] + "<" + params[:email] + ">",
            :to => 'not_a_real_email@gmail.com',
            :subject => params[:name] + " has contacted you",
            :body => params[:message],
            :port => '587',
            :via => :smtp,
            :via_options => { 
              :address              => 'smtp.gmail.com', 
              :port                 => '587', 
              :enable_starttls_auto => true, 
              :user_name            => 'not_a_real_user_name', 
              :password             => 'not_a_real_password', 
              :authentication       => :plain, 
              :domain               => 'localhost.localdomain'
            }
          )
        end
end 

before do
    set_title
end

DataMapper.finalize

get('/styles.css'){ scss :styles } # This employs the sass helper to tell Sinatra to process this request using Sass using the styles file located within the views directory.
get('/javascripts/application.js'){ coffee :application } # this employs the coffee helper method to tell Sinatra to process the request using CoffeeScript using the application file in the views directory.

get '/' do
    slim :home
end

get '/about' do
    @title = "All About This Website"
    slim :about
end

get '/contact' do
    @title = "Contact Us"
    slim :contact
end

get '/set/:name' do
    session[:name] = params[:name]
end

get '/get/hello' do
    "Hello #{session[:name]}"
end

post '/contact' do
    send_message
    flash[:notice]="Thank you for your message. We'll be in touch soon."
    redirect to('/')
end

not_found do
    slim :not_found
end