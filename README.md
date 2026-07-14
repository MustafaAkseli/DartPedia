# DartPedia

DartPedia is an interactive Wikipedia reader for the terminal, written entirely in Dart.

Search with natural language, choose from numbered results, and read complete articles in a colored, page-by-page terminal interface:

```powershell
dartpedia search chainsaw man the movie
```

## Highlights

- Search Wikipedia without quoting multiword queries
- Select articles from an interactive numbered list
- Read complete articles in 500-word pages
- Navigate with `N` / Right Arrow, `P` / Left Arrow, and `Q`
- Preserve paragraphs and highlight Wikipedia section headings
- Wrap article text automatically to the current terminal width
- Get a quick summary with `--im-feeling-lucky`
- Use non-interactive output for scripts and redirection
- Run `dartpedia` globally from any directory

## Current status

The repository contains three working packages:

- `command_runner`: a custom command framework with commands, positional arguments, options, flags, validation, error handling, colored help text, and configurable output callbacks.
- `wikipedia`: a library for searching Wikipedia, fetching article content and summaries, and converting API JSON responses into typed Dart models.
- `cli`: the final command-line application, with help, Wikipedia search, lucky summaries, article reading, and terminal pagination.

The Wikipedia library is connected to the CLI through dedicated `SearchCommand` and `GetArticleCommand` classes. Runtime errors are handled gracefully and written to dated files under `cli/logs/`.

## Project structure

```text
DartPedia/
|-- pubspec.yaml              # Dart workspace definition
|-- cli/                      # Command-line executable
|   `-- bin/cli.dart
|-- command_runner/           # Reusable CLI parsing and command framework
|   `-- lib/src/
`-- wikipedia/                # Wikipedia API client and data models
    |-- lib/src/api/
    |-- lib/src/model/
    `-- test/
```

## Requirements

- Dart SDK compatible with the version constraint in `pubspec.yaml`
- Internet access for live Wikipedia API calls

Check your Dart installation:

```powershell
dart --version
```

## Setup

Clone the repository and download all workspace dependencies:

```powershell
git clone https://github.com/MustafaAkseli/DartPedia.git
cd DartPedia
dart pub get
```

Install DartPedia as a user-level command:

```powershell
dart pub global activate --source path cli --overwrite
```

On Windows, Dart installs commands under:

```text
%LOCALAPPDATA%\Pub\Cache\bin
```

Add that directory to your user `Path` if the activation command reports that it is missing, then open a new terminal. After that, `dartpedia` can be run from any directory.

## Using the CLI

After installation, run:

```powershell
dartpedia help
```

During development, the original form remains available from the repository root:

```powershell
dart run cli/bin/cli.dart help
```

### Search Wikipedia

Natural-language searches no longer require quotes. Consecutive positional words are combined into one search phrase:

```powershell
dartpedia search Dart
dartpedia search chainsaw man the movie
```

Quotes are still accepted when preferred.

In an interactive terminal, search returns a numbered list and asks you to select an article:

```text
Search results:
1. Dart (programming language) - https://en.wikipedia.org/wiki/Dart_(programming_language)
2. DASL programming language - https://en.wikipedia.org/wiki/DASL_programming_language

Select an article [1-2], or press Q to quit:
```

Enter a result number to open that article in the terminal reader. Use `--links-only` to print results without opening the interactive selector:

```powershell
dartpedia search chainsaw man the movie --links-only
```

When output is redirected or no interactive terminal is attached, DartPedia automatically uses the non-interactive links-only behavior.

### I'm feeling lucky

Add `--im-feeling-lucky` to include a summary of the first result:

```powershell
dartpedia search Dart programming language --im-feeling-lucky
```

### Read an article

The `article` command retrieves an article by its exact title. With no title, it defaults to `cat`.

```powershell
dartpedia article
dartpedia article Dart programming language
```

Articles open in a terminal-aware reader that:

- Divides content into pages of 500 words
- Wraps text to the current terminal width
- Preserves paragraph breaks
- Highlights the article title and Wikipedia section headings
- Clears and redraws the terminal between pages

Navigation does not require pressing Enter:

- `N` or Right Arrow: next page
- `P` or Left Arrow: previous page
- `Q`: close the reader

If the host terminal does not permit raw single-key input, DartPedia automatically falls back to typing `N`, `P`, or `Q` followed by Enter.

To bypass the reader and print the complete article—for example when redirecting it to a file—use:

```powershell
dartpedia article Dart programming language --no-pager
```

The pager is automatically bypassed when no interactive terminal is attached.

### Help

```powershell
dartpedia help
dartpedia help --verbose
dartpedia help --command search
```

Verbose help displays command descriptions, arguments, default values, and options using colored terminal output.

## Command reference

| Command | Purpose |
| --- | --- |
| `dartpedia help` | Show basic usage |
| `dartpedia help --verbose` | Show every command, argument, and option |
| `dartpedia help --command search` | Show detailed help for one command |
| `dartpedia search <query>` | Search and interactively select an article |
| `dartpedia search <query> --links-only` | Print results without interaction |
| `dartpedia search <query> --im-feeling-lucky` | Show the top result summary |
| `dartpedia article [title]` | Read an article with pagination |
| `dartpedia article [title] --no-pager` | Print the complete article |

## Logging

DartPedia creates dated log files under `cli/logs/`. Network, data-format, command, and unexpected application errors are recorded with appropriate severity levels. The directory is ignored by Git.

## Using the Wikipedia library

The `wikipedia` package publicly exports these API functions:

- `search(String searchTerm)` searches Wikipedia and returns `SearchResults`.
- `getArticleByTitle(String title)` returns matching full article extracts.
- `getArticleSummaryByTitle(String title)` returns a typed article summary.
- `getRandomArticleSummary()` returns a random article summary.

Example library usage from another workspace package:

```dart
import 'package:wikipedia/wikipedia.dart';

Future<void> main() async {
  final results = await search('Dart programming language');

  for (final result in results.results) {
    print('${result.title}: ${result.url}');
  }
}
```

## Validation

Analyze the entire workspace from the repository root:

```powershell
dart analyze
```

Tests should be run from each package directory because the Wikipedia tutorial fixtures use paths relative to that package:

```powershell
cd cli
dart test

cd ../command_runner
dart test

cd ../wikipedia
dart test
```

The test suites cover:

- CLI command configuration
- Natural-language argument parsing
- Custom executable usage text
- Exact 500-word page boundaries
- Next, previous, and quit navigation
- Terminal-width wrapping
- Wikipedia JSON model deserialization

The Wikipedia fixture tests should be run from the `wikipedia` package because their sample-data paths are package-relative.

## Updating or removing the installed command

If executable metadata or dependencies change, reactivate the local package:

```powershell
dart pub global activate --source path cli --overwrite
```

To remove the global command:

```powershell
dart pub global deactivate cli
```

## Next steps

- Add command-runner parsing and error-handling tests.
- Add HTTP client injection or mocks for deterministic API tests.
- Add configurable result limits and language selection.
- Add article caching, history, and favorites.
- Choose and add a project license.

## Learning source

This project follows the [official Dart tutorial](https://dart.dev/learn/tutorial).

## License

No license has been added yet. Until a license is selected, the repository remains copyrighted by its owner.
