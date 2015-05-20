Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'

  AAString = (n) ->
   return 'A' if n is 0
   s = ''
   while n > 0
    s += CHARS[n % CHARS.length]
    n = n // CHARS.length
   rev = ''
   for i in [1..s.length]
    rev += s[s.length - i]
   return rev

  class AddColumn extends Base
   @extend()

   name: 'Add Column'
   @name: 'Add Column'
   type: 'addColumn'
   @type: 'addColumn'

   json: ->
    columns: @columns

   render: ->
    @elems.sidebar.innerHTML = ''
    @elems.content.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.file = @input ".input-file", 'Open',
      style: {display: "none"}
      type: "file", on: {change: @$.on.changeFile}

     @button on: {click: @$.on.openFile}, 'Open file'

     @button '.button-primary', on: {click: @$.on.loadData}, 'Load'
     @button on: {click: @$.on.cancel}, 'Cancel'

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
    @table = @editor.getTable()
    @callbacks.apply()

   apply: ->
    if @data.length < @table.size
     for i in [0...@table.size - @data.length]
      @data.push ''
    else if @data.length > @table.size
     for c in @table.columns
      for i in [0..@data.length - @table.size]
        @table.data[c.id].push c.default

    ids = {}
    for c in @table.columns
     ids[c.id] = true

    id = 'A'
    for i in [0...@table.columns.length]
     id = AAString i
     break if not ids[id]?

    @table.columns.push
     id: id
     name: id
     type: 'string'
     default: ''
    @table.data[id] = @data
    @table.size = @data.length


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



  OPERATIONS.set AddColumn.type, AddColumn
