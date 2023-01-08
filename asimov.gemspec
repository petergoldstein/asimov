require_relative "lib/asimov/version"

Gem::Specification.new do |spec|
  spec.name          = "asimov"
  spec.version       = Asimov::VERSION
  spec.authors       = ["Peter M. Goldstein"]
  spec.email         = ["peter.m.goldstein@gmail.com"]

  spec.summary       = "A Ruby gem for the OpenAI GPT-3 API"
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/petergoldstein/asimov"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/petergoldstein/asimov"
  spec.metadata["changelog_uri"] = "https://github.com/petergoldstein/asimov/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.glob("lib/**/*") + [
    "LICENSE.txt",
    "README.md",
    "CHANGELOG.md",
    "Gemfile"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", ">= 0.18.1", "< 0.22.0"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "rubocop", "~> 1.42.0"
  spec.add_development_dependency "rubocop-rake"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "vcr", "~> 6.1.0"
  spec.add_development_dependency "webmock", "~> 3.18.1"
end
