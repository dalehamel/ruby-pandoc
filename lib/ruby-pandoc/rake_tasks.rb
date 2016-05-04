require 'rake'

module Publisher
  # Loads all rake tasks when terraform_dsl is included by a rake script
  module Tasks
    extend self

    def load_all
      Dir.glob("#{File.expand_path('../../tasks', __FILE__)}/*.rake").each { |r| load r }
    end
  end
end

Publisher::Tasks.load_all
