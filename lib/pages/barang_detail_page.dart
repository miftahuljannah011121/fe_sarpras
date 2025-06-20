import 'package:flutter/material.dart';
import 'package:fe_sarpras/models/barang_model.dart';
import 'package:fe_sarpras/pages/form_peminjaman_page.dart'; // Import halaman form peminjaman

class BarangDetailPage extends StatelessWidget {
  final Barang barang;

  const BarangDetailPage({super.key, required this.barang});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(barang.namaBarang),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            barang.foto != null
                ? Image.network(barang.foto!, height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.pink.shade100,
                    child: const Icon(Icons.inventory, size: 60, color: Colors.pink),
                  ),
            const SizedBox(height: 20),
            Text(
              barang.namaBarang,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Stok: ${barang.stok}',
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),

            // Tombol pinjam barang
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormPeminjamanPage(barang: barang),
                    ),
                  );
                },
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Pinjam Barang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
