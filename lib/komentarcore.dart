class Komentar {
  final int? idKomentar;
  final int? postId;
  final int? userId;
  final String? username;
  final String isiKomentar;
  final DateTime? tanggalKomentar;

  Komentar({
    this.idKomentar,
    this.postId,
    this.userId,
    this.username,
    required this.isiKomentar,
    this.tanggalKomentar,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      idKomentar: json['id_komentar'],
      postId: json['post_id'],
      userId: json['user_id'],
      username: json['username'],
      isiKomentar: json['isi_komentar'],
      tanggalKomentar: json['tanggal_komentar'] != null
          ? DateTime.parse(json['tanggal_komentar'])
          : null,
    );
  }
}