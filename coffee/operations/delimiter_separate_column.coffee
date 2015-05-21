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

   @listen 'separate', (e) ->
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



  OPERATIONS.set DelimiterSeparateColumn.type, DelimiterSeparateColumn
