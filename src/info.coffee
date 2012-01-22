_       = require "underscore"
program = require "./setup"

program.commands["Display user info"] = ->
  console.log "User info:"

  # Reduce verbosity for radios..
  user = _.clone program.user
  user.radios = _.map user.radios, (radio) ->
    name  : radio.name
    token : radio.token

  console.dir user
  program.events.emit "ready"

program.commands["Get radio info"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token
    if radio?
      console.dir radio
    else
      console.error "No such radio!"
    program.events.emit "ready"

