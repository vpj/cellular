require 'coffee-script/register'
global.BUILD = 'build'

util = require './build-script/util'
ui = require './build-script/ui'
fs = require 'fs'
{spawn, exec} = require 'child_process'

option '-q', '--quiet',    'Only diplay errors'
option '-w', '--watch',    'Watch files for change and automatically recompile'
option '-c', '--compress', 'Compress files via YUIC'
option '-i', '--inplace',  'Compress files in-place'
option '-m', '--map',  'Source map'

task 'clean', "Cleans up build directory", (opts) ->
 if fs.existsSync "#{BUILD}"
  commands = ["rm -r #{BUILD}/"]
 else
  commands = []

 commands = commands.concat [
  "mkdir #{BUILD}"
 ]

 exec commands.join('&&'), (err, stderr, stdout) ->
  if err?
   util.log stderr.trim(), 'red'
   util.log stdout.trim(), 'red'
   err = 1

  util.finish err

task 'build', "Build all", (opts) ->
 global.options = opts
 buildUi (e) ->
  util.finish e

buildUi = (callback) ->
 ui.assets (e1) ->
  ui.js (e2) ->
   callback e1 + e2
