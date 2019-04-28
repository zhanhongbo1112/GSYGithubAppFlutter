import 'package:yqboots/src/apps/github-client/index.dart';
import 'package:json_annotation/json_annotation.dart';

/**
 * Created by guoshuyu
 * Date: 2018-07-31
 */

part 'Notification.g.dart';

@JsonSerializable()
class GitHubNotification {
  String id;
  bool unread;
  String reason;
  @JsonKey(name: "updated_at")
  DateTime updateAt;
  @JsonKey(name: "last_read_at")
  DateTime lastReadAt;
  Repository repository;
  NotificationSubject subject;

  GitHubNotification(this.id, this.unread, this.reason, this.updateAt, this.lastReadAt, this.repository, this.subject);

  factory GitHubNotification.fromJson(Map<String, dynamic> json) => _$GitHubNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$GitHubNotificationToJson(this);
}
