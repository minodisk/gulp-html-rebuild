rebuild = require '../lib/gulp-rebuild-html'
{ File } = require 'gulp-util'
# es = require 'event-stream'
# { PassThrough } = require 'stream'
expect = require 'expect'

describe 'gulp-rebuild-html', ->

  describe 'in buffer mode', ->
    it 'should prepend text', (done) ->
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
