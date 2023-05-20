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

  Context() {
    if (Platform.environment.containsKey('GITHUB_EVENT_PATH')) {
      String eventPath = Platform.environment['GITHUB_EVENT_PATH']!;
      if (File(eventPath).existsSync()) {
        String eventJson = File(eventPath).readAsStringSync();
        payload = WebhookPayload.fromJson(jsonDecode(eventJson));
      } else {
        stdout.write('GITHUB_EVENT_PATH $eventPath does not exist\n');
      }
    }

    eventName = Platform.environment['GITHUB_EVENT_NAME']!;
    sha = Platform.environment['GITHUB_SHA']!;
    ref = Platform.environment['GITHUB_REF']!;
    workflow = Platform.environment['GITHUB_WORKFLOW']!;
    action = Platform.environment['GITHUB_ACTION']!;
    actor = Platform.environment['GITHUB_ACTOR']!;
    job = Platform.environment['GITHUB_JOB']!;
    runNumber = int.parse(Platform.environment['GITHUB_RUN_NUMBER']!);
    runId = int.parse(Platform.environment['GITHUB_RUN_ID']!);
    apiUrl = Platform.environment['GITHUB_API_URL'] ?? 'https://api.github.com';
    serverUrl =
        Platform.environment['GITHUB_SERVER_URL'] ?? 'https://github.com';
    graphqlUrl = Platform.environment['GITHUB_GRAPHQL_URL'] ??
        'https://api.github.com/graphql';
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
    if (Platform.environment.containsKey('GITHUB_REPOSITORY')) {
      final repoParts = Platform.environment['GITHUB_REPOSITORY']!.split('/');
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
