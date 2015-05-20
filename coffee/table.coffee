Mod.require 'Weya.Base',
 'Weya'
 (Base, Weya) ->
  class Table extends Base
   @initialize ->
    @clear()
    @size = 100000
    @data.number = ("#{i}" for i in [0...@size])
    @columns.push
     name: 'number'
     type: 'number'
    @filteredRows = (i for i in [0...@size])

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
    @elems.container.innerHTML = ''

    Weya elem: @elems.container, context: this, ->
     @$.elems.table =  @table ->
      @$.elems.thead = @thead ->
       @tr ->
        for col in @$.columns
         @th col.name
      @$.elems.tbody = @tbody ''

   generate: ->
    rows = (i for i in [0...@size])
    @elems.tbody.innerHTML = ''
    Weya elem: @elems.tbody, context: this, ->
     #@tr '.top-space', style: {height: "#{topOffset}px"}
     for r in rows
      @tr ->
       for c in @$.columns
        d = @$.data[c.id][r]
        @td d

