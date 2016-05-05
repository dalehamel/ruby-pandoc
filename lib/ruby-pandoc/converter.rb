require 'open3'
require 'tempfile'

module RubyPandoc
  class Converter
    @@pandoc_path = 'pandoc'

    # The available readers and their corresponding names. The keys are used to
    # generate methods and specify options to Pandoc.
    READERS = {
      'native'   => 'pandoc native',
      'json'     => 'pandoc JSON',
      'markdown' => 'markdown',
      'rst'      => 'reStructuredText',
      'textile'  => 'textile',
      'html'     => 'HTML',
      'latex'    => 'LaTeX'
    }.freeze

    # The available string writers and their corresponding names. The keys are
    # used to generate methods and specify options to Pandoc.
    STRING_WRITERS = {
      'native'        => 'pandoc native',
      'json'          => 'pandoc JSON',
      'html'          => 'HTML',
      'html5'         => 'HTML5',
      's5'            => 'S5 HTML slideshow',
      'slidy'         => 'Slidy HTML slideshow',
      'dzslides'      => 'Dzslides HTML slideshow',
      'docbook'       => 'DocBook XML',
      'opendocument'  => 'OpenDocument XML',
      'latex'         => 'LaTeX',
      'beamer'        => 'Beamer PDF slideshow',
      'context'       => 'ConTeXt',
      'texinfo'       => 'GNU Texinfo',
      'man'           => 'groff man',
      'markdown'      => 'markdown',
      'plain'         => 'plain',
      'rst'           => 'reStructuredText',
      'mediawiki'     => 'MediaWiki markup',
      'textile'       => 'textile',
      'rtf'           => 'rich text format',
      'org'           => 'emacs org mode',
      'asciidoc'      => 'asciidoc'
    }.freeze

    # The available binary writers and their corresponding names. The keys are
    # used to generate methods and specify options to Pandoc.
    BINARY_WRITERS = {
      'odt'   => 'OpenDocument',
      'docx'  => 'Word docx',
      'epub'  => 'EPUB V2',
      'epub3' => 'EPUB V3'
    }.freeze

    # All of the available Writers.
    WRITERS = STRING_WRITERS.merge(BINARY_WRITERS)

    # To use run the pandoc command with a custom executable path, the path
    # to the pandoc executable can be set here.
    def self.pandoc_path=(path)
      @@pandoc_path = path
    end

    # Create a new RubyPandoc converter object. The first argument contains the
    # input either as string or as an array of filenames.
    #
    # Any other arguments will be converted to pandoc options.
    #
    # Usage:
    #   new("# A String", :option1 => :value, :option2)
    #   new(["/path/to/file.md"], :option1 => :value, :option2)
    #   new(["/to/file1.html", "/to/file2.html"], :option1 => :value)
    def initialize(*args)
      @input_files = nil
      @input_string = nil
      if args[0].is_a?(String)
        @input_string = args.shift
      elsif args[0].is_a?(Array)
        @input_files = args.shift.join(' ')
      end
      @options = args || []
      @option_string = nil
      @binary_output = false
      @writer = 'html'
    end

    # Run the conversion. The convert method can take any number of arguments,
    # which will be converted to pandoc options. If options were already
    # specified in an initializer or reader method, they will be combined with
    # any that are passed to this method.
    #
    # Returns a string with the converted content.
    #
    # Example:
    #
    #   RubyPandoc.new("# text").convert
    #   # => "<h1 id=\"text\">text</h1>\n"
    def convert(*args)
      tmp_file = Tempfile.new('pandoc-conversion')
      @options += args if args
      @options += [{ output: tmp_file.path }]
      @option_string = prepare_options(@options)
      output = begin
        run_pandoc
        IO.binread(tmp_file)
      ensure
        tmp_file.close
        tmp_file.unlink
      end
    end

    # Generate class methods for each of the readers in RubyPandoc::READERS.
    # When one of these methods is called, it simply calls the initializer
    # with the `from` option set to the reader key, and returns the object.
    #
    # Example:
    #
    #   RubyPandoc.markdown("# text")
    #   # => #<RubyPandoc:0x007 @input_string="# text", @options=[{:from=>"markdown"}]
    class << self
      READERS.each_key do |r|
        define_method(r) do |*args|
          args += [{ from: r }]
          new(*args)
        end
      end
    end

    # Generate instance methods for each of the writers in RubyPandoc::WRITERS.
    # When one of these methods is called, it simply calls the `#convert` method
    # with the `to` option set to the writer key, thereby returning the
    # converted string.
    #
    # Example:
    #
    #   RubyPandoc.new("# text").to_html
    #   # => "<h1 id=\"text\">text</h1>\n"
    WRITERS.each_key do |w|
      define_method(:"to_#{w}") do |*args|
        args += [{ to: w.to_sym }]
        convert(*args)
      end
    end

    private

    # Execute the pandoc command for binary writers. A temp file is created
    # and written to, then read back into the program as a string, then the
    # temp file is closed and unlinked.
    def convert_binary
    end

     # Wrapper to run pandoc in a consistent, DRY way
    def run_pandoc
      command = unless @input_files.nil? || @input_files.empty?
        "#{@@pandoc_path} #{@input_files} #{@option_string}"
      else
        "#{@@pandoc_path} #{@option_string}"
      end
      output = error = exit_status = nil
      options = {}
      options[:stdin_data] = @input_string if @input_string
      output, error, exit_status = Open3.capture3(command, **options)
      raise error unless exit_status && exit_status.success?
      output
    end

    # Builds the option string to be passed to pandoc by iterating over the
    # opts passed in. Recursively calls itself in order to handle hash options.
    def prepare_options(opts = [])
      opts.inject('') do |string, (option, value)|
        string += case
                  when value
                    create_option(option, value)
                  when option.respond_to?(:each_pair)
                    prepare_options(option)
                  else
                    create_option(option)
                  end
      end
    end

    # Takes a flag and optional argument, uses it to set any relevant options
    # used by the library, and returns string with the option formatted as a
    # command line options. If the option has an argument, it is also included.
    def create_option(flag, argument = nil)
      return '' unless flag
      flag = flag.to_s
      set_pandoc_ruby_options(flag, argument)
      if !argument.nil?
        "#{format_flag(flag)} #{argument}"
      else
        format_flag(flag)
      end
    end

    # Formats an option flag in order to be used with the pandoc command line
    # tool.
    def format_flag(flag)
      if flag.length == 1
        " -#{flag}"
      else
        " --#{flag.to_s.tr('_', '-')}"
      end
    end

    # Takes an option and optional argument and uses them to set any flags
    # used by RubyPandoc.
    def set_pandoc_ruby_options(flag, argument = nil)
      case flag
      when 't', 'to'
        @writer = argument.to_s
        @binary_output = true if BINARY_WRITERS.keys.include?(@writer)
      end
    end
  end
end
