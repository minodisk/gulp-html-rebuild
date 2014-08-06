through = require 'through2'
{ PluginError, replaceExtension } = require 'gulp-util'
{ Parser } = require 'htmlparser2'
{ PassThrough } = require 'stream'
{ cloneextend } = require 'cloneextend'

PLUGIN_NAME = 'gulp-rebuild-html'

voidElements =
  __proto__: null
  area: true
  base: true
  basefont: true
  br: true
  col: true
  command: true
  embed: true
  frame: true
  hr: true
  img: true
  input: true
  isindex: true
  keygen: true
  link: true
  meta: true
  param: true
  source: true
  track: true
  wbr: true

  # common self closing svg elements
  path: true
  circle: true
  ellipse: true
  line: true
  rect: true
  use: true

createAttrStr = (attrs) ->
  return '' if Object.keys(attrs).length is 0
  list = for key, val of attrs
    """
    #{key}="#{val}"
    """
  list.unshift ''
  list.join ' '

defOpts =
  onprocessinginstruction: (name, value) -> "<#{value}>"
  onopentag              : (name, attrs) -> "<#{name}#{createAttrStr attrs}>"
  ontext                 : (text) -> text
  onclosetag             : (name, attrs) -> "</#{name}>"
  oncomment              : (value) -> "<!--#{value}-->"

rebuild = (opts = {}) ->
  opts = cloneextend defOpts, opts

  through.obj (file, enc, callback) ->
    return callback() if file.isNull()

    if file.isBuffer()
      contents = ''
      parser = new Parser
        onprocessinginstruction: (name, value) ->
          contents += opts.onprocessinginstruction(name, value) ? defOpts.onprocessinginstruction(name, value)
        onopentag: (name, attrs) ->
          contents += opts.onopentag(name, attrs) ? defOpts.onopentag(name, attrs)
        ontext: (text) ->
          contents += opts.ontext(text) ? defOpts.ontext(text)
        onclosetag: (name, attrs) ->
          return if !parser._options.xmlMode and name of voidElements
          contents += opts.onclosetag(name, attrs) ? defOpts.onclosetag(name, attrs)
        oncomment: (value) ->
          contents += opts.oncomment(value) ? defOpts.oncomment(value)
      parser.write file.contents.toString 'utf8'
      parser.end()
      file.contents = new Buffer contents

    if file.isStream()
      stream = new PassThrough()
      parser = new Parser
        onprocessinginstruction: (name, value) ->
          stream.write opts.onprocessinginstruction(name, value) ? defOpts.onprocessinginstruction(name, value)
        onopentag: (name, attrs) ->
          stream.write opts.onopentag(name, attrs) ? defOpts.onopentag(name, attrs)
        ontext: (text) ->
          stream.write opts.ontext(text) ? defOpts.ontext(text)
        onclosetag: (name, attrs) ->
          return if !parser._options.xmlMode and name of voidElements
          stream.write opts.onclosetag(name, attrs) ? defOpts.onclosetag(name, attrs)
        oncomment: (value) ->
          stream.write opts.oncomment(value) ? defOpts.oncomment(value)
        onend: ->
          stream.end()
      file.contents.pipe parser
      file.contents = stream

    @push file
    callback()

rebuild.createAttrStr = createAttrStr

module.exports = rebuild
