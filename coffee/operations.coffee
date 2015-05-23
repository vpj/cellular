Mod.require 'Weya.Base',
 'Weya'
 'Table'
 (Base, Weya, Table) ->
  class Operations extends Base
   @extend()

   @initialize ->
    @_operations = {}

   each: (callback) ->
    for type, op of @_operations
     callback type, op

   get: (type) -> @_operations[type]
   set: (type, op) -> @_operations[type] = op

  OPERATIONS = new Operations
  Mod.set 'OPERATIONS', OPERATIONS



  class Operation extends Base
   @extend()

   @initialize (options) ->
    @elems =
     sidebar: options.sidebar
     content: options.content

    @callbacks =
     cancel: options.onCancel
     apply: options.onApply

    @editor = options.editor

   @listen 'tableSelect', (r, c, table) ->

   json: -> {}

   title: -> @operationName


  Mod.set 'Operation', Operation
