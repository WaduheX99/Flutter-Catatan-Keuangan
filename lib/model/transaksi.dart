class Transaksi {
  final String uid;
  final String nama;
  final DateTime tanggal;
  final int nominal;
  final bool jenis; // true = +   false = -
  final String kategori;
  final String deskripsi;
  final String gambar;
  final String docId;

  Transaksi({
    required this.uid,
    required this.nama,
    required this.tanggal,
    required this.nominal,
    required this.jenis,
    required this.kategori,
    this.deskripsi = '',
    this.gambar = '',
    this.docId = '',
  });
}
