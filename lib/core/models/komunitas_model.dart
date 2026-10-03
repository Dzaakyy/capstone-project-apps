class Komunitas {
  final int? idKomunitas;
  final int? userId;
  final String? username;
  final String? judul;
  final String isi;
  final String? image;
  final DateTime? tanggalPost;
  final int? likeCount;
  final int? dislikeCount;
  final int commentCount;

  Komunitas({
    this.idKomunitas,
    this.userId,
    this.username,
    this.judul,
    required this.isi,
    this.image,
    this.tanggalPost,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
  });

  factory Komunitas.fromJson(Map<String, dynamic> json) {
    return Komunitas(
      idKomunitas: json['id_komunitas'],
      userId: json['user_id'],
      username: json['user']?['username'],
      judul: json['judul'],
      isi: json['isi'],
      image: json['image'],
      tanggalPost: json['tanggal_post'] != null
          ? DateTime.parse(json['tanggal_post'])
          : null,
      likeCount: json['like_count'] ?? 0,
      dislikeCount: json['dislike_count'] ?? 0,
      commentCount: json['comment_count'] ?? 0,
    );
  }
}

