# SauceBot Module Loader

fs = require 'fs'
io = require './ioutil'
db = require './saucedb'

PATH = './modules/'

exports.MODULES = {}

INFO_TABLE = 'moduleinfo'

loadModule = (name) ->
    try
        module = require "#{PATH}#{name.toLowerCase()}" 
        io.debug "Loaded module #{module.name}(#{name.toLowerCase()}) v#{module.version}"
        exports.MODULES[module.name] = module
        
        {name, description, version} = module
        locked       = (if module.locked then 1 else 0)
        defaultstate = (if module.ignore then 0 else 1)
        
        db.addData INFO_TABLE, ['name', 'description', 'version', 'defaultstate', 'locked'], [[name, description, version, defaultstate, locked]]

    catch error
      io.error "Could not load module #{name}: #{error}"


db.clearTable INFO_TABLE

fs.readdirSync(PATH).forEach (file) ->
    return unless match = /(\w+)\.js$/i.exec file
    loadModule(match[1])
 
exports.instance = (name, chan) ->
    if (!exports.MODULES[name]?)
        throw new Error "No such module '#{name}'" unless loadModule name
        
    module = exports.MODULES[name]
    
    if (!module.New?)
        throw new Error "Invalid module '#{name}'"
        
    obj = module.New chan
    
    obj.name        = module.name
    obj.description = module.description
    obj.version     = module.version
    return obj
