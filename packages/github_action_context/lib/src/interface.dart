import 'dart:convert';

class PayloadRepository {
  String? fullName;
  String name;
  Owner owner;
  String? htmlUrl;

  PayloadRepository({
    this.fullName,
    required this.name,
    required this.owner,
    this.htmlUrl,
  });

  factory PayloadRepository.fromJson(Map json) {
    return PayloadRepository(
      fullName: json['full_name'],
      name: json['name'],
      owner: Owner.fromJson(json['owner']),
      htmlUrl: json['html_url'],
    );
  }

  factory PayloadRepository.fromString(String text) {
    final json = jsonDecode(text);
    return PayloadRepository.fromJson(json);
  }
}

class Owner {
  String login;
  String? name;

  Owner({
    required this.login,
    this.name,
  });

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      login: json['login'],
      name: json['name'],
    );
  }
}

class WebhookPayload {
  Map<String, dynamic> repository;
  Map<String, dynamic>? issue;
  Map<String, dynamic>? pullRequest;
  Map<String, dynamic>? sender;
  String? action;
  Map<String, dynamic>? installation;
  Map<String, dynamic>? comment;

  WebhookPayload({
    required this.repository,
    this.issue,
    this.pullRequest,
    this.sender,
    this.action,
    this.installation,
    this.comment,
  });

  factory WebhookPayload.fromJson(Map<String, dynamic> json) {
    return WebhookPayload(
      repository: json['repository'],
      issue: json['issue'],
      pullRequest: json['pull_request'],
      sender: json['sender'],
      action: json['action'],
      installation: json['installation'],
      comment: json['comment'],
    );
  }
}
