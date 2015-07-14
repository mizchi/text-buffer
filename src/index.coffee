global.React = require 'react'

TextBuffer = require './text-buffer-component'
window.addEventListener 'load', =>
  React.render React.createFactory(TextBuffer)({}), document.body
