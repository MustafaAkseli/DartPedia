import 'package:cli/cli.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  final logger = Logger('test');

  test('exports the Wikipedia search command', () {
    final command = SearchCommand(logger: logger);

    expect(command.name, 'search');
    expect(command.requiresArgument, isTrue);
    expect(
      command.options.any((option) => option.name == 'links-only'),
      isTrue,
    );
  });

  test('exports the Wikipedia article command', () {
    final command = GetArticleCommand(logger: logger);

    expect(command.name, 'article');
    expect(command.defaultValue, 'cat');
    expect(command.options.any((option) => option.name == 'no-pager'), isTrue);
  });

  test('article pager splits content into 500-word pages', () {
    final terminal = _FakeTerminal();
    final pager = ArticlePager(terminal);
    final article = List.generate(1001, (index) => 'word$index').join(' ');

    final pages = pager.paginate(article);

    expect(pages, hasLength(3));
    expect(_wordCount(pages[0]), 500);
    expect(_wordCount(pages[1]), 500);
    expect(_wordCount(pages[2]), 1);
  });

  test('article pager supports next, previous, and quit navigation', () {
    final terminal = _FakeTerminal(navigationKeys: ['n', 'p', 'n', 'q']);
    final pager = ArticlePager(terminal, wordsPerPage: 2);

    pager.display(title: 'Example', text: 'one two three four');

    expect(terminal.output, contains('Page 1/2'));
    expect(terminal.output, contains('Page 2/2'));
    expect(terminal.clearCount, 4);
  });

  test('article text wrapping respects the terminal width', () {
    final lines = ArticlePager.wrapText(
      'one two three four five six seven eight',
      20,
    );

    expect(lines.every((line) => line.length <= 20), isTrue);
  });
}

int _wordCount(String text) => RegExp(r'\S+').allMatches(text).length;

class _FakeTerminal implements Terminal {
  _FakeTerminal({List<String>? navigationKeys})
    : _navigationKeys = navigationKeys ?? <String>[];

  final List<String> _navigationKeys;
  final StringBuffer _output = StringBuffer();
  int clearCount = 0;

  String get output => _output.toString();

  @override
  bool get isInteractive => true;

  @override
  bool get supportsAnsi => false;

  @override
  int get width => 40;

  @override
  void clear() => clearCount++;

  @override
  String? readLine() => null;

  @override
  String readNavigationKey() => _navigationKeys.removeAt(0);

  @override
  void write(String text) => _output.write(text);
}
