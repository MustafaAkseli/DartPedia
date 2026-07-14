# DartPedia

DartPedia is a command-line application written in Dart. Its goal is to provide a simple terminal interface for searching Wikipedia while also exploring how a reusable command-line argument parser and command runner can be built from scratch.

> **Development status:** DartPedia is a work in progress. The custom command runner and `help` command are available now. Wikipedia search functionality is planned but is not yet enabled in the executable.

## Current features

- A reusable `command_runner` package
- Registration and execution of named commands
- Parsing for positional arguments, long options, short option abbreviations, and boolean flags
- Validation and custom exceptions for invalid command-line input
- A built-in `help` command that prints usage information
- Asynchronous command execution and optional error handling

## Project structure

```text
DartPedia/
|-- cli/                  # DartPedia command-line application
|   |-- bin/cli.dart      # Executable entry point
|   |-- lib/              # CLI library code
|   `-- test/             # CLI tests
`-- command_runner/       # Reusable command framework
    |-- lib/src/          # Commands, arguments, parser, and exceptions
    |-- example/          # Package usage example
    `-- test/             # Command runner tests
```

The CLI uses `command_runner` through a local path dependency, so both directories should remain next to each other.

## Requirements

- [Dart SDK](https://dart.dev/get-dart) compatible with the SDK constraint in the package files

You can confirm your installation with:

```shell
dart --version
```

## Installation

Clone the repository:

```shell
git clone https://github.com/MustafaAkseli/DartPedia.git
cd DartPedia
```

Install the dependencies for both packages:

```shell
cd command_runner
dart pub get

cd ../cli
dart pub get
```

## Usage

Run the CLI from the `cli` directory:

```shell
dart run bin/cli.dart help
```

Current output is similar to:

```text
Usage: dart run bin/cli.dart <command> [commandArg?] [...options?]
 help:  Prints usage information to the command line.
```

The help command also defines these options for future detailed help output:

```shell
dart run bin/cli.dart help --verbose
dart run bin/cli.dart help --command <command-name>
```

Option parsing exists, but the current help implementation does not yet change its output based on these options.

## Development

Run static analysis separately in each package:

```shell
cd command_runner
dart analyze

cd ../cli
dart analyze
```

Run the tests:

```shell
cd command_runner
dart test

cd ../cli
dart test
```

## Roadmap

- Add a `search` command
- Retrieve article summaries from the Wikipedia API
- Format API responses for terminal output
- Expand help output for individual commands and verbose mode
- Add comprehensive parser, command, and CLI tests
- Improve package metadata and error messages

## Contributing

This project is currently an educational work in progress. Suggestions, bug reports, and focused pull requests are welcome.

## License

No license has been added yet. Until a license is selected, the repository remains copyrighted by its owner.
