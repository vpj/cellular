Mod.require 'Operation',
 'OPERATIONS'
 (Base, OPERATIONS) ->
  class AddColumn extends Base
   @extend()

   name: 'Add Column'
   @name: 'Add Column'
   type: 'addColumn'
   @type: 'addColumn'

   json: ->
    columns: @columns

   render: ->
    @elems.sidebar.innerHTML = ''
    @elems.content.innerHTML = ''

    Weya elem: @elems.sidebar, context: this, ->
     @$.elems.file = @input ".input-file", 'Open',
      style: {display: "none"}
      type: "file", on: {change: @$.on.changeFile}

     @button on: {click: @$.on.openFile}, 'Open file'

     @button '.button-primary', on: {click: @$.on.openFile}, 'Load'

    Weya elem: @elems.content, context: this, ->
     @$.elems.textArea = @textarea ".textarea-data", '',
      autocomplete: "off"
      spellcheck: "false"

    window.requestAnimationFrame @on.setupEditor


   @listen 'setupEditor', ->
    @textEditor = CodeMirror.fromTextArea @elems.textArea,
     mode: "text"
     lineNumbers: true
     value: "Paste your data here"
     tabSize: 12


  OPERATIONS.set AddColumn.type, AddColumn
