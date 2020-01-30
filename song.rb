require 'dm-core'
require 'dm-migrations'
require 'sinatra'

class Song
    include DataMapper::Resource
    property :id, Serial
    property :title, String
    property :lyrics, Text
    property :length, Integer
    property :released_on, Date 

    def released_on=date
        super Date.strptime(date, '%m/%d/%Y')
    end
end

get '/songs' do
    @songs = Song.all
    slim :songs
end

get '/songs/new' do
    halt(401, "Not Authorized") unless session[:admin]
    @song = Song.new
    slim :new_song
end

get '/songs/:id' do
    @song = Song.get(params[:id])
    slim :show_song
end

get '/songs/:id/edit' do
    halt(401, "Not Authorized") unless session[:admin]
    @song = Song.get(params[:id])
    slim :edit_song
end

post '/songs' do
    halt(401, "Not Authorized") unless session[:admin]
    song = Song.create(params[:song]) # because our form creates a song hash with all the relevant info we can create a new song with a single method.
    redirect to("/songs/#{song.id}")
end

put '/songs/:id' do
    halt(401, "Not Authorized") unless session[:admin]
    song = Song.get(params[:id])
    song.update(params[:song])
    redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
    halt(401, "Not Authorized") unless session[:admin]
    Song.get(params[:id]).destroy
    redirect to("/songs")
end