require 'ruby-pandoc/rake_tasks'

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "ruby-pandoc #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task default: :spec
rescue LoadError
  puts 'no rspec available'
end
