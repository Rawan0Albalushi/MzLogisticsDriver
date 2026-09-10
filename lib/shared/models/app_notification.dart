import '../../core/api/json_readers.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.readAt,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final String? readAt;
  final String? createdAt;

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = readMap(json['data']) ?? const {};
    return AppNotification(
      id: readString(json['id']) ?? '',
      title: readString(data['title']) ??
          readString(json['type'])?.split('\\').last ??
          '',
      body: readString(data['body']) ??
          readString(data['message']) ??
          readString(json['data']) ??
          '',
      readAt: readString(json['read_at']),
      createdAt: readString(json['created_at']),
    );
  }
}
