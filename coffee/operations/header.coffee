Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class Header extends Base
   @extend()

   @initialize ->
    @elems.inputs = {}

   operationName: 'Header'
   @operationName: 'Header'
   type: 'header'
   @type: 'header'

   json: ->
    column: @column
    delimiter: @delimiter

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @label for: 'toprows-input', 'Top rows'
     @$.elems.topRows = @input '#toprows-input.u-full-width',
      value: '0'
      type: 'number'
      on: {change: @$.on.change}
     @label for: 'bottomrows-input', 'Bottom rows'
     @$.elems.bottomRows = @input '#bottomrows-input.u-full-width',
      value: '0'
      type: 'number'
      on: {change: @$.on.change}

     @$.elems.inputsDiv = @div
      on: {click: @$.on.removeClick}

     @button on: {click: @$.on.cancel}, 'Cancel'
     @$.elems.btn = @button '.button-primary', 'Header',
      on: {click: @$.on.apply}
      style: {display: 'none'}

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'apply', (e) ->
    e.preventDefault()
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

    top = parseInt @elems.topRows.value
    top = -1 if isNaN top
    bottom = parseInt @elems.bottomRows.value
    bottom = -1 if isNaN bottom

    @top = top
    @bottom = bottom

    if n > 0 and bottom >= 0 and top >= 0
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
    @search = {}
    for id, elems of @elems.inputs
     @search[id] = elems.input.value

    top = parseInt @elems.topRows.value
    top = -1 if isNaN top
    bottom = parseInt @elems.bottomRows.value
    bottom = -1 if isNaN bottom

    @top = top
    @bottom = bottom

    highlight = (true for i in [0...@table.size])
    for id, s of @search
     regex = new RegExp s, ''
     for d, r in @table.data[id]
      if not regex.test d
       highlight[r] = false

    columns = []
    table = {}
    for col in @table.columns
     data = @table.data[col.id]
     for i in [1..@top + @bottom + 1]
      columns.push
       id: "#{col.id}_#{i}"
       name: "#{col.id}_#{i}"
       type: col.type
       default: col.default
      table["#{col.id}_#{i}"] = []
     i = 0
     columns.push
      id: "#{col.id}_#{i}"
      name: "#{col.id}_#{i}"
      type: col.type
      default: col.default
     table["#{col.id}_#{i}"] = []
     values = (undefined for [0..@top + @bottom])
     detail = 0
     for d, r in highlight when d
      @_addRows table, col.id, values, detail, r
      values = (for hr in [r - @top..r + @bottom]
       if hr < 0 or hr >= @table.size
        undefined
       else
        @table.data[col.id][hr])
      detail = r + @bottom + 1

     @_addRows table, col.id, values, detail, @table.size + @top

     @table.size = table["#{col.id}_0"].length

    @table.data = table
    @table.columns = columns

   _addRows: (table, id, values, detail, header) ->
    return if detail >= header - @top
    for i in [0..@top + @bottom]
     c = "#{id}_#{i + 1}"
     table[c].push values[i] for r in [detail...header - @top]
    c = "#{id}_0"
    table[c].push @table.data[id][r] for r in [detail...header - @top]



  OPERATIONS.set Header.type, Header
