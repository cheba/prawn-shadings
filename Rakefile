require 'rspec/core/rake_task'
require 'rdoc/task'

desc "genrates documentation"
RDoc::Task.new do |rdoc|
  rdoc.rdoc_files.include( "README.md",
                           "LICENSE", "BSDL",
                           "lib/" )
  rdoc.main     = "README.md"
  rdoc.rdoc_dir = "doc/html"
  rdoc.title    = "Prawn Shadings Documentation"
end

desc "Run all rspec files"
RSpec::Core::RakeTask.new("spec")

desc "Run tests"
task default: :spec
