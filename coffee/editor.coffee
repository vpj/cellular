Mod.require 'Weya.Base',
 'Weya'
 'Table'
 'OPERATIONS'
 (Base, Weya, Table, OPERATIONS) ->
  SIDEBAR_WIDTH = 300

  class Editor extends Base
   @extend()

   @initialize (options) ->
    @elems =
     sidebar: null
     content: null

    @table = new Table
     onClick: @on.tableClick
    @operation = null
    @history = []
    @nHistory = -1

   getTable: -> @table

   render: (elem) ->
    @elems.container = elem

    height = window.innerHeight
    width = window.innerWidth

    @elems.container.innerHTML = ''

    Weya elem: @elems.container, context: this, ->
     @$.elems.content = @div ".content", null
     @$.elems.sidebar = @div ".sidebar", null

    @renderTable()
    @renderOperations()

   selectOperation: (operation) ->
    @operation = new operation
     sidebar: @elems.sidebar
     content: @elems.content
     onCancel: @on.cancelOperation
     onApply: @on.applyOperation
     editor: this
    @operation.render()

   selectHistory: (n) ->
    @nHistory = n - 1
    @table.clear()
    for i in [0...n]
     h = @history[i]
     op = new (OPERATIONS.get h.type)
      editor: this
     op.setJson h.data
     op.apply()
    h = @history[n]

    @operation = new (OPERATIONS.get h.type)
     sidebar: @elems.sidebar
     content: @elems.content
     onCancel: @on.cancelOperation
     onApply: @on.applyOperation
     editor: this
    @operation.setJson h.data
    @renderTable()
    @renderOperations()
    window.requestAnimationFrame =>
     @operation.render()


   @listen 'applyOperation', ->
    @nHistory++
    if @nHistory < @history.length
     @history = @history.slice 0, @nHistory
    @history.push
     title: @operation.title()
     type: @operation.type
     data: @operation.json()
    @nHistory = @history.length - 1

    @operation.apply()
    @renderTable()
    @renderOperations()
    @operation = null

   @listen 'tableClick', (r, c, table) ->
    return unless @operation
    @operation.on.tableSelect r, c, table

   @listen 'cancelOperation', ->
    @renderTable()
    @renderOperations()
    @operation = null

   @listen 'selectOperation', (e) ->
    n = e.target
    while n?
     if n._type?
      op = OPERATIONS.get n._type
      @selectOperation op
      return
     n = n.parentNode

   @listen 'selectHistory', (e) ->
    n = e.target
    while n?
     if n._history?
      @selectHistory n._history
      return
     n = n.parentNode

   @listen 'tableSelect', (r, c) ->
    return unless @operation?
    @operation.tableSelect r, c

   renderTable: ->
    @table.clearHighlight()
    @table.render @elems.content

   renderOperations: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @div '.operations-list', on: {click: @$.on.selectOperation}, ->
      OPERATIONS.each (type, op) =>
       btn = @button op.operationName
       btn._type = type

     @div '.history-list', on: {click: @$.on.selectHistory}, ->
      for h, i in @$.history
       btn = @button h.title
       btn._history = i


  Mod.onLoad ->
   EDITOR = new Editor()
   EDITOR.render document.body

