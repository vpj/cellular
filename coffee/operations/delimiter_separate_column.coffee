Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class DelimiterSeparateColumn extends Base
   @extend()

   operationName: 'Delimiter Separate'
   @operationName: 'Delimiter Separate'
   type: 'delimiterSeparate'
   @type: 'delimiterSeparate'

   json: ->
    column: @column
    delimiter: @delimiter
    quote: @quote
    table: @table.id

   setJson: (json) ->
    @column = json.column
    @delimiter = json.delimiter
    @quote = json.quote
    @table = @editor.getTable json.table

   render: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.status = @p 'Select a column'

     @label for: 'delimiter-input', 'Delimiter'
     @$.elems.delimiter = @input '#delimiter-input.u-full-width',
      value: ','
      type: 'text'
      on: {change: @$.on.change}
     @label for: 'quote-input', 'Quote'
     @$.elems.quote = @input '#quote-input.u-full-width',
      value: '"'
      type: 'text'
      on: {change: @$.on.change}

     @$.elems.btn = @button '.u-full-width.button-primary', 'Separate',
      on: {click: @$.on.apply}
      style: {display: 'none'}
     @button '.u-full-width', on: {click: @$.on.cancel}, 'Cancel'

    @_setData() if @column?

   _setData: ->
    delimiter = @delimiter
    if delimiter is ' '
     delimiter = 'SPACE'
    else if delimiter is '\t'
     delimiter = 'TAB'
    @elems.delimiter.value = delimiter
    @elems.quote.value = @quote
    @table.clearHighlight()
    for col, c in @table.columns when col.id is @column
     @table.highlight.columns[c] = true
    @table.refresh()
    @refresh()


   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()

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

   @listen 'apply', (e) ->
    e.preventDefault()
    @delimiter = @elems.delimiter.value.trim()
    @quote = @elems.quote.value.trim()
    if (@delimiter.substr 0, 3) is 'TAB'
     n = parseInt @delimiter.substr 3
     n = 1 if isNaN n
     @delimiter = ''
     @delimiter += '\t' for i in [0...n]
    if @delimiter is 'SPACE'
     n = parseInt @delimiter.substr 5
     n = 1 if isNaN n
     @delimiter = ''
     @delimiter += ' ' for i in [0...n]

    @callbacks.apply()

   apply: ->
    cidx = -1
    for c, i in @table.columns when c.id is @column
     cidx = i

    column = @table.data[@column]
    data = []
    for d, r in column
     d ?= ''
     d = dsv
      separator: @delimiter
      quote: @quote
      text: d
     while d.length < data.length
      d.push ['']
     for t, i in d
      if data.length <= i
       a = new Array r
       for j in [0...r]
        a[j] = ''
       data.push a

      data[i].push t[0]

    nColumns = data.length
    col = @table.columns[cidx]
    args = [cidx, 1]
    for i in [1..nColumns]
     args.push
      id: "#{col.id}_#{i}"
      name: "#{col.name}_#{i}"
      type: 'string'
      default: ''

    delete @table.data[col.id]
    @table.columns.splice.apply @table.columns, args
    for d, i in data
     @table.data["#{col.id}_#{i + 1}"] = d



  OPERATIONS.set DelimiterSeparateColumn.type, DelimiterSeparateColumn
