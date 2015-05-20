class Table extends Base
 @initialize ->

 clear: ->
  @data = {}
  @columns = [] #name, type
  @filteredRows = [] #array of filtered rows
  @highlight =
   rows: []
   columns: []
   cells: []

 render: (elem) ->
  @elems.container = elem
  @elems.innerHTML = ''

  Weya elem: @elems.container, context: this, ->
   @$.elems.table =  @table ->
    @$.elems.thead = @thead ->
     @tr ->
      for col in @$.columns
       @th col.name
    @$.elems.tbody = @tbody ''

 generate: ->
  rows = []
  @elems.tbody.innerHTML = ''
  Weya elem: @elems.tbody, context: this, ->
   @tr '.top-space', style: {height: "#{topOffset}px"}
   for r in rows
    for c in @$.columns
     d = @$.data[c.id][r]

   @$.elems.displayed = {}

