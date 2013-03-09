_       = require "underscore"
program = require "./setup"
query   = require "./query"

updateUser = ->
  query "get-user", "user", (user) ->
    program.user = user
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

        query "edit-radio", update, "edited-radio", ->
          console.log "Name successfuly edited!"
          updateUser()

program.commands["Edit radio location"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token

    if not radio?
      console.error "No such radio!"
      return program.events.emit "ready"

    update = _.clone radio

    program.prompt "Latitude: ", (lat) ->
      update.latitude = lat

      program.prompt "Longitude: ", (long) ->
        update.longitude = long

        query "edit-radio", update, "edited-radio", ->
          console.log "Location successfuly edited!"
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

      query "delete-radio", token, "deleted-radio", ->
        console.log "Radio successfully deleted!"
        updateUser()

program.commands["Exit"] = ->
  console.log "Bye!"
  process.exit 0
