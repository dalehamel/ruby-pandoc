require 'ruby-pandoc/dependencies'

desc 'Assert that dependencies are installed'
task 'check_depends' do
  RubyPandoc::Dependencies.satisfied?
end

desc 'Install necessary dependencies'
task 'get_depends' do
  RubyPandoc::Dependencies.satisfy
end
