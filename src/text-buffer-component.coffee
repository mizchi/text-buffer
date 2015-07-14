charFromKeyEvent = require './char-from-key-event'
Document = require './document'

module.exports = React.createClass
  componentDidMount: ->
    input = @refs.input.getDOMNode()
    input.addEventListener 'keydown', (ev) =>
      ev.preventDefault()
      char = charFromKeyEvent(ev)
      input.value = char

      @state.doc.handleInput
        char : char
        shift: ev.shiftKey
        alt  : ev.altKey
        meta : ev.metaKey
        ctrl : ev.ctrlKey
      @setState body: @state.doc.text

  focus: -> @refs.input.getDOMNode().focus()

  getInitialState: ->
    doc: new Document
    body: ''
    onComposition: false

  render: ->
    $ = React.createElement
    $ 'div', {
      ref: 'textBuffer'
      onClick: @focus
      key: 'textBuffer'
      style:
        width: 400
        height: 800
        outline: '1px solid gray'
    }, [
      $ 'textarea', {
        ref: 'input'
        contenteditable: true
        style:
          # position: 'absolute'
          padding: 0
          # width: '1000px'
          height: '1em'
          outline: 'none'
      }

      $ 'div', {key: 'displayContainer', ref:'display'}, [
        $ 'div', {className: 'linesContainer', key: 'lines'},
          for line, lineCount in @state.body.split('\n')
            $ 'div', {key: 'l:'+lineCount, className: 'line'},
              if line.length > 0
                for char, charCount in line.split('')
                  cursor = @state.doc.cursor
                  $ 'span', {
                    key: lineCount+':'+charCount
                    className: 'char'
                    style: {
                      backgroundColor:
                        if cursor.ch-1 is charCount and cursor.line is lineCount
                          'green'
                        else
                          'transparent'
                    }
                  }, char
              else
                [$ 'br']
      ]
    ]
