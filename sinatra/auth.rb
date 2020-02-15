require 'sinatra/base' # every extension needs this requirement - it is the core of sinatra minus the code for the actual application
require 'sinatra/flash' # not essential but used here to display flash messages.

module Sinatra
    module Auth # the extension is a nested module, the standard structure for Sinatra extensions.
        module Helpers # helper methods within the extension have their own nested module at the start of the extension.
            def authorised? # checks to see if the admin is logged in ie true
                session[:admin]
            end

            def protected! # protects routes unless the admin is logged in.
                halt 401,slim(:unauthorised) unless authorised?
            end
        end

        def self.registered(app) # this contains all the settings for the extension, registers the Helpers module as a helper module and contains specific route handlers relevant to the extension.
            app.helpers Helpers

            app.enable :sessions # all methods need to me registered to be methods of the app object, which is the argument passed to self.registered and is effectively the app using the extension.

            app.set :username => 'frank', :password => 'sinatra' # all settings can be overwritten by the app, these act as default settings for the extension.
            
            app.get '/login' do
                slim :login
            end

            app.post '/login' do
                if params[:username] == settings.username && params[:password] == settings.password
                    session[:admin] = true
                    flash[:notice] = "Your are now logged in as #{settings.username}."
                    redirect to('/songs')
                else
                    flash[:notice] = "The username or password you entered are incorrect."
                    redirect to ('/login')
                end
            end

            app.get '/logout' do
                session[:admin] = nil
                flash[:notice] = "You have now logged out"
                redirect to('/')
            end
        end
    end
    register Auth # this registers the extension and needs to be added at the bottom of the extension file.
end

