through = require 'through2'
{ PluginError, replaceExtension } = require 'gulp-util'
{ Parser } = require 'htmlparser2'

PLUGIN_NAME = 'gulp-html-rebuilder'

voidElements =
	__proto__: null,
	area: true,
	base: true,
	basefont: true,
	br: true,
	col: true,
	command: true,
	embed: true,
	frame: true,
	hr: true,
	img: true,
	input: true,
	isindex: true,
	keygen: true,
	link: true,
	meta: true,
	param: true,
	source: true,
	track: true,
	wbr: true,

	# common self closing svg elements
	path: true,
	circle: true,
	ellipse: true,
	line: true,
	rect: true,
	use: true

createAttrStr = (attrs) ->
  return '' if Object.keys(attrs).length is 0
  list = for key, val of attrs
    """
    #{key}="#{val}"
    """
  list.unshift ''
  list.join ' '

module.exports = (opts = {}) ->
  opts.onprocessinginstruction ?= (name, value) -> "<#{value}>"
  opts.onopentag ?= (name, attrs, createAttrStr) -> "<#{name}#{createAttrStr attrs}>"
  opts.ontext ?= (text) -> text
  opts.onwhitespace ?= (value) -> value
  opts.onclosetag ?= (name, attrs, createAttrStr) -> "</#{name}>"
  opts.oncomment ?= (value) -> "<!--#{value}-->"

  through.obj (file, enc, callback) ->
    return callback() if file.isNull()
    throw new PluginError PLUGIN_NAME, 'Not supports Stream' if file.isStream()
    throw new PluginError PLUGIN_NAME, 'Supports Buffer only' unless file.isBuffer()

    contents = ''
    [ node ] = []
    parser = new Parser
      onprocessinginstruction: (name, value) ->
        contents += opts.onprocessinginstruction name, value
      onopentag: (name, attrs) ->
        contents += opts.onopentag name, attrs, createAttrStr
      ontext: (text) ->
        contents += opts.ontext text
      onclosetag: (name, attrs) ->
        return if !parser._options.xmlMode and name of voidElements
        contents += opts.onclosetag name, attrs, createAttrStr
      oncomment: (value) ->
        contents += opts.oncomment value

    parser.write file.contents.toString 'utf8'
    parser.end()

    file.contents = new Buffer contents
    @push file

    callback()
