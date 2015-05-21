Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class Append extends Base
   @extend()

   name: 'Append Data'
   @name: 'Append Data'
   type: 'appendData'
   @type: 'appendData'

   json: ->
    column: @column
    data: @data

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.status = @p 'Select a column'
     @button on: {click: @$.on.cancel}, 'Cancel'

   renderLoad: ->
    @elems.content.innerHTML = ''
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.file = @input ".input-file", 'Open',
      style: {display: "none"}
      type: "file", on: {change: @$.on.changeFile}

     @button on: {click: @$.on.openFile}, 'Open file'
     @button on: {click: @$.on.cancel}, 'Cancel'

     @button '.button-primary', on: {click: @$.on.loadData}, 'Load'

    Weya elem: @elems.content, context: this, ->
     @$.elems.textArea = @textarea ".textarea-data", '',
      autocomplete: "off"
      spellcheck: "false"

    window.requestAnimationFrame @on.setupEditor


   @listen 'setupEditor', ->
    @textEditor = CodeMirror.fromTextArea @elems.textArea,
     mode: "text"
     lineNumbers: true
     value: "Paste your data here"
     tabSize: 12

    @textEditor.setSize '100%', '100%'

   @listen 'openFile', (e) ->
    e.preventDefault()
    @elems.file.click()

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'loadData', (e) ->
    e.preventDefault()
    text = @textEditor.getValue()
    @data = text.split '\n'
    @callbacks.apply()

   @listen 'tableSelect', (r, c, table) ->
    @table = table
    @column = table.columns[c].id
    @renderLoad()

   apply: ->
    for c in @table.columns
     if c.id is @column
      for d, i in @data
       @table.data[c.id].push d
     for i in [0...@data.length]
       @table.data[c.id].push c.default

    @table.size += @data.length


   @listen 'changeFile', (e) ->
    files = @elems.file.files
    if files.length > 0
     file = files[0]
     reader = new FileReader()
     console.time "readFile"
     reader.onload = (e) =>
      @skipChangeText = true
      @textEditor.setValue reader.result
      reader.result = null

     reader.readAsText file



  OPERATIONS.set Append.type, Append