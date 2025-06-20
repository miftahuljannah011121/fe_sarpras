import 'dart:convert';
import 'package:fe_sarpras/models/barang_model.dart';
import 'package:http/http.dart' as http;

class BarangService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/barang'; // Ganti jika pakai device

  static Future<List<Barang>> fetchBarangs() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> barangList = data['data'];
      return barangList.map((json) => Barang.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data barang');
    }
  }
}
