# [gulp](http://gulpjs.com)-rebuild-html [![NPM version][npm-image]][npm-url] [![Build status][travis-image]][travis-url] [![Coverage Status](https://img.shields.io/coveralls/minodisk/gulp-rebuild-html.svg)](https://coveralls.io/r/minodisk/gulp-rebuild-html)

> Run [minodisk/htmlparser2#stack-storage](https://github.com/minodisk/htmlparser2/tree/stack-storage) and rebuild html.

*Automate rebuilding html to observe coding conventions, and so on.*

## Install

```bash
$ npm install --save-dev gulp-rebuild-html
```

## Usage

```js
var gulp = require('gulp');
var rebuild = require('gulp-rebuild-html');

gulp.task('default', function () {
  return gulp.src('index.html')
  .pipe(rebuild({
    onopentag: function (name, attrs, createAttrStr) {
      var classes = attrs.class.split(/\s+/);
      var index;
      if ((index = classes.indexOf('article')) === -1) {
        return;
      }
      classes.splice(index, 1);
      attrs.class = classes.join(' ');
      return "<" + name + createAttrStr(attrs) + ">";
    }
  }));
});
```

## API

### rebuild(options)

#### options

##### onprocessinginstruction
Type: `function`
Default: `function (name, value) { return "<" + value + ">"; }`

##### onopentag
Type: `function`
Default: `function (name, attrs, createAttrStr) { return "<" + name + createAttrStr(attrs) + ">"; }`

##### ontext
Type: `function`
Default: `function (name, value) { return text; }`

##### onwhitespace
Type: `function`
Default: `function (name, value) { return value; }`

##### onclosetag
Type: `function`
Default: `function (name, attrs, createAttrStr) { return "</" + name + ">"; }`

##### oncomment
Type: `function`
Default: `function (name, value) { return "<!--" + value + "-->"; }`


[travis-url]: http://travis-ci.org/minodisk/gulp-rebuild-html
[travis-image]: https://secure.travis-ci.org/minodisk/gulp-rebuild-html.svg?branch=master
[npm-url]: https://npmjs.org/package/gulp-rebuild-html
[npm-image]: https://badge.fury.io/js/gulp-rebuild-html.svg
