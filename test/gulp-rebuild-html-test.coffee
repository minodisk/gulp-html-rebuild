expect = require 'expect'
rebuild = require '../lib/gulp-rebuild-html'
{ File } = require 'gulp-util'
{ PassThrough } = require 'stream'
es = require 'event-stream'

describe 'gulp-rebuild-html', ->

  describe 'in buffer mode', ->

    test = (rebuildOpts, source, expected) ->
      (done) ->
        rebuildStream = rebuild rebuildOpts
        rebuildStream.on 'data', (outputFile) ->
          expect outputFile.contents.toString()
          .toBe expected
        rebuildStream.on 'end', ->
          done()
        rebuildStream.write new File contents: new Buffer source
        rebuildStream.end()

    it 'should parse and rebuild html', test
      onopentag: (name, attrs, createAttrStr) ->
        if attrs.class?
          attrs.class = ("module-#{cls}" for cls in  attrs.class.split /\s+/g).join ' '
        "<#{name}#{createAttrStr attrs}>"
    , """
    <div>
      <p class="foo">abc<span>def</span>ghi</p>
      <p>jkl</p>
    </div>
    """
    , """
    <div>
      <p class="module-foo">abc<span>def</span>ghi</p>
      <p>jkl</p>
    </div>
    """

  describe 'in stream mode', ->

    test = (rebuildOpts, sourceChunks, expected) ->
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
            setTimeout writeChunk, 100
          else
            contentStream.end()
        writeChunk()

    it 'should parse and rebuild html', test
        onopentag: (name, attrs, createAttrStr) ->
          if attrs.class?
            attrs.class = ("module-#{cls}" for cls in  attrs.class.split /\s+/g).join ' '
          "<#{name}#{createAttrStr attrs}>"
      , [
        '<div>\n'
        '  <p class="foo bar">abc<span>def</span>ghi</p>\n'
        '  <p>jkl</p>\n'
        '</div>'
      ]
      , """
      <div>
        <p class="module-foo module-bar">abc<span>def</span>ghi</p>
        <p>jkl</p>
      </div>
      """
