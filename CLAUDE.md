# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What is Asimov?

Asimov is a Ruby gem providing an OpenAI API client. It supports multiple API configurations (different API keys/organization IDs) within a single application, configurable network options (timeouts, proxies, SSL), and covers all non-streaming OpenAI API endpoints. Originally forked from the ruby-openai gem.

## Commands

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake        # or: bundle exec rspec

# Run a single test file
bundle exec rspec spec/asimov/client_spec.rb

# Run a specific test by line number
bundle exec rspec spec/asimov/client_spec.rb:42

# Re-record VCR cassettes against live API
RUN_LIVE=true bundle exec rspec

# Lint
bundle exec rubocop

# Lint with auto-correct
bundle exec rubocop -A

# Interactive console
bin/console
```

## Architecture

### Client Delegation Pattern

`Asimov::Client` is the main entry point. It lazily instantiates endpoint-specific API objects (Audio, Chat, Files, Images, etc.) that live under `Asimov::ApiV1::`. Each endpoint class inherits from `ApiV1::Base`, which includes HTTParty and provides REST primitives (`rest_index`, `rest_get`, `rest_delete`, `rest_create_w_json_params`, `rest_create_w_multipart_params`, `rest_get_streamed_download`).

```
Client → ApiV1::Chat     → Base (HTTParty)
       → ApiV1::Audio    → Base
       → ApiV1::Images   → Base
       → ApiV1::Files    → Base
       → ...
```

### Configuration

Two-level configuration: global (`Asimov.configure`) and per-client (constructor args). Client-level settings merge with and override global settings. `HeadersFactory` constructs auth/organization headers from this configuration.

### Error Hierarchy

`Asimov::Error` has a deep class hierarchy splitting into `ConfigurationError`, `RequestError`, `NetworkError`, `AuthorizationError`, `ParameterError`, `FileDataError`, etc. API HTTP errors are mapped to specific exception classes via `ApiErrorTranslator`; network-level errors via `NetworkErrorTranslator`.

### Validators

`Asimov::Utils::` contains validators for chat messages, JSONL files, training files, request options, etc. These perform client-side validation before API calls.

## Code Style

- Ruby 3.0+ target
- Double quotes for strings (`Style/StringLiterals: double_quotes`)
- 100-character line length max
- No frozen string literal comments
- RuboCop with rubocop-performance, rubocop-rake, rubocop-rspec extensions

## Testing

- RSpec with `expect` syntax only
- VCR + WebMock for HTTP interaction recording (cassettes in `spec/fixtures/cassettes/`)
- Feature tests (`spec/feature/`) are integration tests using VCR cassettes tagged with `:vcr` metadata
- Unit tests (`spec/asimov/`) test classes in isolation
- `spec/support/utils.rb` provides helpers for config reset and fixture loading
- Global configuration is reset before each test; VCR-tagged tests load API credentials
