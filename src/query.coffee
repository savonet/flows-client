_       = require "underscore"
program = require "./setup"

module.exports = (event, args, response, handler) ->
  unless handler?
    handler  = response
    response = args
    args = []

  unless _.isArray args
    args = [args]
  
  onError = (err) ->
    console.log "Error while updating user!"
    console.dir err if err?
    program.socket.removeListener response, onResponse
    program.events.emit "ready"

  onResponse = ->
    program.socket.removeListener "error", onError
    handler.apply this, arguments

  program.socket.once "error",  onError
  program.socket.once response, onResponse

  args.unshift event
  program.socket.emit.apply program.socket, args
  

