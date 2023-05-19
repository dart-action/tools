import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

import 'utils.dart';

void issueCommand(
    String command, Map<String, dynamic> properties, dynamic message) {
  final cmd = Command(command, properties, message);
  stdout.write('${cmd.toString()}${Platform.operatingSystem}');
}

void issue(String name, {String message = ''}) {
  issueCommand(name, {}, message);
}

const _cmdString = '::';

class Command {
  String command;
  final Map<String, dynamic> properties;
  final String message;

  Command(this.command, this.properties, this.message) {
    if (command.isEmpty) {
      command = 'missing.command';
    }
  }

  @override
  String toString() {
    var cmdStr = _cmdString + command;

    if (properties.isNotEmpty) {
      cmdStr += ' ';
      var first = true;
      for (var entry in properties.entries) {
        final key = entry.key;
        final val = entry.value;
        if (val != null) {
          if (first) {
            first = false;
          } else {
            cmdStr += ',';
          }

          cmdStr += '$key=${escapeProperty(val)}';
        }
      }
    }

    cmdStr += '$_cmdString${escapeData(message)}';
    return cmdStr;
  }
}

String escapeData(dynamic s) {
  return toCommandValue(s)
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A');
}

String escapeProperty(dynamic s) {
  return toCommandValue(s)
      .replaceAll('%', '%25')
      .replaceAll('\r', '%0D')
      .replaceAll('\n', '%0A')
      .replaceAll(':', '%3A')
      .replaceAll(',', '%2C');
}

void issueFileCommand(String command, dynamic message) {
  final filePath = Platform.environment['GITHUB_$command'];
  if (filePath == null) {
    throw Exception(
        'Unable to find environment variable for file command $command');
  }
  if (!File(filePath).existsSync()) {
    throw Exception('Missing file at path: $filePath');
  }

  final file = File(filePath);
  file.writeAsStringSync('${toCommandValue(message)}\n',
      mode: FileMode.append, encoding: utf8);
}

String prepareKeyValueMessage(String key, dynamic value) {
  final delimiter = 'ghadelimiter_${Uuid().v4()}';
  final convertedValue = toCommandValue(value);

  if (key.contains(delimiter)) {
    throw Exception(
        'Unexpected input: name should not contain the delimiter "$delimiter"');
  }

  if (convertedValue.contains(delimiter)) {
    throw Exception(
        'Unexpected input: value should not contain the delimiter "$delimiter"');
  }

  return '$key<<$delimiter\n$convertedValue\n$delimiter';
}
