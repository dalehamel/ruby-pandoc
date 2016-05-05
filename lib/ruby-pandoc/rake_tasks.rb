require 'rake'

module RubyPandoc
  module Tasks
    extend self

    def load_all
      Dir.glob("#{File.expand_path('../../tasks', __FILE__)}/*.rake").each { |r| load r }
    end
  end
end

RubyPandoc::Tasks.load_all
