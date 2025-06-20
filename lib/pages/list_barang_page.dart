import 'package:flutter/material.dart';
import 'package:fe_sarpras/models/barang_model.dart';
import 'package:fe_sarpras/services/barang_service.dart';
import 'barang_detail_page.dart';

class BarangListPage extends StatefulWidget {
  const BarangListPage({super.key});

  @override
  State<BarangListPage> createState() => _BarangListPageState();
}

class _BarangListPageState extends State<BarangListPage> {
  late Future<List<Barang>> _barangFuture;

  @override
  void initState() {
    super.initState();
    _loadBarangs();
  }

  Future<void> _loadBarangs() async {
    setState(() {
      _barangFuture = BarangService.fetchBarangs();
    });
  }

  int _getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1000) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  Widget _buildBarangCard(Barang barang) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BarangDetailPage(barang: barang),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: Colors.pinkAccent.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: barang.foto != null
                  ? Image.network(
                      barang.foto!,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
                      color: Colors.pink.shade100,
                      child: const Icon(
                        Icons.inventory,
                        size: 40,
                        color: Colors.pink,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    barang.namaBarang,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink.shade800,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stok: ${barang.stok}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Barang>>(
      future: _barangFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Tidak ada barang.'));
        }

        final barangs = snapshot.data!;

        return RefreshIndicator(
          onRefresh: _loadBarangs,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: GridView.builder(
              itemCount: barangs.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _getCrossAxisCount(context),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                return _buildBarangCard(barangs[index]);
              },
            ),
          ),
        );
      },
    );
  }
}
