import 'dart:collection';
import 'dart:convert';

class _BaseItem with MapMixin<dynamic, dynamic> {
  final Map innerMap;

  _BaseItem(this.innerMap);

  @override
  operator [](Object? key) {
    return innerMap[key];
  }

  @override
  void operator []=(key, value) {
    innerMap[key] = value;
  }

  @override
  void clear() {
    innerMap.clear();
  }

  @override
  Iterable get keys => innerMap.keys;

  @override
  remove(Object? key) {
    return innerMap.remove(key);
  }
}

class PayloadRepository extends _BaseItem {
  String? fullName;
  String name;
  Owner owner;
  String? htmlUrl;

  PayloadRepository(
    super.innerMap, {
    this.fullName,
    required this.name,
    required this.owner,
    this.htmlUrl,
  });

  static PayloadRepository? fromJson(Map? json) {
    if (json == null) {
      return null;
    }
    return PayloadRepository(
      json,
      fullName: json['full_name'],
      name: json['name'],
      owner: Owner.fromJson(json['owner']),
      htmlUrl: json['html_url'],
    );
  }

}

class Owner extends _BaseItem {
  String login;
  String? name;

  Owner(
    super.innerMap, {
    required this.login,
    this.name,
  });

  factory Owner.fromJson(Map json) {
    return Owner(
      json,
      login: json['login'],
      name: json['name'],
    );
  }
}

class WebhookPayload extends _BaseItem {
  PayloadRepository? repository;
  Map<String, dynamic>? issue;
  Map<String, dynamic>? pullRequest;
  Map<String, dynamic>? sender;
  String? action;
  Map<String, dynamic>? installation;
  Map<String, dynamic>? comment;

  WebhookPayload(
    super.innerMap, {
    required this.repository,
    this.issue,
    this.pullRequest,
    this.sender,
    this.action,
    this.installation,
    this.comment,
  });

  factory WebhookPayload.fromJson(Map json) {
    return WebhookPayload(
      json,
      repository: PayloadRepository.fromJson(json['repository']),
      issue: json['issue'],
      pullRequest: json['pull_request'],
      sender: json['sender'],
      action: json['action'],
      installation: json['installation'],
      comment: json['comment'],
    );
  }


  factory WebhookPayload.fromString(String text) {
    final json = jsonDecode(text);
    return WebhookPayload.fromJson(json);
  }
}
