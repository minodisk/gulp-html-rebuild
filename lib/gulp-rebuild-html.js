var PLUGIN_NAME, Parser, PluginError, createAttrStr, replaceExtension, through, voidElements, _ref;
through = require('through2');
_ref = require('gulp-util'), PluginError = _ref.PluginError, replaceExtension = _ref.replaceExtension;
Parser = require('htmlparser2').Parser;
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
module.exports = function(opts) {
  if (opts == null) {
    opts = {};
  }
  if (opts.onprocessinginstruction == null) {
    opts.onprocessinginstruction = function(name, value) {
      return "<" + value + ">";
    };
  }
  if (opts.onopentag == null) {
    opts.onopentag = function(name, attrs, createAttrStr) {
      return "<" + name + (createAttrStr(attrs)) + ">";
    };
  }
  if (opts.ontext == null) {
    opts.ontext = function(text) {
      return text;
    };
  }
  if (opts.onwhitespace == null) {
    opts.onwhitespace = function(value) {
      return value;
    };
  }
  if (opts.onclosetag == null) {
    opts.onclosetag = function(name, attrs, createAttrStr) {
      return "</" + name + ">";
    };
  }
  if (opts.oncomment == null) {
    opts.oncomment = function(value) {
      return "<!--" + value + "-->";
    };
  }
  return through.obj(function(file, enc, callback) {
    var contents, node, parser;
    if (file.isNull()) {
      return callback();
    }
    if (file.isStream()) {
      throw new PluginError(PLUGIN_NAME, 'Not supports Stream');
    }
    if (!file.isBuffer()) {
      throw new PluginError(PLUGIN_NAME, 'Supports Buffer only');
    }
    contents = '';
    node = [][0];
    parser = new Parser({
      onprocessinginstruction: function(name, value) {
        return contents += opts.onprocessinginstruction(name, value);
      },
      onopentag: function(name, attrs) {
        return contents += opts.onopentag(name, attrs, createAttrStr);
      },
      ontext: function(text) {
        return contents += opts.ontext(text);
      },
      onclosetag: function(name, attrs) {
        if (!parser._options.xmlMode && name in voidElements) {
          return;
        }
        return contents += opts.onclosetag(name, attrs, createAttrStr);
      },
      oncomment: function(value) {
        return contents += opts.oncomment(value);
      }
    });
    parser.write(file.contents.toString('utf8'));
    parser.end();
    file.contents = new Buffer(contents);
    this.push(file);
    return callback();
  });
};
