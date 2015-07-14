# e: KeyEvent => string
module.exports = getInputFromKeyEventEvent = do ->
  _MAP =
    8: 'backspace'
    9: 'tab'
    13: 'enter'
    16: 'shift'
    17: 'ctrl'
    18: 'alt'
    20: 'capslock'
    27: 'esc'
    32: 'space'
    33: 'pageup'
    34: 'pagedown'
    35: 'end'
    36: 'home'
    37: 'left'
    38: 'up'
    39: 'right'
    40: 'down'
    45: 'ins'
    46: 'del'
    91: 'meta'
    93: 'meta'
    224: 'meta'

  # F1~F20
  for i in [1..20] then _MAP[111 + i] = 'f' + i
  # numpad 0~9
  for i in [0..9] then _MAP[96 + i] = i

  _KEYCODE_MAP =
    106: '*'
    107: '+'
    109: '-'
    110: '.'
    111 : '/'
    186: ';',
    187: '='
    188: ','
    189: '-'
    190: '.'
    191: '/'
    192: '`'
    219: '['
    220: '\\'
    221: ']'
    222: '\''

  _SHIFT_MAP =
    '~': '`'
    '!': '1'
    '@': '2'
    '#': '3'
    '$': '4'
    '%': '5'
    '^': '6'
    '&': '7'
    '*': '8'
    '(': '9'
    ')': '0'
    '_': '-'
    '+': '='
    ':': ';'
    '<': ','
    '>': '.'
    '?': '/'
    '|': '\\'
    '\"': '\''

  _SPECIAL_ALIASES =
    'option' : 'alt'
    'command': 'meta'
    'return' : 'enter'
    'escape' : 'esc'
    'mod'    : if /Mac|iPod|iPhone|iPad/.test(navigator.platform) then 'meta' else 'ctrl'
  (e) ->
    if _MAP[e.which] then return _MAP[e.which]
    if _KEYCODE_MAP[e.which] then return _KEYCODE_MAP[e.which]

    char = String.fromCharCode(e.which)
    unless e.shiftKey
      char = char.toLowerCase()
    # debugger
    char
