Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class DelimiterSeparateColumn extends Base
   @extend()

   name: 'Delimiter Separate'
   @name: 'Delimiter Separate'
   type: 'delimiterSeparate'
   @type: 'delimiterSeparate'

   json: ->
    column: @column
    delimiter: @delimiter

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.status = @p 'Select a column'

     @label for: 'delimiter-input', 'Delimiter'
     @$.elems.delimiter = @input '#delimiter-input.u-full-width',
      value: ','
      type: 'text'
      on: {change: @$.on.change}

     @button on: {click: @$.on.cancel}, 'Cancel'
     @$.elems.btn = @button '.button-primary', 'Separate',
      on: {click: @$.on.separate}
      style: {display: 'none'}

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'separate', (e) ->
    e.preventDefault()
    text = @textEditor.getValue()
    @data = text.split '\n'
    @callbacks.apply()

   @listen 'tableSelect', (r, c, table) ->
    @table = table
    @column = table.columns[c].id
    @table.clearHighlight()
    @table.highlight.columns[c] = true
    @table.refresh()
    @refresh()

   @listen 'change', ->
    @refresh()

   refresh: ->
    if @table and @elems.delimiter.value.trim() isnt ''
     @elems.btn.style.display = 'block'
    else
     @elems.btn.style.display = 'none'

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



  OPERATIONS.set DelimiterSeparateColumn.type, DelimiterSeparateColumn
