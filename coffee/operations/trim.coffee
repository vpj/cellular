Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class Trim extends Base
   @extend()

   @initialize ->
    @columns = {}

   operationName: 'Trim'
   @operationName: 'Trim'
   type: 'trim'
   @type: 'trim'

   json: ->
    columns: @columns
    table: @table.id

   setJson: (json) ->
    @columns = json.columns
    @table = @editor.getTable json.table

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.status = @p 'Select columns'

     @button on: {click: @$.on.cancel}, 'Cancel'
     @$.elems.btn = @button '.button-primary', 'Trim',
      on: {click: @$.on.apply}
      style: {display: 'none'}

    @_setData() if @table?

   _setData: ->
    @table.clearHighlight()
    for col, c in @table.columns when @columns[col.id]
     @table.highlight.columns[c] = true
    @table.refresh()
    @refresh()

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'tableSelect', (r, c, table) ->
    if @table? and @table.id isnt table.id
     return

    @table = table
    @table.clearHighlight()
    if @columns[table.columns[c].id] is on
     delete @columns[table.columns[c].id]
     @table.highlight.columns[c] = false
    else
     @columns[table.columns[c].id] = true
     @table.highlight.columns[c] = true
    @table.refresh()
    @refresh()

   refresh: ->
    if @table
     @elems.btn.style.display = 'block'
    else
     @elems.btn.style.display = 'none'

   @listen 'apply', (e) ->
    e.preventDefault()
    @callbacks.apply()

   apply: ->
    for id of @columns
     for i in [0...@table.size]
      @table.data[id][i] = @table.data[id][i].trim()



  OPERATIONS.set Trim.type, Trim
