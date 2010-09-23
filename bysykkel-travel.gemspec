# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bysykkel-travel}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Espen Antonsen & Rune Botten"]
  s.date = %q{2010-09-23}
  s.description = %q{Query Clear Channel Bysykkel racks with Ruby}
  s.email = %q{espen@inspired.no}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".gitignore",
     "CHANGES",
     "Gemfile",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/bysykkel_travel.rb",
     "lib/bysykkel_travel/rack.rb",
     "lib/bysykkel_travel/utils.rb",
     "spec/fixtures/rack.xml",
     "spec/options",
     "spec/spec.opts",
     "spec/bysykkel_travel/rack_spec.rb",
     "spec/bysykkel_travel/utils_spec.rb",
     "bysykkel-travel.gemspec"
  ]
  s.homepage = %q{http://github.com/espen/bysykkel-travel}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Bysykkel Travel Planner}
  s.test_files = [
     "spec/bysykkel_travel/rack_spec.rb",
     "spec/bysykkel_travel/utils_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_runtime_dependency(%q<nokogiri>, [">= 1.4.1"])
      s.add_runtime_dependency(%q<geoutm>, [">= 0.0.4"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<nokogiri>, [">= 1.4.1"])
      s.add_dependency(%q<geoutm>, [">= 0.0.4"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<nokogiri>, [">= 1.4.1"])
    s.add_dependency(%q<geoutm>, [">= 0.0.4"])
  end
end

