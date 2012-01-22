Flows command-line client
=========================

This is the command-line client for [savonet Flows](http://liquidsoap.fm/flows.html) service.
It provides administration commands for flows users to update their radio's name, see listeners, 
setup a twitter relay, etc..

Install
=======

First, grab the sources, install [node](http://nodejs.org/) and (npm)[http://npmjs.org/]. 
Please note that due to an [this issue](https://github.com/LearnBoost/socket.io-client/issues/372), 
node `0.6.x` does not work for this application at the moment.

Then install all dependencies:

    npm install

You should now be able to run the `flow` command:

    toots@zulu client  % ./flow --help

      Usage: flow [options]

      Options:

        -h, --help         output usage information
        -V, --version      output the version number
        -u, --user [user]  Specify user
        -U, --url [url]    Specify url, defaults to http://flows.liquidsoap.fm/admin 


Usage
=====

_TODO_
