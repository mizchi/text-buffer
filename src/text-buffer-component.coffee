$ = React.createElement

charFromKeyEvent = require './char-from-key-event'
Document = require './document'
raf = window?.requestAnimationFrame ? setInterval

flatten = require 'lodash.flatten'

Buffer = React.createClass
  render: ->
    $ 'div', {className: 'linesContainer', key: 'lines'},
      @props.body.split('\n').map (line, lineCount) =>
        $ 'div', {key: 'l:'+lineCount, className: 'line'},
          if line.length is 0
            [
              $ 'span', {
                ref: 'cursor'
                # key: 'cursor'
                className: 'cursor'
                style: {color: 'blue'}
              }, '|'
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
                      className: 'char'
                      ref: 'cursor'
                    }, '|'
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
  componentDidMount: ->
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
      # TODO: allocate buffer

    input.addEventListener 'compositionupdate', (ev) =>
      console.log 'composition:update', ev.data
      # TODO: resize input buffer

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
          left: 300
          padding: 0
          backgroundColor: 'wheat'
          width: '400px'
          height: '1em'
          outline: 'none'
      }
      $ 'div', {key: 'displayContainer', ref:'display'}, [
        $ Buffer, @state
      ]
    ]
