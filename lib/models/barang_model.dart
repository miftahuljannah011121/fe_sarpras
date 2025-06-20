class Barang {
  final int id;
  final String namaBarang;
  final int stok;
  final String kategori;
  final String? foto;

  Barang({
    required this.id,
    required this.namaBarang,
    required this.stok,
    required this.kategori,
    this.foto,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      namaBarang: json['nama_barang'],
      stok: json['stok'],
      kategori: json['kategori'],
      foto: json['foto'],
    );
  }
}
