expect = require 'expect'
rebuild = require '../lib/gulp-rebuild-html'
{ File } = require 'gulp-util'
{ PassThrough } = require 'stream'
es = require 'event-stream'

describe 'gulp-rebuild-html', ->

  describe 'in buffer mode', ->

    it 'should parse and rebuild html', (done) ->
      stream = rebuild
        onopentag: (name, attrs, createAttrStr) ->
          if attrs.class?
            attrs.class = ("js-#{cls}" for cls in  attrs.class.split /\s+/g).join ' '
          "<#{name}#{createAttrStr attrs}>"
      stream.on 'data', (file) ->
        expect file.contents.toString()
        .toBe """
        <div>
          <p class="js-foo">abc<span>def</span>ghi</p>
          <p>jkl</p>
        </div>
        """
      stream.on 'end', ->
        done()
      stream.write new File contents: new Buffer """
      <div>
        <p class="foo">abc<span>def</span>ghi</p>
        <p>jkl</p>
      </div>
      """
      stream.end()

  describe 'in stream mode', ->

    test = (done, rebuildOpts, chunks, expected) ->
      writableStream = new PassThrough

      rebuildStream = rebuild rebuildOpts
      rebuildStream.on 'data', (newFile) ->
        newFile.pipe es.wait (err, data) ->
          expect data.toString()
          .toBe expected
          done()
      rebuildStream.write new File contents: writableStream
      rebuildStream.end()

      writeChunk = ->
        if chunks.length > 0
          chunk = chunks.shift()
          writableStream.write new Buffer chunk
          setTimeout writeChunk, 100
        else
          writableStream.end()
      writeChunk()

    it 'should parse and rebuild html', (done) ->
      test done,
        onopentag: (name, attrs, createAttrStr) ->
          if attrs.class?
            attrs.class = ("module-#{cls}" for cls in  attrs.class.split /\s+/g).join ' '
          "<#{name}#{createAttrStr attrs}>"
      , [
        """<div>\n"""
        """  <p class="foo bar">abc<span>def</span>ghi</p>\n"""
        """  <p>jkl</p>\n"""
        """</div>"""
      ]
      , """
      <div>
        <p class="module-foo module-bar">abc<span>def</span>ghi</p>
        <p>jkl</p>
      </div>
      """
