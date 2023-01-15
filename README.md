# Asimov

[![Gem Version](https://badge.fury.io/rb/asimov.svg)](https://badge.fury.io/rb/asimov)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/petergoldstein/asimov/blob/main/LICENSE.txt)
[![Tests](https://github.com/petergoldstein/asimov/actions/workflows/ci.yml/badge.svg)](https://github.com/petergoldstein/asimov/actions/workflows/ci.yml)

Asimov is a gem that enables the use of OpenAI's ML capabilities within SaaS applications.  With that in mind it includes:

* The ability to use multiple OpenAI configurations (API keys and organization ids) within a single application.
* Support for configuring connections with timeouts and proxies to make applications robust against failure and to support complex network environments.
* Methods for all non-streaming endpoints in the [OpenAI API](https://openai.com/blog/openai-api/).  (Streaming support is under consideration).


You can use this gem to write applications that generate text with GPT-3, create images with DALL·E, or write code with Codex.

The name Asimov is a tribute to [Isaac Asimov](https://en.wikipedia.org/wiki/Isaac_Asimov), a 20th century author whose work referenced AI extensively, most famously with his ["Three Laws of Robotics"](https://en.wikipedia.org/wiki/Three_Laws_of_Robotics). Asimov's stories explored the ethical and philosophical implications of using artificial intelligence and robots in society, and he is often credited with helping to popularize the concept of AI in science fiction. His work has had a lasting impact on the genre and has influenced many other writers and thinkers.


## Documentation and Information

* [User Documentation](https://github.com/petergoldstein/asimov/wiki) - The documentation is maintained in the repository's wiki.  
* [Announcements](https://github.com/petergoldstein/asimov/discussions/categories/announcements) - Announcements of interest to the Asimov community will be posted here.
* [Bug Reports](https://github.com/petergoldstein/asimov/issues) - If you discover a problem with Asimov, please submit a bug report in the tracker.
* [Client API](https://rubydoc.info/github/petergoldstein/asimov/Asimov/Client) - Ruby documentation for the `Asimov::Client` API

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/petergoldstein/asimov>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/petergoldstein/asimov/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ruby-openai project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/petergoldstein/asimov/blob/main/CODE_OF_CONDUCT.md).

## Appreciation

Asimov was originally created from a fork of the [ruby-openai](https://github.com/alexrudall/ruby-openai).  It would not exist without the work of [alexrudall](https://github.com/alexrudall) and other contributors to that gem.
