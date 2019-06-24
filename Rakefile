require "rake/testtask"
require 'rdoc/task'

Rake::TestTask.new do |t|
  t.libs << "lib"
  t.libs << "test"
  t.test_files = FileList['test/*_test.rb']
end



RDoc::Task.new do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/*.rb")
  rdoc.rdoc_dir = "website/docs"
end

RDoc::Task.new :rdoc_coverage do |rdoc|
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("README.md", "lib/*.rb")
  rdoc.rdoc_dir = "website/docs"
  rdoc.options << '-C'
end

task :default => [:test]
