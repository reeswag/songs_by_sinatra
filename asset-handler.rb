class AssetHandler < Sinatra::Base
    configure do
        set :views, File.dirname(__FILE__) + '/assets' # this changes the views folder to a new assets folder.
        set :jsdir, 'js'
        set :cssdir, 'css'
        enable :coffeescript
        set :cssengine, 'scss' # this selects the CSS prprocessor
    end

    get '/javascripts/*.js' do # collects any links to JavaScript files.
        pass unless settings.coffeescript? # pass over this handler and find another matching route if the :coffeescript setting is false.
        last_modified File.mtime(settings.root+'/assets/'+settings.jsdir) # sets the last modified header to the last time the directories were modified.
        cache_control :public, :must_revalidate # requires the client to confirm if the content is up to date at each request.
        coffee (settings.jsdir + '/' + params[:splat].first).to_sym # since we are using a wildcard in the route handler, any route used will be contained in the params[:splat] array.
    end

    get '/*.css' do
        last_modified File.mtime(settings.root+'/assets/'+settings.cssdir)
        cache_control :public, :must_revalidate
        send(settings.cssengine, (settings.cssdir + '/' + params[:splat].first).to_sym) # here we use the send method, this lets us invoke a method from the string stored int the :cssengine settng
    end
end
