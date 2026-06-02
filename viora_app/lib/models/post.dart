class Post {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final String? imageUrl;
  final List<String> hashtags;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final String? challengeName; // Tên thử thách nếu có
  final int? daysStreak; // Số ngày streak nếu có
  final bool isFollowing; // Current user is following post author
  final bool isFollowedBack; // Post author is following current user back
  final bool isOwnPost; // Post belongs to current user

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.imageUrl,
    this.hashtags = const [],
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.challengeName,
    this.daysStreak,
    this.isFollowing = false,
    this.isFollowedBack = false,
    this.isOwnPost = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      userName: json['user_name'] ?? '',
      userAvatar: json['user_avatar'],
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      hashtags: json['hashtags'] != null 
          ? List<String>.from(json['hashtags']) 
          : [],
      likeCount: json['like_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      challengeName: json['challenge_name'],
      daysStreak: json['days_streak'],
      isFollowing: json['is_following'] ?? false,
      isFollowedBack: json['is_followed_back'] ?? false,
      isOwnPost: json['is_own_post'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      'user_avatar': userAvatar,
      'content': content,
      'image_url': imageUrl,
      'hashtags': hashtags,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'challenge_name': challengeName,
      'days_streak': daysStreak,
      'is_following': isFollowing,
      'is_followed_back': isFollowedBack,
      'is_own_post': isOwnPost,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? content,
    String? imageUrl,
    List<String>? hashtags,
    int? likeCount,
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    String? challengeName,
    int? daysStreak,
    bool? isFollowing,
    bool? isFollowedBack,
    bool? isOwnPost,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      hashtags: hashtags ?? this.hashtags,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      challengeName: challengeName ?? this.challengeName,
      daysStreak: daysStreak ?? this.daysStreak,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBack: isFollowedBack ?? this.isFollowedBack,
      isOwnPost: isOwnPost ?? this.isOwnPost,
    );
  }
}
