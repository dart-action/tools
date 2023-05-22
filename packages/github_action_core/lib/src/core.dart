import 'dart:io';

import 'command.dart';
import 'utils.dart';

class ExitCode {
  static const int success = 0;
  static const int failure = 1;
}

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
  exit(exitCode);
}

void debug(String message) {
  issueCommand('debug', {}, message);
}

void info(String message) {
  stdout.writeln(message);
}

void _msg(
  String command,
  dynamic message,
  AnnotationProperties? properties,
) {
  issueCommand(
    command,
    toCommandProperties(properties),
    message is Error ? message.toString() : message,
  );
}

void error(
  dynamic message, {
  AnnotationProperties? properties = const AnnotationProperties(),
}) {
  _msg(
    'error',
    message,
    properties,
  );
}

void warning(
  dynamic message, {
  AnnotationProperties? properties = const AnnotationProperties(),
}) {
  _msg(
    'warning',
    message,
    properties,
  );
}

void notice(
  dynamic message, {
  AnnotationProperties? properties = const AnnotationProperties(),
}) {
  _msg(
    'notice',
    message,
    properties,
  );
}

void startGroup(String name) {
  issue('group', message: name);
}

void groupEnd() {
  issue('endgroup');
}

Future<T> group<T>(String name, Future<T> Function() body) async {
  startGroup(name);

  T result;
  try {
    result = await body();
  } finally {
    groupEnd();
  }

  return result;
}

void saveState(String name, dynamic value) {
  final filePath = Platform.environment['GITHUB_STATE'] ?? '';
  if (filePath.isNotEmpty) {
    issueFileCommand('STATE', prepareKeyValueMessage(name, value));
    return;
  }

  issueCommand('save-state', {'name': name}, toCommandValue(value));
}

String getState(String name) {
  return Platform.environment['STATE_$name'] ?? '';
}

void setCommandEcho(bool enabled) {
  issue('echo', message: enabled ? 'on' : 'off');
}

bool isDebug() {
  return Platform.environment['RUNNER_DEBUG'] == '1';
}
