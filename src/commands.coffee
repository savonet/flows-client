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

program.commands["Add twitter to radio"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token

    if not radio?
      console.error "No such radio!"
      return program.events.emit "ready"
  
    program.socket.emit "auth-twitter", token

    onError = (err) ->
      console.log "Authentication failed!"
      console.dir err if err?
      program.events.emit "ready"

    program.socket.once "error", onError
    program.socket.once "confirm-twitter", (callback) ->
      console.log "In order to authenticate a twitter account for radio: #{radio.name}"
      console.log "You need to visit that URL:"
      console.log "    #{callback.url}"
      console.log ""
      console.log "There you should take note of the PIN that will be displayed"
      console.log "and report it here."
      console.log ""
      program.prompt "PIN? ", (verifier) ->
        program.socket.emit callback.token, verifier
      
        program.socket.once "authenticated-twitter", (name) ->
          console.log "Authenticated twitter account: #{name} for radio: #{radio.name}!"
          program.socket.removeListener "error", onError
          updateUser()

program.commands["Remove twitter from radio"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token

    if not radio?
      console.error "No such radio!"
      return program.events.emit "ready"

    program.prompt "Twitter screen name: ", (name) ->
      ok = _.any radio.twitters, (twitter) -> twitter == name
      unless ok
         console.error "This account is not authenticated for radio: #{radio.name}!"
         return program.events.emit "ready"

      program.socket.json.emit "delete-twitter",
        token : radio.token
        name  : name

      onError = (err) ->
        console.log "Operation failed!"
        console.dir err if err?
        program.events.emit "ready"

      program.socket.once "error", onError
      program.socket.once "deleted-twitter", ->
        console.log ""
        console.log "Twitter account #{name} successfully un-registered for radio: #{radio.name}!"
        console.log ""
        console.log "This account shall not be used by SavonetFlows anymore. However, SavonetFlows"
        console.log "remains authorized for this account. Please visit the account profile to remove"
        console.log "it."
        
        program.socket.removeListener "error", onError
        updateUser()

program.commands["Exit"] = ->
  console.log "Bye!"
  process.exit 0
