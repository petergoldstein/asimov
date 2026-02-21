require_relative "lib/asimov/version"

Gem::Specification.new do |spec|
  spec.name          = "asimov"
  spec.version       = Asimov::VERSION
  spec.authors       = ["Peter M. Goldstein"]
  spec.email         = ["peter.m.goldstein@gmail.com"]

  spec.summary       = "A Ruby client for the OpenAI API support for multiple API " \
                       "configurations in a single app, robust and simple error handling, " \
                       "and network-level configuration."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/petergoldstein/asimov"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.3.0")

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

  spec.add_dependency "httparty", ">= 0.18.1", "< 0.25.0"
end
