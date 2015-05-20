Mod.require 'Weya.Base',
 'Weya'
 'Table'
 (Base, Weya, Table) ->
  SIDEBAR_WIDTH = 300

  class Editor extends Base
   @initialize (options) ->
    @elems =
     sidebar: null
     content: null

    @table = new Table()

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
     table: @table

   @listen 'applyOperation', ->
    @history.push
     type: @operation.type
     data: @operation.json()

    @operation.apply()
    @renderTable()
    @renderOperations()
    @operation = null

   @listen 'cancelOperation', ->
    @renderTable()
    @renderOperations()
    @operation = null

   @listen 'selectOperation', ->
    #@operations[]

   @listen 'tableSelect', (r, c) ->
    return unless @operation?
    @operation.tableSelect r, c

   renderTable: ->
    @table.render @elems.content
    @table.generate()

   renderOperations: ->
    #operations.render()

   @listen 'undo', ->

   @listen 'redo', ->

  EDITOR = new Editor()
  EDITOR.render document.body

