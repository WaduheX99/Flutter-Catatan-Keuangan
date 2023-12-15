import 'package:catatan_keuangan/components/kategori_icon.dart';
import 'package:catatan_keuangan/model/akun.dart';
import 'package:catatan_keuangan/model/transaksi.dart';
import 'package:catatan_keuangan/tools/firebase_helper.dart';
import 'package:catatan_keuangan/tools/formater.dart';

import 'package:flutter/material.dart';
import 'package:catatan_keuangan/tools/styles.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({
    super.key,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  void delete(Transaksi transaksi) async {
    final respond = await _firebaseHelper.deleteTransaksi(transaksi);

    if (respond == 'success') {
      Navigator.pop(context);
    } else {
      final snackbar = SnackBar(content: Text(respond));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Transaksi transaksi = arguments['transaksi'];
    final Akun akun = arguments['akun'];

    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Transaksi', style: titleAppBar),
          centerTitle: true,
          backgroundColor: headerColor,
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 40),
                child: transaksi.jenis
                    ? const Text('Transaksi Masuk',
                        textAlign: TextAlign.center, style: textBold)
                    : const Text('Transaksi Keluar',
                        textAlign: TextAlign.center, style: textBold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                child: transaksi.gambar == ''
                    ? Image.asset('assets/no-picture.jpg')
                    : Image.network(transaksi.gambar),
              ),
              Container(
                  decoration: const BoxDecoration(
                    border: Border.symmetric(
                        horizontal: BorderSide(width: 5, color: headerColor)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(numFormat.format(transaksi.nominal),
                      textAlign: TextAlign.center,
                      style: transaksi.jenis ? priceMasuk : priceKeluar)),
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaksi.nama,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: secondaryColor),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                transaksi.kategori,
                                style: const TextStyle(
                                    fontSize: 12, color: secondaryColor),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                dateFormat.format(transaksi.tanggal),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    kategoriIcon(transaksi.kategori),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Column(children: [
                  const Text(
                    'Deskripsi Transaksi',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    transaksi.deskripsi,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontSize: 14),
                  ),
                ]),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                //edit dan hapus
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(0, 150, 199, 1),
                        borderRadius: BorderRadius.circular(30)),
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: TextButton(
                      onPressed: () {
                        //arahakan ke halaman detail
                        Navigator.pushReplacementNamed(context, '/update',
                            arguments: {'transaksi': transaksi, 'akun': akun});
                      },
                      child: const Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 150, 199, 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: TextButton(
                      onPressed: () {
                        delete(transaksi);
                      },
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ));
  }
}
