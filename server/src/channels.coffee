# SauceBot channel data

Sauce = require './sauce'

db    = require './saucedb'
users = require './users'

io    = require './ioutil'
mod   = require './module'

sys   = require 'sys'

# Module names
moduleNames = Object.keys mod.MODULES

# Channel list - indexed by channel name
channels = {}

# Name list for quick chanid -> channel name lookup
names = {}

class Channel
    constructor: (data) ->
        @id   = data.chanid
        @name = data.name
        @desc = data.description
   
        @modules = []
        @loadChannelModules()
    
    addModule: (moduleName) ->
        try
            module = mod.instance moduleName
            module.load this

            priority = module.priority()
            index = 0
            index++ for md in @modules when priority >= md.priority()
            
            io.debug "Index of #{moduleName} = #{index}"
            
            @modules.splice index, 0, module
            io.debug "[#{[md.priority() for md in @modules].join ','}]"
        catch error
            io.error "#{error}"
            sys.puts error.stack
    
    loadChannelModules: ->
        db.getChanDataEach @id, 'module', (result) =>
            @addModule result.module
            io.debug "Channel #{@name} uses module #{result.module}"
        , =>
            io.debug "Done loading modules for #{@name}"
            
            
    getUser: (username, op) ->
        op = null unless op
        
        chan = @name
        user = users.getByName username
        
        if (user?)
            return {
                name: user.name
                op  : op or user.isMod chan
            }
        return {
            name: username
            op  : op
        }

    handle: (data, sendMessage, finished) ->
        user      = @getUser data.user, data.op
        command   = data.cmd
        arguments = data.args
        
        for module in @modules
            module.handle user, command, arguments, sendMessage
        
        finished() if finished?
        
        

# Handles a message in the appropriate channel instance
exports.handle = (channel, data, sendMessage, finished) ->
    channels[channel].handle data, sendMessage, finished
    
# Loads the channel list
exports.load = (finished) ->
    # Clear the channel list
    channels = {}
    names    = {}
    
    db.getDataEach 'channel', (chan) ->
        id   = chan.chanid
        name = chan.name.toLowerCase()
        desc = chan.description
        
        channel        = new Channel chan
        channels[name] = channel
        names[id]      = name
        
    , ->
        finished channels if finished?

    
