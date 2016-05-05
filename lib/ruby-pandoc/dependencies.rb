require 'mkmf'
require 'tmpdir'

PANDOC_MIN_VERSION = '1.6' # min version with epub
PANDOC_URL = 'https://github.com/jgm/pandoc/releases/download/1.17.0.2/pandoc-1.17.0.2-1-amd64.deb' # FIXME

module MakeMakefile::Logging
  @logfile = File::NULL
end

module Publication
  module Dependencies
    extend self

    def satisfied?
      has_pandoc
      has_latex
    end

    def satisfy
      get_pandoc
      get_latex
    end

  private

    def has_pandoc
      pandoc = find_executable 'pandoc'
      unless pandoc
        puts 'Pandoc is not installed'
        return false
      end
      version = `#{pandoc} -v`.lines.first.split(/\s+/).last
      unless Gem::Version.new(version) > Gem::Version.new(PANDOC_MIN_VERSION)
        puts "Pandoc version #{version} too old (require #{PANDOC_MIN_VERSION})"
        return false
      end
      true
    end

    def has_latex
      find_executable 'pdflatex'
    end

    # FIXME make this conditional to different types of platforms
    def get_pandoc
      return if has_pandoc
      Dir.mktmpdir do |dir|
        Dir.chdir(dir) do
          system("wget #{PANDOC_URL} -O pandoc.deb")
          system("dpkg -i pandoc.deb")
        end
      end
    end

    def get_latex
      system('apt-get install -y --force-yes texlive-full')
    end
  end
end
