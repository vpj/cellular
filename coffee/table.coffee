Mod.require 'Weya.Base',
 'Weya'
 (Base, Weya) ->
  ROW_HEIGHT = 20
  CLUSTER_MULTIPLE = 4

  class Table extends Base
   @extend()

   @initialize (options) ->
    @_onClick = options.onClick
    @elems = {}
    @dims =
     bodyHeight: 0
     rowHeight: ROW_HEIGHT
    @clear()
    @testData()

   testData: ->
    @size = 1000000
    @data.number = ("#{i}" for i in [0...@size])
    @data.id = ("#{parseInt Math.random() * 1000}" for i in [0...@size])
    @columns.push
     id: 'number'
     name: 'Number'
     type: 'number'
     default: 0
    @columns.push
     id: 'id'
     name: 'Id'
     type: 'number'
     default: 0
    @filteredRows = (i for i in [0...@size])

   clear: ->
    @data = {}
    @columns = []
    @filteredRows = []
    @clearHighlight()

   clearHighlight: ->
    @highlight =
     rows: {}
     columns: {}
     cells: {}

   @get 'scroll', -> @elems.tableBodyWrapper.scrollTop
   @listen 'scroll', -> @generate()

   @listen 'click', (e) ->
    n = e.target

    while n?
     if n._row? and n._col?
      @_onClick n._row, n._col, this
     n = n.parentNode

   render: (elem) ->
    @elems.container = elem
    @elems.container.innerHTML = ''

    @_currentCluster = -1

    Weya elem: @elems.container, context: this, ->
     @$.elems.tableHeader =  @table ".table-header", ->
      @$.elems.thead = @thead ''
     @$.elems.tableBodyWrapper = @div '.table-body-wrapper', ->
      @$.elems.tableBody =  @table ".table-body", ->
       @$.elems.tbody = @tbody ''

    @_renderHeader()

    @elems.container.addEventListener 'click', @on.click
    @elems.tableBodyWrapper.addEventListener 'scroll', @on.scroll
    window.requestAnimationFrame @on.getDimensions

   @listen 'getDimensions', ->
    @dims.bodyHeight = @elems.container.offsetHeight -
             @elems.tableHeader.offsetHeight
    @elems.tableBodyWrapper.style.height = "#{@dims.bodyHeight}px"
    @dims.visibleRows = Math.ceil @dims.bodyHeight / @dims.rowHeight
    @dims.clusterRows = @dims.visibleRows * CLUSTER_MULTIPLE
    @dims.visibleHeight = @dims.visibleRows * @dims.rowHeight
    @dims.clusterHeight = @dims.clusterRows * @dims.rowHeight

    @generate()

   refresh: ->
    @_renderHeader()
    @generate true

   _renderHeader: ->
    @elems.thead.innerHTML = ''

    Weya elem: @elems.thead, context: this, ->
     @tr ->
      for col, i in @$.columns
       cssClass = '.th'
       cssClass += '.hgc' if @$.highlight.columns[i] is on
       th = @th cssClass, col.name
       th._row = -1
       th._col = i

   generate: (force) ->
    scroll = @scroll
    cluster = Math.floor scroll  / (@dims.clusterHeight - @dims.visibleHeight)
    return if not force and @_currentCluster is cluster

    @_currentCluster = cluster

    from = cluster * (@dims.clusterRows - @dims.visibleRows)
    to = Math.min from + @dims.clusterRows, @size
    rows = (i for i in [from...to])

    topSpace = from * @dims.rowHeight
    bottomSpace = (@size - to) * @dims.rowHeight

    @elems.tbody.innerHTML = ''
    Weya elem: @elems.tbody, context: this, ->
     @tr '.top-space', style: {height: "#{topSpace}px"}
     for r in rows
      rowCssClass = '.tr'
      rowCssClass += '.hgr' if @$.highlight.rows[r] is on
      @tr rowCssClass, ->
       for c, i in @$.columns
        cssClass = '.td'
        cssClass += '.hgc' if @$.highlight.columns[i] is on
        cssClass += '.hg' if @$.highlight.cells["#{r}_#{i}"] is on
        td = @td cssClass, @$.data[c.id][r]
        td._row = r
        td._col = i
     @tr '.bottom-space', style: {height: "#{bottomSpace}px"}

  Mod.set 'Table', Table
