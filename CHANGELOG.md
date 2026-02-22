# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2026-02-22

### Added

- Realtime API (`Client#realtime`) with WebSocket-based `connect` method and `Session` object for event-driven interaction
- Automatic retry with exponential backoff for `TooManyRequestsError` and `ServerError` (configure via `Asimov.configure { |c| c.max_retries = 3 }`)
- Request logging hooks (configure via `Asimov.configure { |c| c.logger = Logger.new(STDOUT) }`)
- `websocket-client-simple` runtime dependency for Realtime API
- `max_retries`, `logger`, and `log_level` configuration options

## [2.3.0] - 2026-02-22

### Added

- Uploads API (`Client#uploads`) with `create`, `add_part`, `complete`, `cancel` for resumable large file uploads
- Conversations API (`Client#conversations`) with `list`, `retrieve`, `delete`

## [2.2.0] - 2026-02-22

### Added

- Responses API (`Client#responses`) with `create` (streaming via block), `retrieve`, `delete`, `list_input_items`
- Vector Stores API (`Client#vector_stores`) with full CRUD, `search`, file management (`create_file`, `list_files`, `retrieve_file`, `delete_file`), and file batch operations (`create_file_batch`, `retrieve_file_batch`, `cancel_file_batch`, `list_file_batch_files`)

## [2.1.0] - 2026-02-22

### Added

- Fine-tuning Jobs API (`Client#fine_tuning`) with `create`, `list`, `retrieve`, `cancel`, `list_events`, `list_checkpoints`
- Batch API (`Client#batches`) with `create`, `retrieve`, `cancel`, `list`
- Audio Text-to-Speech (`Audio#create_speech`) with binary return and streamed download via `writer:` parameter
- Binary download primitive (`rest_create_w_json_params_binary`) in Base
- Streamed download primitive (`rest_create_w_json_params_streamed_download`) in Base
- Pagination support for `rest_index` via optional `parameters:` keyword argument

### Changed

- Extracted streaming/binary REST primitives into `ApiV1::Streaming` module for maintainability

## [2.0.0] - 2026-02-21

### Removed

- Removed `Asimov::ApiV1::Edits` (OpenAI removed the Edits API)
- Removed `Asimov::ApiV1::Completions` (legacy endpoint, replaced by Chat Completions)
- Removed `Asimov::ApiV1::Finetunes` (removed Jan 2024, replaced by Fine-tuning Jobs API)
- Removed `TrainingFileValidator`, `ClassificationsFileValidator`, `TextEntryFileValidator`
- Removed `InvalidTrainingExampleError`, `InvalidTextEntryError`, `InvalidClassificationError`
- Removed `StreamingResponseNotSupportedError` (streaming is now supported)
- Removed `Client#completions`, `Client#edits`, `Client#finetunes` accessors

### Added

- SSE streaming support for Chat Completions via block syntax
- `ServerError` and `ServiceUnavailableError` for HTTP 500/503 responses
- `project_id` configuration for OpenAI project-scoped API keys (`OpenAI-Project` header)
- `event_stream_parser` runtime dependency for SSE parsing

### Changed

- Renamed `Chat#create_completions` to `Chat#create`
- Relaxed `ChatMessagesValidator` to accept any role string and allow additional message keys
- Simplified file upload validation: only JSONL-validates `fine-tune` and `batch` purposes
- Bumped minimum version to 2.0.0

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

