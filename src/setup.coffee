io   = require "socket.io-client"

program = require "commander"

# Setup event notifications to deal with asynchronous 
# tasks in the program.
{EventEmitter} = require "events"
program.events = events = new EventEmitter()

program
  .version("0.0.1")
  .option("-u, --user [user]", "Specify user")
  .option("-U, --url [url]", "Specify url, defaults to http://flows.liquidsoap.fm/admin", "http://flows.liquidsoap.fm/admin")
  .parse process.argv

program.commands = {}

events.on "user", ->
  program.password "Password: ", "*", (password) ->
    program.password = password
    events.emit "password"

events.on "password", ->
  program.socket = socket = io.connect program.url
  socket.emit "sign-in",
    user     : program.user
    password : program.password

  onError = (err) ->
    console.error "Error while signing in!"
    console.dir err if err?
    process.exit 1

  socket.on "error", onError
  socket.on "signed-in", (user) ->
    program.user = user
    socket.removeListener "error", onError
    
    console.log "Signed in!"
    events.emit "ready"

if program.user?
  events.emit "user"
else
  program.prompt "User: ", (user) ->
    program.user = user
    events.emit "user"

module.exports = program
