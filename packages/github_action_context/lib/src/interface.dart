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

  String toJson() {
    return json.encode(innerMap);
  }

  @override
  String toString() {
    return toJson();
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

// export interface WebhookPayload {
//   [key: string]: any
//   repository?: PayloadRepository
//   issue?: {
//     [key: string]: any
//     number: number
//     html_url?: string
//     body?: string
//   }
//   pull_request?: {
//     [key: string]: any
//     number: number
//     html_url?: string
//     body?: string
//   }
//   sender?: {
//     [key: string]: any
//     type: string
//   }
//   action?: string
//   installation?: {
//     id: number
//     [key: string]: any
//   }
//   comment?: {
//     id: number
//     [key: string]: any
//   }
// }

class Issue extends _BaseItem {
  int? number;
  String? htmlUrl;
  String? body;

  Issue(
    super.innerMap, {
    this.number,
    this.htmlUrl,
    this.body,
  });

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

class Sender extends _BaseItem {
  String? type;

  Sender(
    super.innerMap, {
    this.type,
  });

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

class _IdItem extends _BaseItem {
  int? id;

  _IdItem(
    super.innerMap, {
    this.id,
  });
}

class Installation extends _IdItem {
  Installation(
    super.innerMap, {
    super.id,
  });

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

class Comment extends _IdItem {
  Comment(
    super.innerMap, {
    super.id,
  });

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

class WebhookPayload extends _BaseItem {
  PayloadRepository? repository;
  Issue? issue;
  Issue? pullRequest;
  Sender? sender;
  String? action;
  Installation? installation;
  Comment? comment;

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
