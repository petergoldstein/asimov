# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

## [1.1.0] - 2023-03-01

### Added

- Made API base URI configurable to support services that proxy API calls (like Helicone)
- Added support for the chat and audio endpoints

## [1.0.0] - 2023-01-24

This version has complete coverage of the OpenAI API (except for stream: true behavior), has
no known errors and has full test coverage.  At this point there are no anticipated changes
to existing endpoints.

### Fixed

- Fixed handling of authentication errors

### Changed

- Properly distinguished public and private methods to ensure proper documentation.
- Renamed events to list_events for consistency
- Updated file arguments to take path strings or File-like objects
- Adjusted endpoints to make required parameters more explicit

### Added

- Code level documentation for all public classes and methods.
- Error for the unsupported stream: true case
- Error mapping for 409 and 429 errors
- Specs for authentication

## [0.1.0] - 2023-01-14

This initial version of the gem is now suitable for use.  API endpoint method naming may shift slightly.

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

