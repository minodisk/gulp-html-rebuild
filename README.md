# [gulp](http://gulpjs.com)-rebuild-html [![NPM version][npm-image]][npm-url] [![Build status][travis-image]][travis-url]

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
			ontagopen: function () {}
		}));
});
```


## API

### rebuild(options)

#### options.ontagstart


[travis-url]: http://travis-ci.org/minodisk/gulp-rebuild-html
[travis-image]: https://secure.travis-ci.org/minodisk/gulp-rebuild-html.svg?branch=master
[npm-url]: https://npmjs.org/package/gulp-rebuild-html
[npm-image]: https://badge.fury.io/js/gulp-rebuild-html.svg
