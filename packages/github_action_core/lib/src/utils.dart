import 'dart:convert';

import 'core.dart';

String toCommandValue(dynamic input) {
  if (input == null) {
    return '';
  } else if (input is String) {
    return input;
  }
  return jsonEncode(input);
}

Map<String, dynamic> toCommandProperties(
    AnnotationProperties? annotationProperties) {
  if (annotationProperties == null) {
    return {};
  }

  return {
    'title': annotationProperties.title,
    'file': annotationProperties.file,
    'line': annotationProperties.startLine,
    'endLine': annotationProperties.endLine,
    'col': annotationProperties.startColumn,
    'endColumn': annotationProperties.endColumn,
  };
}
