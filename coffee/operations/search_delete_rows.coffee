Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class SearchDeleteRows extends Base
   @extend()

   @initialize ->
    @elems.inputs = {}

   operationName: 'Search and Delete Rows'
   @operationName: 'Search and Delete Rows'
   type: 'searchDeleteRows'
   @type: 'searchDeleteRows'

   json: ->
    column: @column
    delimiter: @delimiter

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.inputsDiv = @div
      on: {click: @$.on.removeClick}

     @button on: {click: @$.on.cancel}, 'Cancel'
     @$.elems.btn = @button '.button-primary', 'Delete',
      on: {click: @$.on.apply}
      style: {display: 'none'}

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'apply', (e) ->
    e.preventDefault()
    text = @textEditor.getValue()
    @data = text.split '\n'
    @callbacks.apply()

   @listen 'tableSelect', (r, c, table) ->
    @table = table
    id = table.columns[c].id
    @addInputs id, table.columns[c].name, table.data[id][r]
    @refresh()

   @listen 'change', ->
    @refresh()

   @listen 'removeClick', (e) ->
    n = e.target
    while n?
     if n._id?
      @elems.inputsDiv.removeChild @elems.inputs[n._id].div
      delete @elems.inputs[n._id]
      @refresh()
     n = n.parentNode

   addInputs: (id, name, search) ->
    if @elems.inputs[id]?
     @elems.inputsDiv.removeChild @elems.inputs[id].div

    Weya elem: @elems.inputsDiv, context: this, ->
     elems = {}
     elems.div = @div ->
      elems.label = @label for: "search-#{id}", name
      elems.input = @input "#search-#{id}",
       value: search
       type: 'text'
       on: {change: @$.on.change}
      elems.remove = @button 'Remove'
     elems.remove._id = id
     @$.elems.inputs[id] = elems

   refresh: ->
    @search = {}
    n = 0
    for id, elems of @elems.inputs
     @search[id] = elems.input.value
     n++

    if n > 0
     @elems.btn.style.display = 'block'
    else
     @elems.btn.style.display = 'none'

    @table.highlight.rows = {}
    highlight = (true for i in [0...@table.size])
    for id, s of @search
     regex = new RegExp s, ''
     for d, r in @table.data[id]
      if not regex.test d
       highlight[r] = false

    for d, r in highlight when d
     @table.highlight.rows[r] = true

    @table.refresh()

   apply: ->
    cidx = -1
    for c, i in @table.columns when c.id is @column
     cidx = i

    data = @table.data[@column].join '\n'
    data = dsv
     separator: @delimiter
     quote: @quote.charCodeAt 0
     text: data

    nColumns = data.length
    col = @table.columns[cidx]
    args = [cidx, 1]
    for i in [1..nColumns]
     args.push
      id: "#{col.id}_#{i}"
      name: "#{col.name}_#{i}"
      type: 'string'
      default: ''

    @table.columns.splice.apply @table.columns, args
    for d, i in data
     @table.data["#{col.id}_#{i + 1}"] = d



  OPERATIONS.set SearchDeleteRows.type, SearchDeleteRows
