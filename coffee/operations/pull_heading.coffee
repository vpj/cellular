Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class PullHeadings extends Base
   @extend()

   @initialize ->
    @elems.inputs = {}

   operationName: 'Pull Headings'
   @operationName: 'Pull Headings'
   type: 'pullHeadings'
   @type: 'pullHeadings'

   json: ->
    table: @table.id
    row: @row

   setJson: (json) ->
    @row = json.row
    @table = @editor.getTable json.table

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
    @row = r
    @refresh()

   refresh: ->
    @table.highlight.rows = {}
    if @row?
     @table.highlight.rows[@row] = true
     @elems.btn.style.display = 'block'
    else
     @elems.btn.style.display = 'none'


    @table.refresh()

   apply: ->
    return if not @row?

    for col, i in @table.columns
     name = @table.data[col.id][@row]
     name = name.trim()
     continue if name is ''
     continue if @table.data[name]?
     temp = @table.data[col.id]
     delete @table.data[col.id]
     @table.data[name] = temp
     col.id = col.name = name

    for id, data of @table.data
     @table.data[id] = (v for v, r in data when r isnt @row)
     @table.size = @table.data[id].length



  OPERATIONS.set PullHeadings.type, PullHeadings
