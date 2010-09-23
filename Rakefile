require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "bysykkel"
    gem.summary = %Q{Bysykkel API Wrapper}
    gem.description = %Q{Query the city bike availability API at clearchannel.no with Ruby}
    gem.email = "espen@inspired.no"
    gem.homepage = "http://github.com/espen/bysykkel"
    gem.authors = ["Espen Antonsen & Rune Botten"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency('nokogiri', '>= 1.4.1')
    gem.add_dependency('geoutm', '>= 0.0.4') # --source http://gems.github.com
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts << '-O spec/spec.opts'
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "bysykkel #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end