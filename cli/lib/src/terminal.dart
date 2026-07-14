import 'dart:io';

import 'package:command_runner/command_runner.dart';

abstract interface class Terminal {
  bool get isInteractive;
  bool get supportsAnsi;
  int get width;

  void write(String text);
  String? readLine();
  String readNavigationKey();
  void clear();
}

class SystemTerminal implements Terminal {
  @override
  bool get isInteractive => stdin.hasTerminal && stdout.hasTerminal;

  @override
  bool get supportsAnsi => stdout.supportsAnsiEscapes;

  @override
  int get width {
    if (!stdout.hasTerminal) return 80;
    return stdout.terminalColumns.clamp(40, 160);
  }

  @override
  void write(String text) => stdout.write(text);

  @override
  String? readLine() => stdin.readLineSync();

  @override
  void clear() {
    if (supportsAnsi) {
      stdout.write('\x1B[2J\x1B[H');
    } else {
      stdout.writeln('\n${'-' * width}\n');
    }
  }

  @override
  String readNavigationKey() {
    if (!isInteractive) return 'q';

    final previousLineMode = stdin.lineMode;
    final previousEchoMode = stdin.echoMode;
    String? key;
    var rawModeFailed = false;
    try {
      // Windows requires echo mode to be disabled before line mode.
      stdin
        ..echoMode = false
        ..lineMode = false;

      while (true) {
        final first = stdin.readByteSync();
        if (first == -1 || first == 3) {
          key = 'q';
          break;
        }

        final character = String.fromCharCode(first).toLowerCase();
        if (character == 'n' || character == 'p' || character == 'q') {
          key = character;
          break;
        }

        // Windows arrow keys are prefixed by 0 or 224.
        if (first == 0 || first == 224) {
          final second = stdin.readByteSync();
          if (second == 77) {
            key = 'n';
            break;
          }
          if (second == 75) {
            key = 'p';
            break;
          }
        }

        // ANSI terminals encode arrow keys as ESC [ C/D.
        if (first == 27) {
          final second = stdin.readByteSync();
          final third = stdin.readByteSync();
          if (second == 91 && third == 67) {
            key = 'n';
            break;
          }
          if (second == 91 && third == 68) {
            key = 'p';
            break;
          }
        }
      }
    } on StdinException {
      rawModeFailed = true;
    } finally {
      // Restore line mode before echo mode; Windows requires line mode to be
      // enabled before echo can be enabled again.
      try {
        stdin.lineMode = previousLineMode;
      } on StdinException {
        // The parent terminal may control this mode and reject changes.
      }
      try {
        stdin.echoMode = previousEchoMode;
      } on StdinException {
        // The parent terminal may control this mode and reject changes.
      }
    }

    if (!rawModeFailed) return key ?? 'q';

    write(
      '\nThis terminal does not support single-key navigation. '
      'Type N, P, or Q and press Enter: ',
    );
    while (true) {
      final input = readLine()?.trim().toLowerCase();
      if (input == null || input == 'q' || input == 'quit') return 'q';
      if (input == 'n' || input == 'next') return 'n';
      if (input == 'p' || input == 'previous') return 'p';
      write('Please type N, P, or Q and press Enter: ');
    }
  }
}

class ArticlePager {
  ArticlePager(this.terminal, {this.wordsPerPage = 500});

  final Terminal terminal;
  final int wordsPerPage;

  List<String> paginate(String text) {
    if (text.trim().isEmpty) return const <String>[];

    final words = RegExp(r'\S+').allMatches(text).toList();
    final pages = <String>[];
    var pageStart = 0;

    for (var index = 0; index < words.length; index += wordsPerPage) {
      final lastWordIndex = (index + wordsPerPage - 1).clamp(
        0,
        words.length - 1,
      );
      final pageEnd = words[lastWordIndex].end;
      pages.add(text.substring(pageStart, pageEnd).trim());
      pageStart = pageEnd;
    }

    return pages;
  }

  void display({required String title, required String text}) {
    final pages = paginate(text);
    if (pages.isEmpty) {
      terminal.write('This article has no readable text.\n');
      return;
    }

    var pageIndex = 0;
    while (true) {
      terminal.clear();
      terminal.write(
        _renderPage(title, pages[pageIndex], pageIndex, pages.length),
      );

      if (pages.length == 1) return;

      final key = terminal.readNavigationKey();
      if (key == 'q') return;
      if (key == 'n' && pageIndex < pages.length - 1) pageIndex++;
      if (key == 'p' && pageIndex > 0) pageIndex--;
    }
  }

  String _renderPage(String title, String page, int pageIndex, int pageCount) {
    final buffer = StringBuffer();
    final renderedTitle = terminal.supportsAnsi ? title.titleText : title;
    buffer
      ..writeln(renderedTitle)
      ..writeln('=' * title.length.clamp(3, terminal.width))
      ..writeln()
      ..write(_formatArticleText(page))
      ..writeln()
      ..writeln();

    final controls =
        'Page ${pageIndex + 1}/$pageCount  '
        '[N/Right] Next  [P/Left] Previous  [Q] Quit';
    buffer.writeln(
      terminal.supportsAnsi
          ? ConsoleColor.grey.applyForeground(controls)
          : controls,
    );
    return buffer.toString();
  }

  String _formatArticleText(String text) {
    final buffer = StringBuffer();
    for (final rawLine in text.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) {
        buffer.writeln();
        continue;
      }

      final heading = RegExp(r'^=+\s*(.*?)\s*=+$').firstMatch(line);
      if (heading != null) {
        final headingText = heading.group(1)!;
        buffer
          ..writeln()
          ..writeln(
            terminal.supportsAnsi ? headingText.instructionText : headingText,
          )
          ..writeln('-' * headingText.length.clamp(3, terminal.width));
        continue;
      }

      for (final wrappedLine in wrapText(line, terminal.width)) {
        buffer.writeln(wrappedLine);
      }
    }
    return buffer.toString().trimRight();
  }

  static List<String> wrapText(String text, int width) {
    final effectiveWidth = width.clamp(20, 160);
    final words = text.trim().split(RegExp(r'\s+'));
    final lines = <String>[];
    var current = StringBuffer();

    for (final word in words) {
      if (current.isEmpty) {
        current.write(word);
      } else if (current.length + word.length + 1 <= effectiveWidth) {
        current.write(' $word');
      } else {
        lines.add(current.toString());
        current = StringBuffer(word);
      }
    }
    if (current.isNotEmpty) lines.add(current.toString());
    return lines;
  }
}
