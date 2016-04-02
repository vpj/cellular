Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class ReverseCrossTabulate extends Base
   @extend()

   @initialize ->
    @elems.inputs = {}
    @columns = {}

   operationName: 'Reverse Cross Tabulate'
   @operationName: 'Reverse Cross Tabulate'
   type: 'reverseCrossTabulate'
   @type: 'reverseCrossTabulate'

   json: ->
    table: @table.id
    columns: @columns

   setJson: (json) ->
    @table = @editor.getTable json.table
    @columns = json.columns

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.btn = @button '.u-full-width.button-primary', 'Delete',
      on: {click: @$.on.apply}
      style: {display: 'none'}
     @button '.u-full-width', on: {click: @$.on.cancel}, 'Cancel'

    @refresh() if @table?

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'apply', (e) ->
    e.preventDefault()
    @callbacks.apply()

   @listen 'tableSelect', (r, c, table) ->
    @table = table
    if @columns[c]
     delete @columns[c]
    else
     @columns[c] = true
    @refresh()

   refresh: ->
    n = 0
    n++ for c of @columns
    if n > 1
     @elems.btn.style.display = 'block'
    else
     @elems.btn.style.display = 'none'

    @table.highlight.columns = {}
    for c of @columns
     @table.highlight.columns[c] = true

    @table.refresh()

   apply: ->
    n = 0
    for col, i in @table.columns when @columns[i]
     id = col.id
     n++
    id = "#{id}_0"

    data = {}
    for col, i in @table.columns when not @columns[i]
     data[col.id] = []
     for d in @table.data[col.id]
      for j in [0...n]
       data[col.id].push d

    @table.size *= n

    data[id] = new Array @table.size
    m = 0
    for col, i in @table.columns when @columns[i]
     for d, j in @table.data[col.id]
      data[id][m + j * n] = d
     m++

    columns = []
    for col, i in @table.columns
     if not @columns[i]
      columns.push col

    @table.columns = columns
    @table.data = data


  OPERATIONS.set ReverseCrossTabulate.type, ReverseCrossTabulate
