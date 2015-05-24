Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class Export extends Base
   @extend()

   operationName: 'Export'
   @operationName: 'Export'
   type: 'export'
   @type: 'export'

   json: ->
    column: @column
    data: @data

   render: ->
    @elems.sidebar.innerHTML = ''
    @elems.content.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @button '.u-full-width', on: {click: @$.on.cancel}, 'OK'

    Weya elem: @elems.content, context: this, ->
     @$.elems.textArea = @textarea ".textarea-data", '',
      autocomplete: "off"
      spellcheck: "false"

    window.requestAnimationFrame @on.setupEditor


   @listen 'setupEditor', ->
    @textEditor = CodeMirror.fromTextArea @elems.textArea,
     mode: "text"
     lineNumbers: true
     value: ""
     tabSize: 12

    @textEditor.setSize '100%', '100%'

    @export()

   @listen 'cancel', (e) ->
    e.preventDefault()
    @callbacks.cancel()


   export: ->
    table = @editor.getTable()
    header = ''
    for c in table.columns
     header += ',' if header isnt ''
     header += "\"#{c.name.replace /\"/g, '""'}\""
    data = "#{header}\n"

    for r in [0...table.size]
     line = ''
     for c in table.columns
      d = "#{table.data[c.id][r] or c.default}"
      line += ',' if line isnt ''
      line += "\"#{d.replace /\"/g, '""'}\""

     data += "#{line}\n"

    @textEditor.setValue data


  OPERATIONS.set Export.type, Export
