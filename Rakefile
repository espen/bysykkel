require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "trafikanten-travel"
    gem.summary = %Q{Trafikanten.no Travel Planner}
    gem.description = %Q{Query the travel planner at trafikanten.no with Ruby}
    gem.email = "rbotten@gmail.com"
    gem.homepage = "http://github.com/runeb/trafikanten-travel"
    gem.authors = ["Rune Botten"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    gem.add_dependency('nokogiri', '>= 1.4.1')
    gem.add_dependency('tallakt-geoutm', '>= 0.0.3') # --source http://gems.github.com
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
  rdoc.title = "trafikanten-travel #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
