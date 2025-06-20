  import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:fe_sarpras/models/peminjaman_model.dart';

  class PeminjamanService {
    static const String baseUrl = 'http://127.0.0.1:8000/api'; // URL untuk Android Emulator

    static Future<Peminjaman> createPeminjaman({
      required String token,
      required int userId,
      required int barangId,
      required String namaPeminjam,
      required String alasanMeminjam,
      required int jumlah,
      required DateTime tanggalPinjam,
      required DateTime tanggalKembali,
    }) async {
      final url = Uri.parse('$baseUrl/peminjaman');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'user_id': userId,
        'barang_id': barangId,
        'nama_peminjam': namaPeminjam,
        'alasan_meminjam': alasanMeminjam,
        'jumlah': jumlah,
        'tanggal_pinjam': tanggalPinjam.toIso8601String(),
        'tanggal_kembali': tanggalKembali.toIso8601String(),
      });

      final response = await http.post(url, headers: headers, body: body);

      print(response.body);

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body)['data'];
        return Peminjaman.fromJson(data);
      } else {
        throw Exception('Gagal meminjam barang: ${response.body}');
      }
    }
static Future<List<Peminjaman>> getByUser(String token) async {
  final url = Uri.parse('$baseUrl/peminjaman/user');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  });

  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body)['data'];
    return data.map((e) => Peminjaman.fromJson(e)).toList();
  } else {
    throw Exception('Gagal mengambil daftar peminjaman user');
  }
}
  }
