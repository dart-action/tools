import 'dart:convert';
import 'dart:io';

import 'interface.dart';

final context = Context();

class Context {
  late WebhookPayload payload;

  late String eventName;
  late String sha;
  late String ref;
  late String workflow;
  late String action;
  late String actor;
  late String job;
  late int runNumber;
  late int runId;
  late String apiUrl;
  late String serverUrl;
  late String graphqlUrl;

  Map<String, String> get env => Platform.environment;

  Context() {
    if (env.containsKey('GITHUB_EVENT_PATH')) {
      String eventPath = env['GITHUB_EVENT_PATH']!;
      if (File(eventPath).existsSync()) {
        String eventJson = File(eventPath).readAsStringSync();
        payload = WebhookPayload.fromJson(jsonDecode(eventJson));
      } else {
        stdout.write('GITHUB_EVENT_PATH $eventPath does not exist\n');
      }
    }

    eventName = env['GITHUB_EVENT_NAME']!;
    sha = env['GITHUB_SHA']!;
    ref = env['GITHUB_REF']!;
    workflow = env['GITHUB_WORKFLOW']!;
    action = env['GITHUB_ACTION']!;
    actor = env['GITHUB_ACTOR']!;
    job = env['GITHUB_JOB']!;
    runNumber = env.intValue('GITHUB_RUN_NUMBER', 10);
    runId = env.intValue('GITHUB_RUN_ID', 10);
    apiUrl = env.stringValue('GITHUB_API_URL', 'https://api.github.com');
    serverUrl = env.stringValue('GITHUB_SERVER_URL', 'https://github.com');
    graphqlUrl =
        env.stringValue('GITHUB_GRAPHQL_URL', 'https://api.github.com/graphql');
  }

  IssueInfo get issue {
    final payload = this.payload;

    int n;

    if (payload.issue != null) {
      n = payload.issue!['number'];
    } else if (payload.pullRequest != null) {
      n = payload.pullRequest!['number'];
    } else {
      n = payload['number'];
    }

    return IssueInfo(
      owner: repo.owner,
      repo: repo.repo,
      number: n,
    );
  }

  RepoInfo get repo {
    if (env.containsKey('GITHUB_REPOSITORY')) {
      final repoParts = env['GITHUB_REPOSITORY']!.split('/');
      return RepoInfo(owner: repoParts[0], repo: repoParts[1]);
    }

    if (payload.repository != null) {
      return RepoInfo(
        owner: payload.repository!['owner']['login']!,
        repo: payload.repository!['name']!,
      );
    }

    throw Exception(
        "context.repo requires a GITHUB_REPOSITORY environment variable like 'owner/repo'");
  }
}

class IssueInfo {
  final String owner;
  final String repo;
  final int? number;

  IssueInfo({
    required this.owner,
    required this.repo,
    this.number,
  });
}

class RepoInfo {
  final String owner;
  final String repo;

  RepoInfo({
    required this.owner,
    required this.repo,
  });
}

extension _PlatformExt on Map<String, String> {
  String stringValue(String key, [String? defaultValue]) {
    final result = this[key] ?? defaultValue;
    if (result == null) {
      throw Exception('Missing required environment variable $key');
    }
    return result;
  }

  int intValue(String key, [int? defaultValue]) {
    try {
      return int.parse(this[key]!);
    } catch (e) {
      if (defaultValue == null) {
        throw Exception(
            'Environment variable $key cannot be parsed to int, and no default value was provided.');
      }
      return defaultValue;
    }
  }
}
