flatten = require 'lodash.flatten'

charFromKeyEvent = require './char-from-key-event'
Document = require './document'
raf = window?.requestAnimationFrame ? setInterval
$ = React.createElement

Buffer = React.createClass
  render: ->
    $ 'div', {className: 'linesContainer', key: 'lines'},
      @props.body.split('\n').map (line, lineCount) =>
        $ 'div', {key: 'l:'+lineCount, className: 'line'},
          if line.length is 0
            [
              $ 'span', {
                ref: 'cursor'
                className: 'cursor'
              }, ''
            ]
          else
            chars =
              for char, charCount in line.split('')
                cursor = @props.doc.cursor
                isCursorChar = cursor.ch-1 is charCount and cursor.line is lineCount
                if isCursorChar
                  [
                    $ 'span', {
                      key: lineCount+':'+charCount
                      className: 'char'
                    }, char
                    $ 'span', {
                      key: lineCount+':'+charCount+'cursor'
                      className: 'cursor'
                      ref: 'cursor'
                      style:
                        width: 0
                        visibility: 'hidden'
                    }, ''
                  ]
                else
                  [
                    $ 'span', {
                      key: lineCount+':'+charCount
                      className: 'char'
                    }, char
                  ]
            flatten(chars)

module.exports = React.createClass
  _adjustCursorPositon: ->
    input = @refs.input.getDOMNode()
    cursor = @refs.buffer.refs.cursor.getDOMNode()
    # TODO: Firefox won't work
    # TODO: detect this params
    x = cursor.offsetLeft + 1
    y = cursor.offsetTop - 4
    input.style.left = x+'px'
    input.style.top = y+'px'

  componentDidUpdate: ->
    console.log 'didUpdate'
    @_adjustCursorPositon()

  componentDidMount: ->
    @_adjustCursorPositon()

    onComposition = false

    input = @refs.input.getDOMNode()

    events = []
    do mainloop = =>
      if events.length > 0
        while f = events.shift() then f()
      raf mainloop

    input.addEventListener 'compositionend', (ev) =>
      console.log '--- composition:end'
      char = ev.data
      onComposition = false
      cursor = @refs.buffer.refs.cursor.getDOMNode()
      cursor.style.color = 'black'

      # exec priority
      events.unshift =>
        @state.doc.handleInput
          char : char
          shift: false
          alt  : false
          meta : false
          ctrl : false
        @setState body: @state.doc.text
        input.innerHTML = ''
      return

    input.addEventListener 'compositionstart', (ev) =>
      console.log '--- composition:start'
      onComposition = true
      cursor = @refs.buffer.refs.cursor.getDOMNode()
      cursor.style.color = 'white'

    input.addEventListener 'compositionupdate', (ev) =>
      console.log 'composition:update', ev.data
      cursor = @refs.buffer.refs.cursor.getDOMNode()
      cursor.innerHTML = ev.data

    input.addEventListener 'keydown', (ev) =>
      # ignore meta ime event
      console.log ev.which
      if ev.which in [16, 17, 18, 93, 229]
        return

      char = charFromKeyEvent(ev)
      {shiftKey, altKey, metaKey, ctrlKey} = ev
      events.push =>
        if onComposition
          console.log 'queued onComposition', onComposition
        else
          console.log 'insert directly'
          @state.doc.handleInput
            char : char
            shift: shiftKey
            alt  : altKey
            meta : metaKey
            ctrl : ctrlKey
          @setState body: @state.doc.text
          input.innerHTML = ''

  focus: -> @refs.input.getDOMNode().focus()

  getInitialState: ->
    doc: new Document
    body: ''

  render: ->
    $ 'div', {
      ref: 'textBuffer'
      onClick: @focus
      key: 'textBuffer'
      style:
        width: 400
        height: 800
        outline: '1px solid gray'
    }, [
      $ 'div', {
        ref: 'input'
        contentEditable: true
        style:
          position: 'absolute'
          top: 0
          left: 0
          padding: 0
          margin: 0
          width: '400px'
          # width: 1
          height: '1em'
          outline: 'none'
      }
      $ 'div', {key: 'displayContainer', ref:'display'}, [
        $ Buffer, {
          doc: @state.doc
          body: @state.body
          ref: 'buffer'
        }
      ]
    ]
