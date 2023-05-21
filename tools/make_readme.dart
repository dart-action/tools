import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final result = await getList();

  final table = makeTable(result).trim();

  final prefix = '''
# tools

The package is help user to use `dart` code to develop github action.

## Packages
''';
  final content = '''
$prefix
$table
'''
          .trim() +
      '\n';

  final file = File('README.md');
  await file.writeAsString(content);
}

Future<List<Package>> getList() async {
  final cmd = 'melos list --json -r';

  final result = await Process.run('melos', ['list', '--json', '-r']);
  if (result.exitCode != 0) {
    throw Exception('Failed to run $cmd');
  }

  final json = result.stdout;
  final packages = jsonDecode(json) as List<dynamic>;
  return packages.map((e) => Package.fromJson(e)).toList();
}

// [
//   {
//     "name": "github_action_context",
//     "version": "0.1.2",
//     "private": false,
//     "location": "packages/github_action_context",
//     "type": 0
//   },
//   {
//     "name": "github_action_core",
//     "version": "0.1.1",
//     "private": false,
//     "location": "packages/github_action_core",
//     "type": 0
//   }
// ]

class Package {
  final String name;
  final String version;
  final bool private;
  final String location;
  final int type;

  Package({
    required this.name,
    required this.version,
    required this.private,
    required this.location,
    required this.type,
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      name: json['name'],
      version: json['version'],
      private: json['private'],
      location: json['location'],
      type: json['type'],
    );
  }
}

String makeTable(List<Package> result) {
  final baseUrl = 'https://github.com/dart-action/tools/tree/main';

  final tableContent = result.map((e) {
    final name = e.name;
    final version = e.version;
    final location = '[${e.location}]($baseUrl/${e.location})';
    final pub = e.private ? '' : '[pub](https://pub.dev/packages/$name)';
    final docs = e.private ? '' : '[doc](https://pub.dev/documentation/$name)';
    return '| $name | $version | $location | $pub | $docs |';
  }).join('\n');

  return '''
| Package | Version | Location | Pub | docs |
| ------- | ------- | -------- | --- | ---  |
$tableContent
''';
}
