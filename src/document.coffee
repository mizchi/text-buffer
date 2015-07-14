class Position
  constructor: (@line = 0, @ch = 0) ->

module.exports = class Document
  constructor: ->
    @text = ''
    @cursor = new Position(0, 0)

  insertText: (text, pos) ->
    console.log 'insert', text, pos
    @text = @text
      .split('\n')
      .map (line, lineCount) =>
        if lineCount is pos.line
          line[0...pos.ch] + text + line[pos.ch..]
        else
          line
      .join('\n')

  deletePosition: (pos) ->
    @text = @text
      .split('\n')
      .map (line, lineCount) =>
        if lineCount is pos.line
          line[0...pos.ch-1] + line[pos.ch..]
        else
          line
      .join('\n')

  moveForward: ->
    @cursor.ch += 1

  moveBackward: ->
    @cursor.ch -= 1

  moveNextLine: ->
    @cursor.line += 1

  movePreviousLine: ->
    @cursor.line -= 1

  # input: {char: string; shift: boolean; alt: boolean; ctrl: boolean}
  handleInput: (input) ->
    if input.char is 'backspace'
      @deletePosition(@cursor)
      # @text = @text[0...@text.length-1]
      if @cursor.ch >= 0
        @cursor.ch--
      else
        @cursor.line--
    else if input.char is 'meta'
      # ignore
      ''
    else if input.char is 'enter'
      @text += '\n'
      @cursor.ch = 0
      @cursor.line++
    else if input.char is 'space'
      @text += ' '
      @cursor.ch++
    else if input.char in ['right', 'up', 'down', 'left']
      switch input.char
        when 'right'
          @moveForward()
        when 'left'
          @moveBackward()
        when 'up'
          @movePreviousLine()
        when 'down'
          @moveNextLine()
    # else if input.char.length > 1
    #   @text += input.char
    #   @cursor.ch += input.char
    else
      # if /[a-zA-Z ]/.test input.char
      @insertText(input.char, @cursor)
      @cursor.ch += input.char.length
