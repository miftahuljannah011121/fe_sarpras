import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/peminjaman_model.dart';
import '../models/pengembalian_model.dart';

class PengembalianService {
  final String baseUrl = 'http://your-api-url.test/api'; // ganti dengan URL API Laravel

  Future<List<Peminjaman>> getPeminjamanBelumDikembalikan() async {
    final response = await http.get(Uri.parse('$baseUrl/peminjaman-belum-dikembalikan'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((e) => Peminjaman.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data peminjaman');
    }
  }

  Future<bool> kirimPengembalian(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pengembalian'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    return response.statusCode == 201;
  }
}
