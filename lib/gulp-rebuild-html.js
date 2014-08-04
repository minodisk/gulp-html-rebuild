var PLUGIN_NAME, Parser, PassThrough, PluginError, cloneextend, createAttrStr, defOpts, replaceExtension, through, voidElements, _ref;
through = require('through2');
_ref = require('gulp-util'), PluginError = _ref.PluginError, replaceExtension = _ref.replaceExtension;
Parser = require('htmlparser2').Parser;
PassThrough = require('stream').PassThrough;
cloneextend = require('cloneextend').cloneextend;
PLUGIN_NAME = 'gulp-rebuild-html';
voidElements = {
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
  path: true,
  circle: true,
  ellipse: true,
  line: true,
  rect: true,
  use: true
};
createAttrStr = function(attrs) {
  var key, list, val;
  if (Object.keys(attrs).length === 0) {
    return '';
  }
  list = (function() {
    var _results;
    _results = [];
    for (key in attrs) {
      val = attrs[key];
      _results.push("" + key + "=\"" + val + "\"");
    }
    return _results;
  })();
  list.unshift('');
  return list.join(' ');
};
defOpts = {
  onprocessinginstruction: function(name, value) {
    return "<" + value + ">";
  },
  onopentag: function(name, attrs, createAttrStr) {
    return "<" + name + (createAttrStr(attrs)) + ">";
  },
  ontext: function(text) {
    return text;
  },
  onwhitespace: function(value) {
    return value;
  },
  onclosetag: function(name, attrs, createAttrStr) {
    return "</" + name + ">";
  },
  oncomment: function(value) {
    return "<!--" + value + "-->";
  }
};
module.exports = function(opts) {
  if (opts == null) {
    opts = {};
  }
  opts = cloneextend(defOpts, opts);
  return through.obj(function(file, enc, callback) {
    var contents, parser, stream;
    if (file.isNull()) {
      return callback();
    }
    if (file.isBuffer()) {
      contents = '';
      parser = new Parser({
        onprocessinginstruction: function(name, value) {
          var _ref1;
          return contents += (_ref1 = opts.onprocessinginstruction(name, value)) != null ? _ref1 : defOpts.onprocessinginstruction(name, value);
        },
        onopentag: function(name, attrs) {
          var _ref1;
          return contents += (_ref1 = opts.onopentag(name, attrs, createAttrStr)) != null ? _ref1 : defOpts.onopentag(name, attrs, createAttrStr);
        },
        ontext: function(text) {
          var _ref1;
          return contents += (_ref1 = opts.ontext(text)) != null ? _ref1 : defOpts.ontext(text);
        },
        onclosetag: function(name, attrs) {
          var _ref1;
          if (!parser._options.xmlMode && name in voidElements) {
            return;
          }
          return contents += (_ref1 = opts.onclosetag(name, attrs, createAttrStr)) != null ? _ref1 : defOpts.onclosetag(name, attrs, createAttrStr);
        },
        oncomment: function(value) {
          var _ref1;
          return contents += (_ref1 = opts.oncomment(value)) != null ? _ref1 : defOpts.oncomment(value);
        }
      });
      parser.write(file.contents.toString('utf8'));
      parser.end();
      file.contents = new Buffer(contents);
    }
    if (file.isStream()) {
      stream = new PassThrough();
      parser = new Parser({
        onprocessinginstruction: function(name, value) {
          var _ref1;
          return stream.write((_ref1 = opts.onprocessinginstruction(name, value)) != null ? _ref1 : defOpts.onprocessinginstruction(name, value));
        },
        onopentag: function(name, attrs) {
          var _ref1;
          return stream.write((_ref1 = opts.onopentag(name, attrs, createAttrStr)) != null ? _ref1 : defOpts.onopentag(name, attrs, createAttrStr));
        },
        ontext: function(text) {
          var _ref1;
          return stream.write((_ref1 = opts.ontext(text)) != null ? _ref1 : defOpts.ontext(text));
        },
        onclosetag: function(name, attrs) {
          var _ref1;
          if (!parser._options.xmlMode && name in voidElements) {
            return;
          }
          return stream.write((_ref1 = opts.onclosetag(name, attrs, createAttrStr)) != null ? _ref1 : defOpts.onclosetag(name, attrs, createAttrStr));
        },
        oncomment: function(value) {
          var _ref1;
          return stream.write((_ref1 = opts.oncomment(value)) != null ? _ref1 : defOpts.oncomment(value));
        },
        onend: function() {
          return stream.end();
        }
      });
      file.contents.pipe(parser);
      file.contents = stream;
    }
    this.push(file);
    return callback();
  });
};
