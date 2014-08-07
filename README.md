# [gulp](http://gulpjs.com)-html-rebuild [![NPM version][npm-image]][npm-url] [![Build status][travis-image]][travis-url] [![Coverage Status](https://img.shields.io/coveralls/minodisk/gulp-html-rebuild.svg)](https://coveralls.io/r/minodisk/gulp-html-rebuild)

> Run [minodisk/htmlparser2#stack-storage](https://github.com/minodisk/htmlparser2/tree/stack-storage) and rebuild html.

*Parse and rebuild html to observe coding conventions, and so on.*

## Install

```bash
$ npm install --save-dev gulp-html-rebuild
```

## Usage

```js
var gulp = require('gulp');
var rebuild = require('gulp-html-rebuild');

gulp.task('default', function () {
  return gulp.src('index.html')
  .pipe(rebuild({
    onopentag: function (name, attrs) {
      var classes = attrs.class.split(/\s+/);
      var index;
      if ((index = classes.indexOf('article')) === -1) {
        return;
      }
      classes.splice(index, 1);
      attrs.class = classes.join(' ');
      return "<" + name + rebuild.createAttrStr(attrs) + ">";
    }
  }));
});
```

## API

### rebuild(options)

Gulp plugin for rebuilding html.

- Params:
  - options `Object` - Options for rebuilding html.
    - onprocessinginstruction `Function` - Replace instruction with returned string. Default: `function (name, value) { return "<" + value + ">"; }`
    - onopentag `Function` - Replace open tag with returned string. Default: `function (name, attrs) { return "<" + name + createAttrStr(attrs) + ">"; }`
    - onclosetag `Function` - Replace close tag with returned string. Default: `function (name, attrs) { return "</" + name + ">"; }`
    - ontext `Function` - Replace text with returned string. Default: `function (value) { return value; }`
    - oncomment `Function` - Replace comment with returned string. Default: `function (value) { return "<!--" + value + "-->"; }`

### rebuild.createAttrStr(attrs)

Helper for creating attribute.

- Params:
  - attrs `Object` - A map of the attribute.
- Returns: `String` - A string of the attribute starting with whitespace.


[travis-url]: http://travis-ci.org/minodisk/gulp-html-rebuild
[travis-image]: https://secure.travis-ci.org/minodisk/gulp-html-rebuild.svg?branch=master
[npm-url]: https://npmjs.org/package/gulp-html-rebuild
[npm-image]: https://badge.fury.io/js/gulp-html-rebuild.svg
