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
     @$.elems.btn = @button '.u-full-width.button-primary', 'Convert to rows',
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

   @listen 'tableSelect', (r, c, table, event) ->
    @table = table
    if event.shiftKey
     if @columns[c]
      for i in [c..0]
       break if not @columns[i]
       delete @columns[i]
     else
      for i in [c..0]
       break if @columns[i]
       @columns[i] = true
    else
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
     sampleCol = col
     n++
    idHead = "#{id}_0"
    id = "#{id}_1"

    data = {}
    size = @table.size
    for col, i in @table.columns when not @columns[i]
     data[col.id] = []
     for r in [0...size]
      d = @table.data[col.id][r]
      for j in [0...n]
       data[col.id].push d

    @table.size *= n

    data[id] = new Array @table.size
    data[idHead] = new Array @table.size
    m = 0
    for col, i in @table.columns when @columns[i]
     for j in [0...size]
      d = @table.data[col.id][j]
      data[id][m + j * n] = d
      data[idHead][m + j * n] = col.name
     m++

    columns = []
    for col, i in @table.columns
     if not @columns[i]
      columns.push col

    columns.push
     id: idHead
     name: idHead
     type: sampleCol.type
     default: sampleCol.default
    columns.push
     id: id
     name: id
     type: sampleCol.type
     default: sampleCol.default


    @table.columns = columns
    @table.data = data


  OPERATIONS.set ReverseCrossTabulate.type, ReverseCrossTabulate
