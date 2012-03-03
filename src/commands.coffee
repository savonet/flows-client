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

program.commands["Add twitter to radio"] = ->
  program.prompt "Token: ", (token) ->
    radio = _.find program.user.radios, (radio) -> radio.token == token

    if not radio?
      console.error "No such radio!"
      return program.events.emit "ready"

    query "auth-twitter", token, "confirm-twitter", (callback) ->
      console.log "In order to authenticate a twitter account for radio: #{radio.name}"
      console.log "You need to visit that URL:"
      console.log "    #{callback.url}"
      console.log ""
      console.log "There you should take note of the PIN that will be displayed"
      console.log "and report it here."
      console.log ""
      program.prompt "PIN? ", (verifier) ->

        query callback.token, verifier, "authenticated-twitter", (name) ->
          console.log "Authenticated twitter account: #{name} for radio: #{radio.name}!"
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

      args =
        token : radio.token
        name  : name

      query "delete-twitter", args, "deleted-twitter", ->
        console.log ""
        console.log "Twitter account #{name} successfully un-registered for radio: #{radio.name}!"
        console.log ""
        console.log "This account shall not be used by SavonetFlows anymore. However, SavonetFlows"
        console.log "remains authorized for this account. Please visit the account profile to remove"
        console.log "it."
        updateUser()

program.commands["Exit"] = ->
  console.log "Bye!"
  process.exit 0
