import 'dart:async';
import 'dart:io';

import 'package:command_runner/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:wikipedia/wikipedia.dart';

import '../terminal.dart';

class SearchCommand extends Command {
  SearchCommand({required this.logger, Terminal? terminal})
    : terminal = terminal ?? SystemTerminal() {
    pager = ArticlePager(this.terminal);
    addFlag(
      'im-feeling-lucky',
      help:
          'If true, prints the summary of the top article that the search returns.',
    );
    addFlag(
      'links-only',
      help: 'Prints search results without asking you to select an article.',
    );
  }

  final Logger logger;
  final Terminal terminal;
  late final ArticlePager pager;

  @override
  String get description => 'Search for Wikipedia articles.';

  @override
  bool get requiresArgument => true;

  @override
  String get name => 'search';

  @override
  String get valueHelp => 'STRING';

  @override
  String get help =>
      'Prints a list of links to Wikipedia articles that match the given term.';

  @override
  FutureOr<String> run(ArgResults args) async {
    if (args.commandArg == null || args.commandArg!.trim().isEmpty) {
      throw ArgumentException('Please include a search term', name);
    }

    final buffer = StringBuffer('Search results:\n');
    try {
      final SearchResults results = await search(args.commandArg!);
      if (results.results.isEmpty) {
        return 'No Wikipedia articles matched "${args.commandArg}".';
      }

      if (args.flag('im-feeling-lucky')) {
        final title = results.results.first.title;
        final Summary article = await getArticleSummaryByTitle(title);
        buffer.writeln('Lucky you!');
        buffer.writeln(
          terminal.supportsAnsi
              ? article.titles.normalized.titleText
              : article.titles.normalized,
        );
        if (article.description != null) {
          buffer.writeln(article.description);
        }
        buffer.writeln(article.extract);
        buffer.writeln();
        buffer.writeln('All results:');
      }

      for (var index = 0; index < results.results.length; index++) {
        final result = results.results[index];
        final title = terminal.supportsAnsi
            ? result.title.instructionText
            : result.title;
        buffer.writeln('${index + 1}. $title - ${result.url}');
      }

      if (args.flag('im-feeling-lucky') ||
          !terminal.isInteractive ||
          args.flag('links-only')) {
        return buffer.toString();
      }

      terminal.write(buffer.toString());
      final selectedIndex = _readSelection(results.results.length);
      if (selectedIndex == null) return 'Search closed.';

      final selected = results.results[selectedIndex];
      final articles = await getArticleByTitle(selected.title);
      if (articles.isEmpty) {
        return 'No readable article was found for "${selected.title}".';
      }
      final article = articles.first;
      pager.display(title: article.title, text: article.extract);
      return 'Finished reading ${article.title}.';
    } on HttpException catch (error) {
      logger
        ..warning(error.message)
        ..warning(error.uri)
        ..info(usage);
      return error.message;
    } on FormatException catch (error) {
      logger
        ..warning(error.message)
        ..warning(error.source)
        ..info(usage);
      return error.message;
    }
  }

  int? _readSelection(int resultCount) {
    while (true) {
      terminal.write(
        '\nSelect an article [1-$resultCount], or press Q to quit: ',
      );
      final input = terminal.readLine()?.trim().toLowerCase();
      if (input == null || input == 'q') return null;

      final selection = int.tryParse(input);
      if (selection != null && selection >= 1 && selection <= resultCount) {
        return selection - 1;
      }
      terminal.write('Please enter a number from 1 to $resultCount.\n');
    }
  }
}
