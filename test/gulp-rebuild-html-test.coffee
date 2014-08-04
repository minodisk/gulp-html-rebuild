expect = require 'expect'
rebuild = require '../lib/gulp-rebuild-html'
{ File } = require 'gulp-util'
{ PassThrough } = require 'stream'
es = require 'event-stream'
{ clone } = require 'cloneextend'

describe 'gulp-rebuild-html', ->

  html = """
  <!DOCTYPE html>
  <html>
  <head></head>
  <body>
    <div class="foo">
      <h1 class="bar baz">abc<span>span</span>ghi</h1>
      <p>jkl</p>
    </div>
  </body>
  </html>
  """
  htmlClone = html
  htmlChunks = while htmlClone.length
    chunk = htmlClone.substr 0, 10
    htmlClone = htmlClone.substr 10
    chunk

  describe 'in buffer mode', ->

    createRunner = (rebuildOpts, source, expected) ->
      (done) ->
        rebuildStream = rebuild rebuildOpts
        rebuildStream.on 'data', (outputFile) ->
          expect outputFile.contents.toString()
          .toBe expected
        rebuildStream.on 'end', ->
          done()
        rebuildStream.write new File contents: new Buffer source
        rebuildStream.end()

    it "should rewrite the value of attributes", createRunner
      onopentag: (name, attrs, createAttrStr) ->
        return unless name is 'div' and
                      attrs.class?
        attrs.class = ("module-#{cls}" for cls in attrs.class.split /\s+/g).join ' '
        "<#{name}#{createAttrStr attrs}>"
    , html
    , """
    <!DOCTYPE html>
    <html>
    <head></head>
    <body>
      <div class="module-foo">
        <h1 class="bar baz">abc<span>span</span>ghi</h1>
        <p>jkl</p>
      </div>
    </body>
    </html>
    """

    it "should add class names as a comment to close tag", createRunner
      onclosetag: (name, attrs, createAttrStr) ->
        return unless name is 'div' and
                      attrs.class?
        classStr = (".#{cls}" for cls in attrs.class.split /s+/g).join ''
        "<!-- /#{classStr} --></#{name}>"
    , html
    , """
    <!DOCTYPE html>
    <html>
    <head></head>
    <body>
      <div class="foo">
        <h1 class="bar baz">abc<span>span</span>ghi</h1>
        <p>jkl</p>
      <!-- /.foo --></div>
    </body>
    </html>
    """

  describe 'in stream mode', ->

    createRunner = (rebuildOpts, sourceChunks, expected) ->
      (done) ->
        contentStream = new PassThrough

        rebuildStream = rebuild rebuildOpts
        rebuildStream.on 'data', (outputFile) ->
          outputFile.pipe es.wait (err, data) ->
            expect data.toString()
            .toBe expected
            done()
        rebuildStream.write new File contents: contentStream
        rebuildStream.end()

        writeChunk = ->
          if sourceChunks.length > 0
            contentStream.write new Buffer sourceChunks.shift()
            setTimeout writeChunk, 10
          else
            contentStream.end()
        writeChunk()

    it "should rewrite the value of attributes", createRunner
      onopentag: (name, attrs, createAttrStr) ->
        return unless name is 'div' and
                      attrs.class?
        attrs.class = ("module-#{cls}" for cls in attrs.class.split /\s+/g).join ' '
        "<#{name}#{createAttrStr attrs}>"
    , clone(htmlChunks)
    , """
    <!DOCTYPE html>
    <html>
    <head></head>
    <body>
      <div class="module-foo">
        <h1 class="bar baz">abc<span>span</span>ghi</h1>
        <p>jkl</p>
      </div>
    </body>
    </html>
    """

    it "should add class names as a comment to close tag", createRunner
      onclosetag: (name, attrs, createAttrStr) ->
        return unless name is 'div' and
                      attrs.class?
        classStr = (".#{cls}" for cls in attrs.class.split /s+/g).join ''
        "<!-- /#{classStr} --></#{name}>"
    , clone(htmlChunks)
    , """
    <!DOCTYPE html>
    <html>
    <head></head>
    <body>
      <div class="foo">
        <h1 class="bar baz">abc<span>span</span>ghi</h1>
        <p>jkl</p>
      <!-- /.foo --></div>
    </body>
    </html>
    """
