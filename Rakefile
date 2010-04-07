require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "congo"
    gem.summary = %Q{Library to define flexible schemas for mongodb documents. }
    gem.email = ["papipo@gmail.com", "didier@nocoffee.fr"]
    gem.homepage = "http://github.com/Papipo/congo"
    gem.authors = ["Rodrigo Alvarez", "Didier Lafforgue"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_development_dependency "mongo_mapper", ">= 0.7.2"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

Spec::Rake::SpecTask.new('spec:unit') do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/unit/**/*_spec.rb']
end

Spec::Rake::SpecTask.new('spec:functionals') do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/functional/**/*_spec.rb']
end

task :spec => [:check_dependencies, 'spec:unit', 'spec:functionals']

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "congo #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
