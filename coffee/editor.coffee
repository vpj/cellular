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

   @listen 'applyOperation', ->
    @history.push
     type: @operation.type
     data: @operation.json()

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

   @listen 'tableSelect', (r, c) ->
    return unless @operation?
    @operation.tableSelect r, c

   renderTable: ->
    @table.clearHighlight()
    @table.render @elems.content
    @table.generate()

   renderOperations: ->
    @elems.sidebar.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @div on: {click: @$.on.selectOperation}, ->
      OPERATIONS.each (type, op) =>
       btn = @button op.operationName
       btn._type = type

    #operations.render()

   @listen 'undo', ->

   @listen 'redo', ->

  Mod.onLoad ->
   EDITOR = new Editor()
   EDITOR.render document.body

