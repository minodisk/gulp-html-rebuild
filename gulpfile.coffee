gulp = require 'gulp'
coffee = require 'gulp-coffee'
replace = require 'gulp-replace'
mocha = require 'gulp-mocha'
sequence = require 'run-sequence'

files =
  src: 'src/**/*.coffee'
  test: 'test/**/*.coffee'

gulp.task 'watch', ->
  gulp.watch files.src, [
    'coffee&mocha'
  ]
  gulp.watch files.test, [
    'mocha'
  ]

gulp.task 'coffee&mocha', (callback) ->
  sequence 'coffee', 'mocha', callback

gulp.task 'coffee', ->
  gulp
  .src files.src
  .pipe coffee bare: true
  .pipe replace /\n{2,}/g, '\n'
  .pipe gulp.dest 'lib'

gulp.task 'mocha', ->
  gulp
  .src files.test, read: false
  .pipe coffee bare: true
  .pipe mocha reporter: 'tap'

gulp.task 'default', [
  'watch'
  'coffee&mocha'
]
