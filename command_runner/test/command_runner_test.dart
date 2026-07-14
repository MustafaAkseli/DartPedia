import 'dart:async';

import 'package:command_runner/command_runner.dart';
import 'package:test/test.dart';

void main() {
  test('combines unquoted positional words into one command argument', () {
    final runner = CommandRunner()..addCommand(_SearchCommand());

    final results = runner.parse(['search', 'chainsaw', 'man', 'the', 'movie']);

    expect(results.commandArg, 'chainsaw man the movie');
  });

  test('uses a configured executable name in usage', () {
    final runner = CommandRunner(executableName: 'dartpedia');

    expect(runner.usage, startsWith('Usage: dartpedia '));
  });
}

class _SearchCommand extends Command {
  @override
  String get name => 'search';

  @override
  String get description => 'Test search command.';

  @override
  FutureOr<Object?> run(ArgResults args) => null;
}
