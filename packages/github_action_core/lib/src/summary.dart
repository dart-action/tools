// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:io';

const EOL = '\n';

const SUMMARY_ENV_VAR = 'GITHUB_STEP_SUMMARY';
const SUMMARY_DOCS_URL =
    'https://docs.github.com/actions/using-workflows/workflow-commands-for-github-actions#adding-a-job-summary';

final Summary _summary = Summary();

final markdownSummary = _summary;
final summary = _summary;

class SummaryTableCell {
  String data;
  bool? header;
  String? colspan;
  String? rowspan;

  SummaryTableCell(this.data, {this.header, this.colspan, this.rowspan});
}

class SummaryImageOptions {
  String? width;
  String? height;

  SummaryImageOptions({this.width, this.height});
}

class SummaryWriteOptions {
  bool? overwrite;

  SummaryWriteOptions({this.overwrite});
}

class Summary {
  late StringBuffer _buffer;
  String? _filePath;

  Summary() {
    _buffer = StringBuffer();
  }

  Future<String> filePath() async {
    if (_filePath != null) {
      return _filePath!;
    }

    final pathFromEnv = Platform.environment[SUMMARY_ENV_VAR];
    if (pathFromEnv == null) {
      throw Exception(
          'Unable to find environment variable for \$$SUMMARY_ENV_VAR. Check if your runtime environment supports job summaries.');
    }

    try {
      await File(pathFromEnv).readAsBytes();
    } catch (_) {
      throw Exception(
          "Unable to access summary file: '$pathFromEnv'. Check if the file has correct read/write permissions.");
    }

    _filePath = pathFromEnv;
    return _filePath!;
  }

  String wrap(
    String tag,
    String? content, {
    Map<String, String> attrs = const {},
  }) {
    final htmlAttrs =
        attrs.entries.map((entry) => ' ${entry.key}="${entry.value}"').join('');

    if (content == null) {
      return '<$tag$htmlAttrs>';
    }

    return '<$tag$htmlAttrs>$content</$tag>';
  }

  Future<Summary> write([SummaryWriteOptions? options]) async {
    final overwrite = options?.overwrite ?? false;
    final filePath = await this.filePath();
    final file = File(filePath);

    if (overwrite) {
      await file.writeAsString(_buffer.toString());
    } else {
      await file.writeAsString(_buffer.toString(), mode: FileMode.append);
    }

    return emptyBuffer();
  }

  Future<Summary> clear() async {
    return emptyBuffer().write(SummaryWriteOptions(overwrite: true));
  }

  String stringify() {
    return _buffer.toString();
  }

  bool isEmptyBuffer() {
    return _buffer.isEmpty;
  }

  Summary emptyBuffer() {
    _buffer.clear();
    return this;
  }

  Summary addRaw(String text, {bool addEOL = false}) {
    _buffer.write(text);
    if (addEOL) {
      return this.addEOL();
    }
    return this;
  }

  Summary addEOL() {
    return addRaw(EOL);
  }

  Summary addCodeBlock(String code, [String? lang]) {
    final attrs = lang != null ? {'lang': lang} : <String, String>{};
    final element = wrap('pre', wrap('code', code), attrs: attrs);
    return addRaw(element).addEOL();
  }

  Summary addList(List<String> items, {bool ordered = false}) {
    final tag = ordered ? 'ol' : 'ul';
    final listItems = items.map((item) => wrap('li', item)).join('');
    final element = wrap(tag, listItems);
    return addRaw(element).addEOL();
  }

  Summary addTable(List<List<dynamic>> rows) {
    final tableBody = rows.map((row) {
      final cells = row.map((cell) {
        if (cell is String) {
          return wrap('td', cell);
        }
        final header = cell.header ?? false;
        final data = cell.data;
        final colspan = cell.colspan;
        final rowspan = cell.rowspan;
        final tag = header ? 'th' : 'td';
        final attrs = <String, String>{};

        if (colspan != null) {
          attrs['colspan'] = colspan;
        }

        if (rowspan != null) {
          attrs['rowspan'] = rowspan;
        }

        return wrap(tag, data, attrs: attrs);
      }).join('');

      return wrap('tr', cells);
    }).join('');

    final element = wrap('table', tableBody);
    return addRaw(element).addEOL();
  }

  Summary addDetails(String label, String content) {
    final element = wrap('details', wrap('summary', label) + content);
    return addRaw(element).addEOL();
  }

  Summary addImage(String src, String alt, [SummaryImageOptions? options]) {
    final width = options?.width;
    final height = options?.height;
    final attrs = <String, String>{};

    if (width != null) {
      attrs['width'] = width;
    }

    if (height != null) {
      attrs['height'] = height;
    }

    final element =
        wrap('img', null, attrs: {'src': src, 'alt': alt, ...attrs});
    return addRaw(element).addEOL();
  }

  Summary addHeading(String text, [dynamic level = 1]) {
    final tag = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'].contains('h$level')
        ? 'h$level'
        : 'h1';
    final element = wrap(tag, text);
    return addRaw(element).addEOL();
  }

  Summary addSeparator() {
    final element = wrap('hr', null);
    return addRaw(element).addEOL();
  }

  Summary addBreak() {
    final element = wrap('br', null);
    return addRaw(element).addEOL();
  }

  Summary addQuote(String text, [String? cite]) {
    final attrs = cite != null ? {'cite': cite} : <String, String>{};
    final element = wrap('blockquote', text, attrs: attrs);
    return addRaw(element).addEOL();
  }

  Summary addLink(String text, String href) {
    final element = wrap('a', text, attrs: {'href': href});
    return addRaw(element).addEOL();
  }
}
