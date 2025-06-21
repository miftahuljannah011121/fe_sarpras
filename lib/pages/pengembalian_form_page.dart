import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/peminjaman_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPengembalianPage extends StatefulWidget {
  final int userId;

  const FormPengembalianPage({super.key, required this.userId});

  @override
  State<FormPengembalianPage> createState() => _FormPengembalianPageState();
}

class _FormPengembalianPageState extends State<FormPengembalianPage> {
  final _formKey = GlobalKey<FormState>();
  List<Peminjaman> peminjamans = [];
  Peminjaman? selectedPeminjaman;
  String? kondisi;
  DateTime? tanggalDikembalikan;
  bool isLoading = false;
  int? jumlahDikembalikan;

  @override
  void initState() {
    super.initState();
    fetchPeminjamans();
  }

  Future<void> fetchPeminjamans() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/peminjaman/belum-dikembalikan/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        final allPeminjamans = List<Peminjaman>.from(
          data.map((p) => Peminjaman.fromJson(p)),
        );

        setState(() {
          peminjamans = allPeminjamans.where((p) => p.status == 'approved').toList();
        });
      } else {
        showError('Gagal mengambil data peminjaman');
      }
    } catch (e) {
      showError('Terjadi kesalahan saat mengambil data: $e');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedPeminjaman == null || kondisi == null || jumlahDikembalikan == null || tanggalDikembalikan == null) return;

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/pengembalian'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': widget.userId,
          'peminjaman_id': selectedPeminjaman!.id,
          'jumlah': jumlahDikembalikan,
          'tanggal_dikembalikan': DateFormat('yyyy-MM-dd').format(tanggalDikembalikan!),
          'kondisi_barang': kondisi,
          'status': 'pending',
        }),
      );

      final body = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final denda = body['data']['denda'] ?? 0;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengembalian berhasil. Denda: Rp$denda')),
        );
        resetForm();
        fetchPeminjamans();
      } else {
        showError(body['message']?.toString() ?? response.body);
      }
    } catch (e) {
      showError('Terjadi kesalahan saat mengirim pengembalian');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void resetForm() {
    setState(() {
      selectedPeminjaman = null;
      kondisi = null;
      jumlahDikembalikan = null;
      tanggalDikembalikan = null;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Pengembalian')),
      body: peminjamans.isEmpty
          ? const Center(child: Text('Tidak ada barang yang bisa dikembalikan.'))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<Peminjaman>(
                      decoration: const InputDecoration(
                        labelText: 'Pilih Barang yang Dipinjam',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedPeminjaman,
                      items: peminjamans.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.namaBarang ?? 'Barang tidak diketahui'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedPeminjaman = value);
                      },
                      validator: (value) => value == null ? 'Wajib pilih barang' : null,
                    ),
                    const SizedBox(height: 16),
                    if (selectedPeminjaman != null)
                      Text('Jumlah yang dipinjam: ${selectedPeminjaman!.jumlah}'),
                    if (selectedPeminjaman?.tanggalKembali != null)
              
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Jumlah yang Dikembalikan',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: jumlahDikembalikan?.toString(),
                      onChanged: (val) {
                        jumlahDikembalikan = int.tryParse(val);
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Jumlah wajib diisi';
                        final jml = int.tryParse(val);
                        if (jml == null || jml <= 0) return 'Jumlah harus lebih dari 0';
                        if (selectedPeminjaman != null && jml > selectedPeminjaman!.jumlah) {
                          return 'Jumlah melebihi jumlah yang dipinjam';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kondisi Barang',
                        border: OutlineInputBorder(),
                      ),
                      value: kondisi,
                      items: ['baik', 'rusak', 'hilang'].map((k) {
                        return DropdownMenuItem(
                          value: k,
                          child: Text(k.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => kondisi = value);
                      },
                      validator: (value) => value == null ? 'Wajib pilih kondisi' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        'Tanggal Pengembalian: ${tanggalDikembalikan == null ? '-' : DateFormat('dd MMM yyyy').format(tanggalDikembalikan!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (picked != null) {
                          setState(() => tanggalDikembalikan = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Kembalikan Barang"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
