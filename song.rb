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

helpers SongHelpers

get '/songs' do
    find_songs
    slim :songs
end

get '/songs/new' do
    protected!
    @song = Song.new
    slim :new_song
end

get '/songs/:id' do
    @song = find_song
    slim :show_song
end

get '/songs/:id/edit' do
    protected!
    @song = find_song
    slim :edit_song
end

post '/songs' do
    flash[:notice] = "Song successfully added" if create_song
    redirect to("/songs/#{@song.id}")
end

put '/songs/:id' do
    song = find_song
    flash[:notice] = "Song successfully updated" if song.update(params[:song])
    redirect to("/songs/#{song.id}")
end

delete '/songs/:id' do
    protected!
    flash[:notice] = "Song successfully deleted" if find_song.destroy
    redirect to("/songs")
end