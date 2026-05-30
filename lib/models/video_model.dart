class Video {
  final String id;
  final String title;
  final String description;
  final String localPath; // Path in phone memory
  final String? thumbnailPath;
  final String uploaderId;
  final String uploaderName;
  final DateTime uploadDate;
  final bool isApproved;
  final int likes;
  final List<String> tags;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.localPath,
    this.thumbnailPath,
    required this.uploaderId,
    required this.uploaderName,
    required this.uploadDate,
    required this.isApproved,
    required this.likes,
    required this.tags,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'localPath': localPath,
      'thumbnailPath': thumbnailPath,
      'uploaderId': uploaderId,
      'uploaderName': uploaderName,
      'uploadDate': uploadDate,
      'isApproved': isApproved,
      'likes': likes,
      'tags': tags,
    };
  }

  factory Video.fromMap(String id, Map<String, dynamic> map) {
    return Video(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      localPath: map['localPath'] ?? '',
      thumbnailPath: map['thumbnailPath'],
      uploaderId: map['uploaderId'] ?? '',
      uploaderName: map['uploaderName'] ?? '',
      uploadDate: (map['uploadDate'] as dynamic).toDate(),
      isApproved: map['isApproved'] ?? false,
      likes: map['likes'] ?? 0,
      tags: List<String>.from(map['tags'] ?? []),
    );
  }
}