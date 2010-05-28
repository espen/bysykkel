# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{trafikanten-travel}
  s.version = "0.2.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Rune Botten"]
  s.date = %q{2010-05-25}
  s.description = %q{Query the travel planner at trafikanten.no with Ruby}
  s.email = %q{rbotten@gmail.com}
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
     "lib/trafikanten_travel.rb",
     "lib/trafikanten_travel/route.rb",
     "lib/trafikanten_travel/station.rb",
     "lib/trafikanten_travel/utils.rb",
     "spec/fixtures/route.html",
     "spec/fixtures/route_search.html",
     "spec/options",
     "spec/spec.opts",
     "spec/trafikanten_travel/route_spec.rb",
     "spec/trafikanten_travel/station_spec.rb",
     "spec/trafikanten_travel/utils_spec.rb",
     "trafikanten-travel.gemspec"
  ]
  s.homepage = %q{http://github.com/runeb/trafikanten-travel}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Trafikanten.no Travel Planner}
  s.test_files = [
    "spec/trafikanten_travel/route_spec.rb",
     "spec/trafikanten_travel/station_spec.rb",
     "spec/trafikanten_travel/utils_spec.rb"
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
