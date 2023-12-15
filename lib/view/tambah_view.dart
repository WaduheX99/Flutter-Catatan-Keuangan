import 'dart:io';

import 'package:catatan_keuangan/model/akun.dart';
import 'package:catatan_keuangan/model/transaksi.dart';
import 'package:catatan_keuangan/tools/firebase_helper.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:catatan_keuangan/tools/styles.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TambahPage extends StatefulWidget {
  const TambahPage({super.key});

  @override
  State<TambahPage> createState() => _TambahPageState();
}

class _TambahPageState extends State<TambahPage> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  bool _isLoading = false;

  TextEditingController namaController = TextEditingController();
  TextEditingController tanggalController = TextEditingController();
  TextEditingController nominalController = TextEditingController();
  bool jenisController = true;
  String kategoriController = '';
  TextEditingController deskripsiController = TextEditingController();

  ImagePicker picker = ImagePicker();
  XFile? file;

  Future<void> addTransaksi(Akun akun) async {
    setState(() {
      _isLoading = true;
    });
    try {
      if (namaController.text.isEmpty ||
          namaController.text == "" ||
          tanggalController.text.isEmpty ||
          tanggalController.text == "" ||
          nominalController.text.isEmpty ||
          nominalController.text == "" ||
          kategoriController.isEmpty ||
          kategoriController == "") {
        throw ("Please fill requied field");
      }
      // Parse the string to DateTime
      DateTime parsedDateTime =
          DateFormat('yyyy-MM-DD hh:mm').parse(tanggalController.text);

      Transaksi transaksi = Transaksi(
        uid: akun.uid,
        nama: namaController.text,
        tanggal: parsedDateTime,
        nominal: int.parse(nominalController.text),
        jenis: jenisController,
        kategori: kategoriController,
        deskripsi: deskripsiController.text,
        gambar: '',
      );

      final respond = await _firebaseHelper.addTransaksi(transaksi, akun, file);
      if (respond == 'success') {
        Navigator.pop(context);
      } else {
        throw respond;
      }
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Akun akun = arguments['akun'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: headerColor,
        title: const Text(
          'Tambah Transaksi',
          style: titleAppBar,
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: Column(
                  children: [
                    const Text(
                      'Transaksi Baru',
                      style: textBold,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Column(
                      children: [
                        TextField(
                          controller: namaController,
                          decoration: const InputDecoration(
                            hintText: 'Nama Transaksi',
                            hintStyle: textRegular,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DateTimePicker(
                          type: DateTimePickerType.dateTime,
                          dateMask: 'MMMM dd, yyyy hh:mm a',
                          controller: tanggalController,
                          decoration: const InputDecoration(
                            hintText: 'Tanggal',
                            hintStyle: textRegular,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: nominalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Nominal',
                            hintStyle: textRegular,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            suffixIcon: Icon(Icons.attach_money),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            hintText: 'Jenis',
                            hintStyle: textRegular,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Pemasukan', style: textRegular),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Pengeluaran', style: textRegular),
                            )
                          ],
                          onChanged: (value) =>
                              setState(() => jenisController = value as bool),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                            hintText: 'Kategori',
                            hintStyle: textRegular,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "Transfer Keluar",
                              child:
                                  Text('Transfer Keluar', style: textRegular),
                            ),
                            DropdownMenuItem(
                              value: "Transfer Masuk",
                              child: Text('Transfer Masuk', style: textRegular),
                            ),
                            DropdownMenuItem(
                              value: "Tiket",
                              child: Text('Tiket', style: textRegular),
                            ),
                            DropdownMenuItem(
                              value: "TopUp",
                              child: Text('TopUp', style: textRegular),
                            ),
                            DropdownMenuItem(
                              value: "Tagihan",
                              child: Text('Tagihan', style: textRegular),
                            ),
                          ],
                          onChanged: (value) => setState(
                              () => kategoriController = value as String),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: deskripsiController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            hintText: 'Deskripsi',
                            hintStyle: textRegular,
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          ),
                        ),

                        SizedBox(height: 20),

                        //masukan file
                        Container(
                          width: double.infinity,
                          child: DottedBorder(
                            dashPattern: [6, 3, 0, 3],
                            borderType: BorderType.RRect,
                            radius: Radius.circular(10),
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(height: 20),
                                  imagePreview(),
                                  Container(
                                    margin: EdgeInsets.all(20),
                                    width: 100,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color:
                                          const Color.fromRGBO(0, 150, 199, 1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        uploadDialog(context);
                                      },
                                      child: const Text(
                                        'Choose Image',
                                        style: TextStyle(
                                          fontFamily: famSemi,
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: secondaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextButton(
                            onPressed: () {
                              addTransaksi(akun);
                            },
                            child: Text('Tambah Transaksi', style: textButton),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Image imagePreview() {
    if (file == null) {
      return Image.asset('assets/image.png', width: 200, height: 200);
    } else {
      return Image.file(File(file!.path), width: 200, height: 200);
    }
  }

  Future<dynamic> uploadDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext) {
          return AlertDialog(
            title: Text('Pilih Aksi'),
            actions: [
              TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.camera);

                  setState(() {
                    file = upload;
                  });

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.camera_alt),
              ),
              TextButton(
                onPressed: () async {
                  XFile? upload =
                      await picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    file = upload;
                  });

                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.photo_library),
              ),
            ],
          );
        });
  }
}
