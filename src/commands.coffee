_       = require "underscore"
program = require "./setup"

updateUser = ->
  program.socket.emit "get-user"

  onError = (err) ->
    console.log "Error while updating user!"
    console.dir err if err?
    program.events.emit "ready"

  program.socket.on "error", onError
  program.socket.on "user", (user) ->
    program.user = user
    program.socket.removeListener "error", onError
    program.events.emit "ready"

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

program.commands["Edit radio name"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token

    if not radio?
      console.error "No such radio!"
      return program.events.emit "ready"

    program.prompt "Name: ", (name) ->
      update = _.clone radio
      update.name = name

      console.log ""
      console.log "-- Radio #{token} --"
      console.log "Setting name to #{name}"
      console.log ""
      console.log "WARNING: Once name has been updated, ALL submissions for this radio"
      console.log "should use the new name."
      console.log ""
      console.log "Make sure that you stop submitting before updating the name and"
      console.log "restart with the new name afterwards."

      program.confirm "proceed? ", (ok) ->
        unless ok
          console.log "Canceled"
          return program.events.emit "ready"

        program.socket.emit "edit-radio", update

        onError = (err) ->
          console.log "Edition failed!"
          console.dir err if err?
          program.events.emit "ready"

        program.socket.once "error", onError
        program.socket.once "edited-radio", ->
          console.log "Name successfuly edited!"
          program.socket.removeListener "error", onError
          updateUser()

program.commands["Delete radio"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token

    if not radio?
      console.error "No such radio!"
      return program.events.emit "ready"

    console.log ""
    program.prompt "DELETE radio #{radio.name} with token #{token}? ", (ok) ->
      unless ok
        console.log "Canceled"
        return program.events.emit "ready"

      program.socket.emit "delete-radio", token

      onError = (err) ->
        console.log "Delete failed!"
        console.dir err if err?
        program.events.emit "ready"

      program.socket.once "error", onError
      program.socket.once "deleted-radio", ->
        console.log "Radio successfully deleted!"
        program.socket.removeListener "error", onError
        updateUser()

program.commands["Exit"] = ->
  console.log "Bye!"
  process.exit 0
