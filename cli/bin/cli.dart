import 'package:command_runner/command_runner.dart';

const version = '0.0.1';

Future<void> main(List<String> arguments) async {
  final commandRunner = CommandRunner()..addCommand(HelpCommand());
  await commandRunner.run(arguments);
}

/*
void searchWikipedia(List<String>? arguments) async {
  final String articleTitle;

  if (arguments== null || arguments.isEmpty) {
    print('Please provide an article title: ');
    final inputFromStdin = stdin.readLineSync();
    if (inputFromStdin == null || inputFromStdin.isEmpty) {
      print("No article title provided. Exiting...");
      return;
    }
  articleTitle = inputFromStdin;

  }
  else {
    articleTitle = arguments.join(' ');

  }
  print('Looking up articles about "$articleTitle". Please wait.');
  // Call the API and wait for the result.
  var articleContent = await getWikipediaArticle(articleTitle);
  print(articleContent);
}

void printUsage() {
  print (
    "The following commands are valid: 'help', 'search <ARTICLE-TITLE>' "
  );
}


Future<String> getWikipediaArticle(String articleTitle) async {
  final url = Uri.https(
    'en.wikipedia.org', // Wikipedia API domain
    '/api/rest_v1/page/summary/$articleTitle', // API path for article summary
  );
  final response = await http.get(url); // make the http request

  if (response.statusCode == 200) {
    return response.body;
  }
  
  return 'Error: Failed to fetch article "$articleTitle". Status code: ${response.statusCode}';
  
  }
*/
