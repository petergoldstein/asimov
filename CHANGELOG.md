# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2023-01-14

This initial version of the gem is now suitable for use.  API endpoint method naming may shift slightly, 

### Changed

- Refactored code base to better accord with SOLID principles and support better unit testing
- `access_token` is now `api_key` to better accord with OpenAI documentation
- Renamed some endpoint methods from the original codebase
- API method default argument now reflect whether a parameter is required
- For errors resulting from an exception raised in the HTTP stack, API endpoints raise subclasses of Asimov::NetworkError
- For errors returned in an OpenAI payload, API endpoint methods raise subclasses of Asimov::RequestError
- API Endpoint methods now return parsed JSON
- Repackaged original code into asimov

### Added

- Method for the files content endpoint
- Method for the models delete endpoint
- Feature test coverage for all endpoint methods
- Unit testing for all classes
- Header and body matching for all VCR specs, including multipart POST
- Support for the use of multiple OpenAI configurations within the same application
- SimpleCov execution for testing
- GitHub Actions for CI
- Forked code from alexrudall/ruby-openai

