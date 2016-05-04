require 'helper'

describe RubyPandoc::Converter do
  before do
    @file = File.join(File.dirname(__FILE__), 'files', 'test.md')
    @file2 = File.join(File.dirname(__FILE__), 'files', 'test2.md')
    @string = '# Test String'
    @converter = RubyPandoc::Converter.new(@string, t: :rst)
  end

  after do
    RubyPandoc::Converter.pandoc_path = 'pandoc'
  end

  it 'calls bare pandoc when passed no options' do
    converter = RubyPandoc::Converter.new(@string)
    converter.expects(:execute).with('pandoc').returns(true)
    assert converter.convert
  end

  it 'converts with altered pandoc_path' do
    path = '/usr/bin/env pandoc'
    RubyPandoc::Converter.pandoc_path = path
    converter = RubyPandoc::Converter.new(@string)
    converter.expects(:execute).with(path).returns(true)
    assert converter.convert
  end

  it 'converts input passed as a string' do
    assert_equal "<h1 id=\"test-string\">Test String</h1>\n",
                 RubyPandoc::Converter.new(@string).to_html
  end

  it 'converts single element array input as array of file paths' do
    assert RubyPandoc::Converter.new([@file]).to_html.match(/This is a Title/)
  end

  it 'converts multiple element array input as array of file paths' do
    assert RubyPandoc::Converter.new([@file, @file2]).to_html.match(/This is a Title/)
    assert RubyPandoc::Converter.new([@file, @file2]).to_html.match(/A Second Title/)
  end

  it 'converts multiple element array input as array of file paths to a binary output format' do
    assert RubyPandoc::Converter.new([@file, @file2]).to_epub.match(/com.apple.ibooks/)
  end

  it 'accepts short options' do
    @converter.expects(:execute).with('pandoc -t rst').returns(true)
    assert @converter.convert
  end

  it 'accepts long options' do
    converter = RubyPandoc::Converter.new(@string, to: :rst)
    converter.expects(:execute).with('pandoc --to rst').returns(true)
    assert converter.convert
  end

  it 'accepts a variety of options in initializer' do
    converter = RubyPandoc::Converter.new(@string, :s, {
                                 f: :markdown, to: :rst
                               }, 'no-wrap')
    converter \
      .expects(:execute) \
      .with('pandoc -s -f markdown --to rst --no-wrap') \
      .returns(true)
    assert converter.convert
  end

  it 'accepts a variety of options in convert' do
    converter = RubyPandoc::Converter.new(@string)
    converter \
      .expects(:execute) \
      .with('pandoc -s -f markdown --to rst --no-wrap') \
      .returns(true)
    assert converter.convert(:s, { f: :markdown, to: :rst }, 'no-wrap')
  end

  it 'converts underscore symbol ares to hyphenated long options' do
    converter = RubyPandoc::Converter.new(@string, {
                                 email_obfuscation: :javascript
                               }, :table_of_contents)
    converter \
      .expects(:execute) \
      .with('pandoc --email-obfuscation javascript --table-of-contents') \
      .returns(true)
    assert converter.convert
  end

  it 'uses second arg as option' do
    converter = RubyPandoc::Converter.new(@string, 'toc')
    converter.expects(:execute).with('pandoc --toc').returns(true)
    assert converter.convert
  end

  it 'raises RuntimeError from pandoc executable error' do
    assert_raises(RuntimeError) do
      RubyPandoc::Converter.new('# hello', 'badopt').to_html5
    end
  end

  RubyPandoc::Converter::READERS.each_key do |r|
    it "converts from #{r} with RubyPandoc::Converter.#{r}" do
      converter = RubyPandoc::Converter.send(r, @string)
      converter.expects(:execute).with("pandoc --from #{r}").returns(true)
      assert converter.convert
    end
  end

  RubyPandoc::Converter::STRING_WRITERS.each_key do |w|
    it "converts to #{w} with to_#{w}" do
      converter = RubyPandoc::Converter.new(@string)
      converter \
        .expects(:execute) \
        .with("pandoc --no-wrap --to #{w}") \
        .returns(true)
      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  RubyPandoc::Converter::BINARY_WRITERS.each_key do |w|
    it "converts to #{w} with to_#{w}" do
      converter = RubyPandoc::Converter.new(@string)
      converter \
        .expects(:execute) \
        .with(regexp_matches(/^pandoc --no-wrap --to #{w} --output /)) \
        .returns(true)
      assert converter.send("to_#{w}", :no_wrap)
    end
  end

  it 'works with strings' do
    converter = RubyPandoc::Converter.new('## this is a title')
    assert_match(/h2/, converter.convert)
  end

  it 'aliases to_s' do
    assert_equal @converter.convert, @converter.to_s
  end

  it 'has convert class method' do
    assert_equal @converter.convert, RubyPandoc::Converter.convert(@string, t: :rst)
  end

  it 'runs more than 400 times without error' do
    begin
      400.times do
        RubyPandoc::Converter.convert(@string)
      end
      assert true
    rescue Errno::EMFILE, Errno::EAGAIN => e
      flunk e
    end
  end

  it 'gracefully times out when pandoc hangs due to malformed input' do
    file = File.join(File.dirname(__FILE__), 'files', 'bomb.tex')
    contents = File.read(file)

    assert_raises(RuntimeError) do
      RubyPandoc::Converter.convert(
        contents, from: :latex, to: :html, timeout: 1
      )
    end
  end

  it 'has reader and writer constants' do
    assert_equal RubyPandoc::Converter::READERS,
                 'html'      =>  'HTML',
                 'latex'     =>  'LaTeX',
                 'textile'   =>  'textile',
                 'native'    =>  'pandoc native',
                 'markdown'  =>  'markdown',
                 'json'      =>  'pandoc JSON',
                 'rst'       =>  'reStructuredText'

    assert_equal RubyPandoc::Converter::STRING_WRITERS,
                 'mediawiki'     =>  'MediaWiki markup',
                 'html'          =>  'HTML',
                 'plain'         =>  'plain',
                 'latex'         =>  'LaTeX',
                 's5'            =>  'S5 HTML slideshow',
                 'textile'       =>  'textile',
                 'texinfo'       =>  'GNU Texinfo',
                 'docbook'       =>  'DocBook XML',
                 'html5'         =>  'HTML5',
                 'native'        =>  'pandoc native',
                 'org'           =>  'emacs org mode',
                 'rtf'           =>  'rich text format',
                 'markdown'      =>  'markdown',
                 'man'           =>  'groff man',
                 'dzslides'      =>  'Dzslides HTML slideshow',
                 'beamer'        =>  'Beamer PDF slideshow',
                 'json'          =>  'pandoc JSON',
                 'opendocument'  =>  'OpenDocument XML',
                 'slidy'         =>  'Slidy HTML slideshow',
                 'rst'           =>  'reStructuredText',
                 'context'       =>  'ConTeXt',
                 'asciidoc'      =>  'asciidoc'

    assert_equal RubyPandoc::Converter::BINARY_WRITERS,
                 'odt'   => 'OpenDocument',
                 'docx'  => 'Word docx',
                 'epub'  => 'EPUB V2',
                 'epub3' => 'EPUB V3'

    assert_equal RubyPandoc::Converter::WRITERS,
                 RubyPandoc::Converter::STRING_WRITERS.merge(PanRuby::Converter::BINARY_WRITERS)
  end
end
