#toolbar

#add data

#view

#add operation
#search
#list operations

#undo
#redoo
class Editor extends Base
 @initialize (options) ->
  @elems =
   sidebar: null
   content: null

 render: ->
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
  @operations[

 @listen 'tableSelect', (r, c) ->
  return unless @operation?
  @operation.tableSelect r, c

 renderTable: ->
  @table.render @elems.content

 renderOperations: ->
  #operations.render()

 @listen 'undo', ->

 @listen 'redo', ->
