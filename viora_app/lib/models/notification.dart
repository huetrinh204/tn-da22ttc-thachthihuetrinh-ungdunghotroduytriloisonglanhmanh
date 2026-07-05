class CommunityNotification {
  final String id;
  final String type; // 'like', 'comment', 'follow', 'warning'
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? postId;
  final String? commentId;
  final String? content;
  final String? title; // For admin warnings
  final String? body; // For admin warnings
  final String? emoji; // For admin warnings
  final bool isRead;
  final DateTime createdAt;

  CommunityNotification({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.postId,
    this.commentId,
    this.content,
    this.title,
    this.body,
    this.emoji,
    required this.isRead,
    required this.createdAt,
  });

  factory CommunityNotification.fromJson(Map<String, dynamic> json) {
    return CommunityNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'like',
      userId: (json['actor_id'] ?? json['user_id'])?.toString() ?? '',
      userName: (json['actor_name'] ?? json['user_name']) as String? ?? 'Unknown',
      userAvatar: (json['actor_avatar'] ?? json['user_avatar']) as String?,
      postId: json['post_id']?.toString(),
      commentId: json['comment_id']?.toString(),
      content: json['comment_content'] ?? json['post_content'] ?? json['content'] ?? json['body'],
      title: json['title'] as String?,
      body: json['body'] as String?,
      emoji: json['emoji'] as String?,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(
              (json['created_at'] as String).contains('Z') || (json['created_at'] as String).contains('+')
                  ? json['created_at'] as String
                  : '${json['created_at']}Z'
            ).toLocal()
          : DateTime.now(),
    );
  }
}