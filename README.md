![build status](https://travis-ci.org/dalehamel/ruby-pandoc.svg)

# RubyPandoc

RubyPandoc is a wrapper for [Pandoc](http://johnmacfarlane.net/pandoc/), a
Haskell library with command line tools for converting one markup format to
another.

Pandoc can convert documents in markdown, reStructuredText, textile, HTML,
DocBook, LaTeX, or MediaWiki markup to a variety of formats, including
markdown, reStructuredText, HTML, LaTeX, ConTeXt, PDF, RTF, DocBook XML,
OpenDocument XML, ODT, GNU Texinfo, MediaWiki markup, groff man pages,
HTML slide shows, EPUB, and Microsoft Word docx.

*This documentation is for version 2 and higher. For version 1 documentation
[see here](https://github.com/alphabetum/ruby-pandoc/blob/v1.0.0/README.markdown).*

## Installation

First, make sure to
[install Pandoc](http://johnmacfarlane.net/pandoc/installing.html).

Next, add RubyPandoc to your Gemfile

```ruby
gem 'ruby-pandoc'
```

or install RubyPandoc from [RubyGems](http://rubygems.org/gems/ruby-pandoc).

```bash
gem install ruby-pandoc
```

## Usage

```ruby
require 'ruby-pandoc'
@converter = RubyPandoc.new('# Markdown Title', :from => :markdown, :to => :rst)
puts @converter.convert
```

This takes the Markdown formatted file and converts it to reStructuredText.

You can also use the `#convert` class method:

```ruby
puts RubyPandoc.convert('# Markdown Title', :from => :markdown, :to => :html)
```

Other arguments are simply converted into command line options, accepting
symbols or strings for options without arguments and hashes of strings or
symbols for options with arguments.

```ruby
RubyPandoc.convert('# Markdown Title', :s, {:f => :markdown, :to => :rst}, 'no-wrap', :table_of_contents)
```

is equivalent to

```bash
echo "# Markdown Title" | pandoc -s -f markdown --to=rst --no-wrap --table-of-contents
```

Also provided are `#to_[writer]` instance methods for each of the writers,
and these can also accept options:

```ruby
RubyPandoc.new("# Some title").to_html(:no_wrap)
# => "<div id=\"some-title\"><h1>Some title</h1></div>"
# or
RubyPandoc.new("# Some title").to_rst
# => "Some title\n=========="
```

Similarly, there are class methods for each of the readers, so readers
and writers can be specified like this:

```ruby
RubyPandoc.html("<h1>hello</h1>").to_latex
# => "\\section{hello}"
```

RubyPandoc assumes the `pandoc` executable is via your environment's `$PATH`
variable.  If you'd like to set an explicit path to the `pandoc` executable,
you can do so with  `RubyPandoc.pandoc_path = '/path/to/pandoc'`

RubyPandoc can also take an array of one or more file paths as the first
argument. The files will be concatenated together with a blank line between
each and used as input.

```ruby
# One file path as a single-element array.
RubyPandoc.html(['/path/to/file1.html']).to_markdown
# Multiple file paths as an array.
RubyPandoc.html(['/path/to/file1.html', '/path/to/file2.html']).to_markdown
```

Available format readers and writers are available in the `RubyPandoc::READERS`
and `RubyPandoc::WRITERS` constants.

For more information on Pandoc, see the
[Pandoc documentation](http://johnmacfarlane.net/pandoc/)
or run `man pandoc`
([also available here](http://johnmacfarlane.net/pandoc/pandoc.1.html)).

If you'd prefer a pure-Ruby extended markdown interpreter that can output a
few different formats, take a look at [Maruku](http://maruku.rubyforge.org/).
If you want to use the full reStructuredText syntax from within Ruby, check
out [RbST](https://github.com/alphabetum/rbst), a docutils wrapper.

This gem was forked from [pandoc-ruby](https://github.com/alphabetum/pandoc-ruby). For a
slightly different approach to using Pandoc with Ruby, see
[Pandoku](http://github.com/dahlia/pandoku).

## Additional Notes

If you are trying to generate a standalone file with full file headers rather
than just a marked up fragment, remember to pass the `:standalone` option so
the correct header and footer are added.

```ruby
RubyPandoc.new("# Some title", :standalone).to_rtf
```

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but
  bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.
