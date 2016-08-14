Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class SearchRows extends Base
   @extend()

   @initialize ->
    @elems.inputs = {}

   operationName: 'Search & Process'
   @operationName: 'Search & Process'
   type: 'searchRows'
   @type: 'searchRows'

   json: ->
    table: @table.id
    search: @search
    func: @func

   setJson: (json) ->
    @search = json.search
    @func = json.func
    @table = @editor.getTable json.table

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.inputsDiv = @div
      on: {click: @$.on.removeClick}

     @div ->
      @$.elems.func = @textarea "#search-func.u-full-width",
       value: '-> false'
       on: {change: @$.on.change}

     @$.elems.btn = @button '.u-full-width.button-primary', 'Apply',
      on: {click: @$.on.apply}
     @button '.u-full-width', on: {click: @$.on.cancel}, 'Cancel'

    @_setData() if @table?

   _setData: ->
    for id of @search
     name = id
     for col in @table.columns when col.id is id
      name = col.name
     @addInputs id, name
    @elems.func.value = @func

    @refresh()

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'tableSelect', (r, c, table) ->
    @table = table
    id = table.columns[c].id
    @addInputs id, table.columns[c].name
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

   addInputs: (id, name) ->
    if @elems.inputs[id]?
     @elems.inputsDiv.removeChild @elems.inputs[id].div

    Weya elem: @elems.inputsDiv, context: this, ->
     elems = {}
     elems.div = @div ->
      elems.label = @label for: "search-#{id}", ->
       @span name
       elems.remove = @span '.remove', 'X'
     elems.remove._id = id
     @$.elems.inputs[id] = elems

   @listen 'apply', (e) ->
    e.preventDefault()
    @search = {}
    @search[id] = true for id of @elems.inputs
    @func = @elems.func.value
    @callbacks.apply()


   refresh: ->
    @search = {}
    @search[id] = true for id of @elems.inputs
    @func = @elems.func.value
    try
     text = @func
     coffee = CoffeeScript.compile "return (#{text})"
     console.log coffee
     func = new Function "return #{coffee}"
     func = func()
     @elems.func.style.background = "white"
    catch e
     console.error e.message
     @elems.func.style.background = "red"
     func = -> false

    @table.highlight.rows = {}
    @table.highlight.onlyHighlightedRows = true
    highlight = (true for i in [0...@table.size])
    for r in [0...@table.size]
     args = (@table.data[id][r] for id of @search)
     result = func.apply null, args
     if result? and result isnt false
      highlight[r] = true
     else
      highlight[r] = false

    for d, r in highlight when d
     @table.highlight.rows[r] = true

    @table.refresh()

   apply: ->
    try
     text = @func
     coffee = CoffeeScript.compile "return (#{text})"
     func = new Function "return #{coffee}"
     func = func()
    catch e
     func = -> false

    deleteRows = {}
    for r in [0...@table.size]
     args = (@table.data[id][r] for id of @search)
     result = func.apply null, args
     if result? and result isnt false
      if result.delete
       deleteRows[r] = true
      else if result.replace?
       c = 0
       for id of @search
        @table.data[id][r] = result.replace[c]
        ++c

    for id, data of @table.data
     @table.data[id] = (d for d, r in data when not deleteRows[r])
     @table.size = @table.data[id].length




  OPERATIONS.set SearchRows.type, SearchRows
