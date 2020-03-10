require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'slim'
require 'sass'
require 'sinatra/flash'
require './sinatra/auth'

class Song
    include DataMapper::Resource
    property :id, Serial
    property :title, String
    property :lyrics, Text
    property :length, Integer
    property :released_on, Date
    property :likes, Integer, :default => 0  

    def released_on=date
        super Date.strptime(date, '%m/%d/%Y')
    end
end

module SongHelpers
    def find_songs
        @songs = Song.all
    end

    def find_song
        Song.get(params[:id])
    end

    def create_song
        @song = Song.create(params[:song]) # because our form creates a song hash with all the relevant info we can create a new song with a single method.
    end
end

class SongController < Sinatra::Base
    enable :method_override # allows the _method overrides to work.
    register Sinatra::Flash
    register Sinatra::Auth

    helpers SongHelpers

    configure :development do
        DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
    end

    configure :production do
        DataMapper.setup(:default, ENV['DATABASE_URL'])
    end

    before do 
        set_title
    end

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


    get '/' do
        find_songs
        slim :songs
    end

    get '/new' do
        protected!
        @song = Song.new
        slim :new_song
    end

    get '/:id' do
        @song = find_song
        slim :show_song
    end

    get '/:id/edit' do
        protected!
        @song = find_song
        slim :edit_song
    end

    post '/' do
        flash[:notice] = "Song successfully added" if create_song
        redirect to("/#{@song.id}")
    end

    post '/:id/like' do
        @song = find_song
        @song.likes = @song.likes.next # this increases the value of the integer by one
        @song.save
        redirect to("/#{@song.id}") unless request.xhr? # this only redirects if the request was initiated by the user via Ajax.
        slim:like, :layout => false
    end

    put '/:id' do
        song = find_song
        flash[:notice] = "Song successfully updated" if song.update(params[:song])
        redirect to("/#{song.id}")
    end

    delete '/:id' do
        protected!
        flash[:notice] = "Song successfully deleted" if find_song.destroy
        redirect to("/")
    end
end