Mod.require 'Weya.Base',
 'Weya'
 (Base, Weya) ->
  class Table extends Base
   @initialize ->
    @elems = {}
    @clear()
    @testData()

   testData: ->
    @size = 10000
    @data.number = ("#{i}" for i in [0...@size])
    @columns.push
     id: 'number'
     name: 'number'
     type: 'number'
    @filteredRows = (i for i in [0...@size])

   clear: ->
    @data = {}
    @columns = []
    @filteredRows = []
    @highlight =
     rows: []
     columns: []
     cells: []

   render: (elem) ->
    @elems.container = elem
    @elems.container.innerHTML = ''

    Weya elem: @elems.container, context: this, ->
     @$.elems.tableHeader =  @table ".table-header", ->
      @$.elems.thead = @thead ->
       @tr ->
        for col in @$.columns
         @th col.name
     @$.elems.tableBodyWrapper = @div '.table-body-wrapper', ->
      @$.elems.tableBody =  @table ".table-body", ->
       @$.elems.tbody = @tbody ''

    window.requestAnimationFrame @on.getDimensions

   @listen 'getDimensions', ->
    height = @elems.container.offsetHeight -
             @elems.tableHeader.offsetHeight
    @elems.tableBodyWrapper.style.height = "#{height}px"


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

  Mod.set 'Table', Table
