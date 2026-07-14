import 'dart:async';
import 'dart:io';

import 'package:command_runner/command_runner.dart';
import 'package:logging/logging.dart';
import 'package:wikipedia/wikipedia.dart';

import '../terminal.dart';

class GetArticleCommand extends Command {
  GetArticleCommand({required this.logger, Terminal? terminal})
    : terminal = terminal ?? SystemTerminal() {
    pager = ArticlePager(this.terminal);
    addFlag(
      'no-pager',
      help: 'Prints the complete article without interactive page navigation.',
    );
  }

  final Logger logger;
  final Terminal terminal;
  late final ArticlePager pager;

  @override
  String get description => 'Read an article from Wikipedia.';

  @override
  String get name => 'article';

  @override
  String get help => 'Gets an article by exact canonical Wikipedia title.';

  @override
  String get defaultValue => 'cat';

  @override
  String get valueHelp => 'STRING';

  @override
  FutureOr<String> run(ArgResults args) async {
    try {
      final title = args.commandArg ?? defaultValue;
      final List<Article> articles = await getArticleByTitle(title);
      if (articles.isEmpty) {
        return 'No Wikipedia article was found for "$title".';
      }

      final article = articles.first;
      if (terminal.isInteractive && !args.flag('no-pager')) {
        pager.display(title: article.title, text: article.extract);
        return 'Finished reading ${article.title}.';
      }

      final renderedTitle = terminal.supportsAnsi
          ? article.title.titleText
          : article.title;
      final buffer = StringBuffer('\n=== $renderedTitle ===\n\n');
      buffer.write(article.extract);
      return buffer.toString();
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
}
