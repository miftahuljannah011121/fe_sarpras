import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/peminjaman_model.dart';

class FormPengembalianPage extends StatefulWidget {
  final int userId;

  const FormPengembalianPage({super.key, required this.userId});

  @override
  State<FormPengembalianPage> createState() => _FormPengembalianPageState();
}

class _FormPengembalianPageState extends State<FormPengembalianPage> {
  List<Peminjaman> peminjamans = [];
  Peminjaman? selectedPeminjaman;
  DateTime? tanggalKembali;
  String? kondisi;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchPeminjamans();
  }

  Future<void> fetchPeminjamans() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/peminjaman/belum-dikembalikan/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      setState(() {
        peminjamans = List<Peminjaman>.from(data.map((p) => Peminjaman.fromJson(p)));
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate() &&
        selectedPeminjaman != null &&
        tanggalKembali != null &&
        kondisi != null) {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/pengembalian'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'peminjaman_id': selectedPeminjaman!.id,
          'jumlah': selectedPeminjaman!.jumlah,
          'tanggal_dikembalikan': DateFormat('yyyy-MM-dd').format(tanggalKembali!),
          'kondisi_barang': kondisi,
          'status': 'pending',
        }),
      );

      final body = jsonDecode(response.body);
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengembalian berhasil dikirim')),
        );
        setState(() {
          selectedPeminjaman = null;
          tanggalKembali = null;
          kondisi = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: ${body['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: peminjamans.isEmpty
          ? const Center(child: CircularProgressIndicator())
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
                      items: peminjamans.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.namaBarang ?? 'Barang'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPeminjaman = value;
                        });
                      },
                      validator: (value) => value == null ? 'Wajib pilih barang' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(tanggalKembali != null
                          ? DateFormat('yyyy-MM-dd').format(tanggalKembali!)
                          : 'Pilih Tanggal Pengembalian'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            tanggalKembali = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Kondisi Barang',
                        border: OutlineInputBorder(),
                      ),
                      items: ['baik', 'rusak', 'hilang'].map((k) {
                        return DropdownMenuItem(
                          value: k,
                          child: Text(k.toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          kondisi = value;
                        });
                      },
                      validator: (value) => value == null ? 'Wajib pilih kondisi' : null,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                      ),
                      child: const Text("Kembalikan Barang"),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
