class PostModel {
  final String id;
  final String userId;
  final String? content;
  final String? mediaUrl;
  final String? mediaType; // image, video, pdf, animation, other
  final String? thumbnailUrl;
  final bool allowDownload; // Solo se puede descargar si el autor lo permite
  final int likesCount;
  final int repostsCount;
  final int savesCount;
  final bool isApproved;
  final DateTime createdAt;

  // Datos del autor (join)
  final String? authorUsername;
  final String? authorDisplayName;
  final String? authorAvatarUrl;

  // Estado del usuario actual
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  const PostModel({
    required this.id,
    required this.userId,
    this.content,
    this.mediaUrl,
    this.mediaType,
    this.thumbnailUrl,
    this.allowDownload = false,
    this.likesCount = 0,
    this.repostsCount = 0,
    this.savesCount = 0,
    this.isApproved = true,
    required this.createdAt,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
    this.isLiked = false,
    this.isReposted = false,
    this.isSaved = false,
  });

  factory PostModel.fromMap(Map<String, dynamic> map) {
    final author = map['profiles'] as Map<String, dynamic>?;

    return PostModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String?,
      mediaUrl: map['media_url'] as String?,
      mediaType: map['media_type'] as String?,
      thumbnailUrl: map['thumbnail_url'] as String?,
      allowDownload: map['allow_download'] as bool? ?? false,
      likesCount: map['likes_count'] as int? ?? 0,
      repostsCount: map['reposts_count'] as int? ?? 0,
      savesCount: map['saves_count'] as int? ?? 0,
      isApproved: map['is_approved'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      authorUsername: author?['username'] as String?,
      authorDisplayName: author?['display_name'] as String?,
      authorAvatarUrl: author?['avatar_url'] as String?,
      isLiked: map['is_liked'] as bool? ?? false,
      isReposted: map['is_reposted'] as bool? ?? false,
      isSaved: map['is_saved'] as bool? ?? false,
    );
  }

  bool get canDownload => allowDownload;

  PostModel copyWith({
    bool? isLiked,
    bool? isReposted,
    bool? isSaved,
    int? likesCount,
    int? repostsCount,
    int? savesCount,
    bool? allowDownload,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      content: content,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      thumbnailUrl: thumbnailUrl,
      allowDownload: allowDownload ?? this.allowDownload,
      likesCount: likesCount ?? this.likesCount,
      repostsCount: repostsCount ?? this.repostsCount,
      savesCount: savesCount ?? this.savesCount,
      isApproved: isApproved,
      createdAt: createdAt,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarUrl: authorAvatarUrl,
      isLiked: isLiked ?? this.isLiked,
      isReposted: isReposted ?? this.isReposted,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
