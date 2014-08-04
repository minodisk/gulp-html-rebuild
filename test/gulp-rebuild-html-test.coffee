expect = require 'expect'
rebuild = require '../lib/gulp-rebuild-html'
{ File } = require 'gulp-util'
{ PassThrough } = require 'stream'
# es = require 'event-stream'

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
    it 'should parse and rebuild html', (done) ->
      stream = rebuild()
      fakeStream = new PassThrough
      fakeFile = new File contents: fakeStream
      fakeStream.write new Buffer "wa"
      fakeStream.write new Buffer "dup"
      fakeStream.end()

      stream.on 'data', (newFile) ->
        console.log newFile.contents.toString()
        # if newFile is fakeFile
        #   newFile.pipe es.wait (err, data) ->
        #     assert.equal("wadup", data)
        # else
        #   newFile.pipe es.wait (err, data) ->
        #     assert.equal("doe", data)

      stream.on 'end', done
      stream.write fakeFile
      stream.end()
