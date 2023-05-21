import 'dart:convert';
import 'dart:io';

import 'interface.dart';

final context = Context();

class Context {
  late WebhookPayload payload;

  /// The name of the event that triggered the workflow.
  late String eventName;

  /// The commit SHA that triggered the workflow.
  late String sha;

  /// The ref that triggered the workflow.
  late String ref;

  /// The workflow name.
  late String workflow;

  /// The action name.
  late String action;

  /// The username of the user or app that initiated the workflow.
  late String actor;

  /// The job name.
  late String job;

  /// The run number of the workflow.
  late int runNumber;

  /// The run ID of the workflow.
  late int runId;

  /// The URL of the GitHub API.
  late String apiUrl;

  /// The URL of the GitHub server.
  late String serverUrl;

  /// The URL of the GitHub GraphQL API.
  late String graphqlUrl;

  /// Retrieves the environment variables.
  Map<String, String> get env => Platform.environment;

  /// Constructs a new instance of the Context class.
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

  /// Gets the information about the issue.
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

  /// Gets the information about the repository.
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

/// A class representing information about an issue.
class IssueInfo {
  /// The owner of the repository.
  final String owner;

  /// The repository name
  final String repo;

  /// The issue number.
  final int? number;

  /// Constructs a new instance of the IssueInfo class.
  IssueInfo({
    required this.owner,
    required this.repo,
    this.number,
  });
}

/// A class representing information about a repository.
class RepoInfo {
  /// The owner of the repository.
  final String owner;

  /// The repository name.
  final String repo;

  /// Constructs a new instance of the RepoInfo class.
  RepoInfo({
    required this.owner,
    required this.repo,
  });
}

/// Extension methods for the Map<String, String> class.
extension _PlatformExt on Map<String, String> {
  /// Retrieves the value associated with the given key as a string.
  ///
  /// If the key is not found, [defaultValue] is returned.
  /// If [defaultValue] is not provided and the key is not found, an exception is thrown.
  String stringValue(String key, [String? defaultValue]) {
    final result = this[key] ?? defaultValue;
    if (result == null) {
      throw Exception('Missing required environment variable $key');
    }
    return result;
  }

  /// Retrieves the value associated with the given key as an integer.
  ///
  /// If the key is not found or the value cannot be parsed as an integer,
  /// [defaultValue] is returned (if provided).
  /// If [defaultValue] is not provided and the value cannot be parsed as an integer,
  /// an exception is thrown.
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
