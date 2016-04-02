util = require './util'
fs = require 'fs'
index = require '../ui-assets/index.coffee'
{spawn, exec} = require 'child_process'

UI_JS = [
 'main'
 'editor'
 'table'
 'operations'
 'operations/add_data_column'
 'operations/delete_columns'
 'operations/pull_heading'
 'operations/append_data'
 'operations/delimiter_separate_column'
 'operations/search_delete_rows'
 'operations/header'
 'operations/width_split_column'
 'operations/trim'
 'operations/reverse_cross_tabulate'
 'operations/export'
]

UI_LESS = ['style']

assets = exports.assets = taskUiAssets = (callback) ->
 commands = []
 if fs.existsSync "#{BUILD}/lib"
  commands.push "rm -r #{BUILD}/lib"
 if fs.existsSync "#{BUILD}/css"
  commands.push "rm -r #{BUILD}/css"
 if fs.existsSync "#{BUILD}/assets"
  commands.push "rm -r #{BUILD}/assets"

 commands = commands.concat [
  "mkdir #{BUILD}/css"
  "mkdir #{BUILD}/assets"
  "mkdir #{BUILD}/lib"
  "mkdir #{BUILD}/lib/weya"
  "mkdir #{BUILD}/lib/mod"
  "mkdir #{BUILD}/lib/dsv"
 ]

 commands = commands.concat [
  "cp -r ui-assets/lib/* #{BUILD}/lib/"
  "cp -r ui-assets/assets/* #{BUILD}/assets/"
 ]


 exec commands.join('&&'), (e, stderr, stdout) ->
  if e?
   util.log stderr.trim(), 'red'
   util.log stdout.trim(), 'red'
   e = 1
   callback e
   return

  e = 0
  e += html()

  css (e1) ->
   e += e1
   e += util.jsDir "lib/weya/", "#{BUILD}/lib/weya"
   e += util.jsDir "lib/dsv/", "#{BUILD}/lib/dsv"
   e += util.jsDir "lib/mod/", "#{BUILD}/lib/mod"

   callback e

html = exports.html = ->
 files = []
 for file in UI_JS
  files.push "js/#{file}.js"

 try
  htmlCode = index.html scripts: files

  fs.writeFileSync "#{BUILD}/index.html", htmlCode

  util.log " - index.html" unless options.quiet
  return 0
 catch err
  util.log " - index.html", 'red'
  util.log "  ^ #{err}", 'red'
  return 1

css = exports.css = (callback) ->
 filesToWatch = UI_LESS

 filesToWatch = ("ui-assets/less/#{f}.less" for f in filesToWatch)

 util.css "ui-assets/less/",
  "ui-assets/less/style.less"
  "#{BUILD}/css/style.css"
  (e1) ->
   util.watch filesToWatch, css, []
   callback? e1

dirList = (files) ->
 dirs = {}
 for file in files
  parts = file.split '/'
  d = dirs
  for i in [0...parts.length - 1]
   d[parts[i]] ?= {}
   d = d[parts[i]]

 list = []
 getDirs = (prefix, d) ->
  for k of d
   list.push "#{prefix}#{k}"
   getDirs "#{prefix}#{k}/", d[k]

 getDirs '', dirs

 return list


exports.js = (callback) ->
 mkdir = dirList UI_JS
 if fs.existsSync "#{BUILD}/js"
  commands = ["rm -r #{BUILD}/js"]
 else
  commands = []

 commands.push "mkdir #{BUILD}/js"
 for d in mkdir
  commands.push "mkdir #{BUILD}/js/#{d}"

 exec commands.join('&&'), (e, stderr, stdout) ->
  if e?
   util.log stderr.trim(), 'red'
   util.log stdout.trim(), 'red'
   e = 1
  else
   e = 0
   for file in UI_JS
    if fs.existsSync "coffee/#{file}.coffee"
     e += util.js "coffee/#{file}.coffee", "#{BUILD}/js/#{file}.js"
    else
     e += util.js "coffee/#{file}.litcoffee", "#{BUILD}/js/#{file}.js"

  callback e

