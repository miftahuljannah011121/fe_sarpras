import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fe_sarpras/models/barang_model.dart';
import 'package:fe_sarpras/services/peminjaman_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPeminjamanPage extends StatefulWidget {
  final Barang barang;

  const FormPeminjamanPage({super.key, required this.barang});

  @override
  State<FormPeminjamanPage> createState() => _FormPeminjamanPageState();
}

class _FormPeminjamanPageState extends State<FormPeminjamanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();

  DateTime? _tanggalPinjam;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tanggalPinjam = DateTime.now();
  }

  bool _validateDates() {
    if (_tanggalPinjam == null) {
      setState(() => _errorMessage = 'Tanggal pinjam harus dipilih');
      return false;
    }

    if (_tanggalPinjam!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      setState(() => _errorMessage = 'Tanggal pinjam tidak boleh di masa lalu');
      return false;
    }

    setState(() => _errorMessage = null);
    return true;
  }

  Future<void> _submitForm() async {
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate() || !_validateDates()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final userId = prefs.getInt('user_id');
      final userName = prefs.getString('user_name');

      if (token == null || userId == null || userName == null) {
        throw Exception('Gagal mengakses data pengguna. Silakan login ulang.');
      }

      final barangId = widget.barang.id;
      if (barangId == null) {
        throw Exception('Barang tidak valid (ID tidak tersedia).');
      }

      final jumlah = int.tryParse(_jumlahController.text.trim());
      if (jumlah == null || jumlah <= 0) {
        throw Exception('Jumlah tidak valid.');
      }

      final tanggalKembali = _tanggalPinjam!.add(const Duration(days: 1));

      final peminjaman = await PeminjamanService.createPeminjaman(
        token: token,
        userId: userId,
        barangId: barangId,
        namaPeminjam: userName,
        alasanMeminjam: _alasanController.text.trim(),
        jumlah: jumlah,
        tanggalPinjam: _tanggalPinjam!,
        tanggalKembali: tanggalKembali,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Peminjaman berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, peminjaman);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Gagal mengajukan peminjaman: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Peminjaman'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.barang.namaBarang,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stok tersedia: ${widget.barang.stok}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _jumlahController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah Pinjam',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                  final jumlah = int.tryParse(value);
                  if (jumlah == null || jumlah <= 0) return 'Jumlah harus lebih dari 0';
                  if (jumlah > widget.barang.stok) return 'Jumlah melebihi stok yang tersedia';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Tanggal Pinjam: ${_tanggalPinjam == null ? "-" : DateFormat('dd MMM yyyy').format(_tanggalPinjam!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _tanggalPinjam ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _tanggalPinjam = picked);
                    _validateDates();
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alasanController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Meminjam',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Alasan wajib diisi';
                  if (value.trim().length < 10) return 'Alasan minimal 10 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(_isLoading ? 'Mengirim...' : 'Ajukan Peminjaman'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                  disabledBackgroundColor: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
