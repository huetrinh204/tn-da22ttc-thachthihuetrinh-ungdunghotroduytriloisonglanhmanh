class CommunityNotification {
  final String id;
  final String type; // 'like', 'comment', 'follow'
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? postId;
  final String? commentId;
  final String? content;
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
    required this.isRead,
    required this.createdAt,
  });

  factory CommunityNotification.fromJson(Map<String, dynamic> json) {
    return CommunityNotification(
      id: json['id']?.toString() ?? '',
      type: json['type'] as String? ?? 'like',
      userId: json['user_id']?.toString() ?? '',
      userName: json['user_name'] as String? ?? 'Unknown',
      userAvatar: json['user_avatar'] as String?,
      postId: json['post_id']?.toString(),
      commentId: json['comment_id']?.toString(),
      content: json['content'] as String?,
      isRead: (json['is_read'] as int? ?? 0) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
