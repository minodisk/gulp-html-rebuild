gulp = require 'gulp'
coffee = require 'gulp-coffee'
replace = require 'gulp-replace'
mocha = require 'gulp-mocha'

gulp.task 'watch', ->
  gulp.watch 'src/**/*.coffee', [
    'coffee'
    'mocha'
  ]
  gulp.watch 'test/**/*.coffee', [
    'mocha'
  ]

gulp.task 'coffee', ->
  gulp
  .src 'src/**/*.coffee'
  .pipe coffee bare: true
  .pipe replace /\n{2,}/g, '\n'
  .pipe gulp.dest 'lib'

gulp.task 'mocha', ->
  gulp
  .src 'test/**/*.coffee', read: false
  .pipe coffee bare: true
  .pipe mocha reporter: 'tap'

gulp.task 'default', [
  'watch'
  'coffee'
  'mocha'
]
