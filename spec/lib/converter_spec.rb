require File.expand_path('../../spec_helper.rb', __FILE__)

RSpec.describe RubyPandoc::Converter do

  let(:file1) { File.join(FIXTURES_PATH, 'test.md') }
  let(:file2) { File.join(FIXTURES_PATH, 'test2.md') }
  let(:string1) { '# Test String' }
  let(:string1_html) { '<h1 id="test-string">Test String</h1>' }

  after do
    RubyPandoc::Converter.pandoc_path = 'pandoc'
  end

  it 'Can convert input passed as a string' do
    converter = RubyPandoc::Converter.new(string1)
    expect(converter.to_html).to match(string1_html)
  end

  it 'Accepts a manually specified pandoc path' do
    path = '/usr/bin/env pandoc'
    RubyPandoc::Converter.pandoc_path = path
    converter = RubyPandoc::Converter.new(string1)
    expect(converter.to_html).to match(string1_html)
  end

  it 'converts single element array input as array of file paths' do
    expect(RubyPandoc::Converter.new([file1]).to_html).to match(/This is a Title/)
  end

  it 'converts multiple element array input as array of file paths' do
    expect(RubyPandoc::Converter.new([file1, file2]).to_html).to match(/This is a Title/)
    expect(RubyPandoc::Converter.new([file1, file2]).to_html).to match(/A Second Title/)
  end

  it 'converts multiple element array input as array of file paths to a binary output format' do
    expect(RubyPandoc::Converter.new([file1, file2]).to_epub).to match(/com.apple.ibooks/)
  end

  it 'accepts short options' do
    converter = RubyPandoc::Converter.new(string1, t: :html)
    expect(converter.convert).to match(string1_html)
  end

  it 'accepts long options' do
    converter = RubyPandoc::Converter.new(string1, to: :html)
    expect(converter.convert).to match(string1_html)
  end

  it 'creates wrappers for reader methods' do
    expect(RubyPandoc::Converter.markdown(string1).to_html).to match(string1_html)
  end
end
