import 'user_model.dart';

class Peminjaman {
  final int id;
  final int barangId;
  final int userId;
  final String namaPeminjam;
  final String alasanMeminjam;
  final int jumlah;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String? namaBarang; // Diambil dari objek barang
  final String? status;
  final User? user;

  Peminjaman({
    required this.id,
    required this.barangId,
    required this.userId,
    required this.namaPeminjam,
    required this.alasanMeminjam,
    required this.jumlah,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    this.namaBarang,
        this.status,
    this.user,
  });

 factory Peminjaman.fromJson(Map<String, dynamic> json) {
  return Peminjaman(
    id: json['id'],
    barangId: json['barang_id'],
    userId: json['user_id'],
    namaPeminjam: json['nama_peminjam'],
    alasanMeminjam: json['alasan_meminjam'],
    jumlah: json['jumlah'],
    tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
    tanggalKembali: DateTime.parse(json['tanggal_kembali']),
    namaBarang: json['barang'] != null ? json['barang']['nama_barang'] : null,
    status: json['status'],
    user: json['user'] != null ? User.fromJson(json['user']) : null,
  );
}
}