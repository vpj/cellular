Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  PADDING = 2

  class WidthSplitColumn extends Base
   @extend()

   @initialize ->
    @elems.inputs = []
    @elems.lines = []

   operationName: 'Width Split Column'
   @operationName: 'Width Split Column'
   type: 'widthSplitColumn'
   @type: 'widthSplitColumn'

   json: ->
    column: @column
    table: @table.id
    offsets: @offsets

   setJson: (json) ->
    @offsets = json.offsets
    @column = json.column
    @table = @editor.getTable json.table

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.status = @p 'Select a column'

     @$.elems.inputsDiv = @div ''

     @button on: {click: @$.on.cancel}, 'Cancel'
     @$.elems.btn = @button '.button-primary', 'Split',
      on: {click: @$.on.apply}
      style: {display: 'none'}

    @_setData() if @table?

   _setData: ->
    n = @offsets.length
    for i in [1...n]
     split = @offsets[i] - @offsets[i - 1]
     @_addInput split

    @refresh()

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

   @listen 'apply', (e) ->
    e.preventDefault()
    offset = 0
    @offsets = [0]
    for elems in @elems.inputs
     v  = parseInt elems.input.value
     continue if isNaN v
     continue if v is 0
     offset += v
     @offsets.push offset

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

   _addInput: (split) ->
    split ?= 0
    n = @elems.inputs.length
    Weya elem: @elems.inputsDiv, context: this, ->
     elems = {}
     elems.div = @div ->
      @label for: "split-#{n}", "Split #{n + 1}"
      elems.input = @input "#split-#{n}",
       value: "#{split}"
       type: 'number'
       on: {change: @$.on.change}
     @$.elems.inputs.push elems

   _removeLines: ->
    elem = @table.elems.container
    for line in @elems.lines
     elem.removeChild line

    @elems.lines = []

   _addLine: (offset) ->
    for col in @table.columns
     break if col.id is @column
     offset += col.width
    offset += PADDING
    Weya elem: @table.elems.container, context: this, ->
     @$.elems.lines.push @div '.split-line', style: {left: "#{offset}px"}

   refresh: ->
    if not @table?
     @elems.btn.style.display = 'none'
     return

    @_removeLines()

    zero = false
    offset = 0
    for elems in @elems.inputs
     v  = parseInt elems.input.value
     continue if isNaN v
     zero = (v is 0)
     continue if v is 0
     offset += v * @table.dims.charWidth
     @_addLine offset

    if not zero
     @_addInput()

    if offset > 0
     @elems.btn.style.display = 'block'
    else
     @elems.btn.style.display = 'none'

   apply: ->
    cidx = -1
    for c, i in @table.columns when c.id is @column
     cidx = i

    nColumns = @offsets.length
    col = @table.columns[cidx]
    args = [cidx, 1]
    for i in [1..nColumns]
     args.push
      id: "#{col.id}_#{i}"
      name: "#{col.name}_#{i}"
      type: 'string'
      default: ''

    @table.columns.splice.apply @table.columns, args
    data = ([] for i in [0...nColumns])
    for r in [0...@table.size]
     v = "#{@table.data[col.id][r] or col.default}"
     for i in [0...nColumns]
      data[i].push v.substring @offsets[i], @offsets[i + 1]

    delete @table.data[col.id]
    for d, i in data
     @table.data["#{col.id}_#{i + 1}"] = d



  OPERATIONS.set WidthSplitColumn.type, WidthSplitColumn
