import 'dart:io';

import 'command.dart';
import 'utils.dart';

class AnnotationProperties {
  final String? title;
  final String? file;
  final int? startLine;
  final int? endLine;
  final int? startColumn;
  final int? endColumn;

  const AnnotationProperties({
    this.title,
    this.file,
    this.startLine,
    this.endLine,
    this.startColumn,
    this.endColumn,
  });
}

String? getInput(
  String key, {
  String? defaultValue,
  bool required = false,
  bool trimWhitespace = false,
}) {
  final name = key.replaceAll(' ', '_').toUpperCase();

  var value = Platform.environment['INPUT_$name'];

  if (value == null || value.isEmpty) {
    if (required) {
      if (defaultValue != null) {
        value = defaultValue;
      } else {
        throw StateError('The input $key is required but was not supplied.');
      }
    }
  }

  if (trimWhitespace) {
    value = value?.trim();
  }

  return value;
}

void exportVariable(String name, dynamic val) {
  final convertedVal = toCommandValue(val);
  Platform.environment[name] = convertedVal;

  final filePath = Platform.environment['GITHUB_ENV'] ?? '';
  if (filePath.isNotEmpty) {
    return issueFileCommand('ENV', prepareKeyValueMessage(name, val));
  }

  issueCommand('set-env', {'name': name}, convertedVal);
}

void setFailed(dynamic message) {
  exitCode = ExitCode.failure;

  error(message);
}

void error(dynamic message,
    {AnnotationProperties? properties = const AnnotationProperties()}) {
  issueCommand(
    'error',
    toCommandProperties(properties),
    message is Error ? message.toString() : message,
  );
}

class ExitCode {
  static const int success = 0;
  static const int failure = 1;
}
