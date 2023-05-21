import 'dart:collection';
import 'dart:convert';

/// Represents a base item with map-like behavior.
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

  /// Converts the inner map to a JSON string.
  String toJson() {
    return json.encode(innerMap);
  }

  @override
  String toString() {
    return toJson();
  }
}

/// Represents the payload repository information.
class PayloadRepository extends _BaseItem {
  /// The full name of the repository.
  String? fullName;

  /// The name of the repository.
  String name;

  /// The owner of the repository.
  Owner owner;

  /// The URL of the repository.
  String? htmlUrl;

  /// Constructs a new instance of the PayloadRepository class.
  PayloadRepository(
    super.innerMap, {
    this.fullName,
    required this.name,
    required this.owner,
    this.htmlUrl,
  });

  /// Creates a PayloadRepository instance from a JSON map.
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

/// Represents the owner information.
class Owner extends _BaseItem {
  /// The login name of the owner.
  String login;

  /// The name of the owner.
  String? name;

  /// Constructs a new instance of the Owner class.
  Owner(
    super.innerMap, {
    required this.login,
    this.name,
  });

  /// Creates an Owner instance from a JSON map.
  factory Owner.fromJson(Map json) {
    return Owner(
      json,
      login: json['login'],
      name: json['name'],
    );
  }
}

/// Represents an issue.

class Issue extends _BaseItem {
  /// The issue number.
  int? number;

  /// The URL of the issue.
  String? htmlUrl;

  /// The body of the issue.
  String? body;

  /// Constructs a new instance of the Issue class.
  Issue(
    super.innerMap, {
    this.number,
    this.htmlUrl,
    this.body,
  });

  /// Creates an Issue instance from a JSON map.
  static Issue? fromJson(Map? json) {
    if (json == null) {
      return null;
    }
    return Issue(
      json,
      number: json['number'],
      htmlUrl: json['html_url'],
      body: json['body'],
    );
  }
}

/// Represents the sender information.

class Sender extends _BaseItem {
  /// The type of the sender.
  String? type;

  /// Constructs a new instance of the Sender class.
  Sender(
    super.innerMap, {
    this.type,
  });

  /// Creates a Sender instance from a JSON map.
  static Sender? fromJson(Map? json) {
    if (json == null) {
      return null;
    }
    return Sender(
      json,
      type: json['type'],
    );
  }
}

/// Represents an item with an ID.

class _IdItem extends _BaseItem {
  /// The ID of the item.
  int? id;

  _IdItem(
    super.innerMap, {
    this.id,
  });
}

/// Represents an installation.

class Installation extends _IdItem {
  Installation(
    super.innerMap, {
    super.id,
  });

  /// Creates an Installation instance from a JSON map.
  static Installation? fromJson(Map? json) {
    if (json == null) {
      return null;
    }
    return Installation(
      json,
      id: json['id'],
    );
  }
}

/// Represents a comment.

class Comment extends _IdItem {
  Comment(
    super.innerMap, {
    super.id,
  });

  /// Creates a Comment instance from a JSON map.
  static Comment? fromJson(Map? json) {
    if (json == null) {
      return null;
    }
    return Comment(
      json,
      id: json['id'],
    );
  }
}

/// Represents the webhook payload.

class WebhookPayload extends _BaseItem {
  /// The payload repository information.
  PayloadRepository? repository;

  /// The issue information.
  Issue? issue;

  /// The pull request information.
  Issue? pullRequest;

  /// The sender information.
  Sender? sender;

  /// The action name.
  String? action;

  /// The installation information.
  Installation? installation;

  /// The comment information.
  Comment? comment;

  /// Constructs a new instance of the WebhookPayload class.
  WebhookPayload(
    super.innerMap, {
    this.repository,
    this.issue,
    this.pullRequest,
    this.sender,
    this.action,
    this.installation,
    this.comment,
  });

  /// Creates a WebhookPayload instance from a JSON map.
  static WebhookPayload fromJson(Map json) {
    return WebhookPayload(
      json,
      repository: PayloadRepository.fromJson(json['repository']),
      issue: Issue.fromJson(json['issue']),
      pullRequest: Issue.fromJson(json['pull_request']),
      sender: Sender.fromJson(json['sender']),
      action: json['action'],
      installation: Installation.fromJson(json['installation']),
      comment: Comment.fromJson(json['comment']),
    );
  }
}
