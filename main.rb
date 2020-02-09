require 'sinatra'
require 'slim'
require 'sass'
require 'sinatra/flash'
require 'pony'
require './song'

configure do
    enable :sessions
    set :username, 'frank'
    set :password, 'sinatra'
end

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
    def css(*stylesheets)
        stylesheets.map do |stylesheet|
            "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel =\"stylesheet\" />"
        end.join   
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

get('/styles.css'){ scss :styles }

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

get '/login' do 
    slim :login
end

get '/logout' do 
    session.clear
    redirect to('/login')
end

post '/login' do
    if params[:username] == settings.username && params[:password] == settings.password
        session[:admin] = true
        redirect to('/songs')
    else
        slim :login
    end
end

post '/contact' do
    send_message
    flash[:notice]="Thank you for your message. We'll be in touch soon."
    redirect to('/')
end

not_found do
    slim :not_found
end