import 'package:catatan_keuangan/model/akun.dart';
import 'package:catatan_keuangan/model/transaksi.dart';
import 'package:catatan_keuangan/tools/firebase_helper.dart';
import 'package:catatan_keuangan/tools/styles.dart';
import 'package:catatan_keuangan/tools/formater.dart';
import 'package:flutter/material.dart';
import 'package:catatan_keuangan/components/list_item.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  bool _isLoading = false;

  Akun akun = Akun(
    uid: '',
    nama: '',
    saldo: 0,
    email: '',
    docId: '',
  ); // null safety sebelum fetch dari firebase di initState
  List<Transaksi> listTransaksi = [];

  void logout() async {
    final navigator = Navigator.of(context);
    final scaffold = ScaffoldMessenger.of(context);
    setState(() {
      _isLoading = true;
    });

    try {
      String respond = await _firebaseHelper.logout();

      if (respond == 'success') {
        navigator.pushReplacementNamed('/login');
      } else {
        throw respond;
      }
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      scaffold.showSnackBar(snackbar);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getAkun() async {
    try {
      final respond = await _firebaseHelper.getAkun();
      setState(() {
        akun = respond;
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  Future<void> getTransaksi() async {
    try {
      final respond = await _firebaseHelper.getListTransaksi();
      setState(() {
        listTransaksi = respond;
      });
    } catch (e) {
      final snackbar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getAkun();
    getTransaksi();
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Hi ${akun.nama}!",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontFamily: 'Poppins-bold',
                            ),
                          ),
                          IconButton(
                            onPressed: logout,
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: headerColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        alignment: Alignment.topLeft,
                        child: const Text(
                          'Catatan Keuangan',
                          style: TextStyle(
                              color: headerColor,
                              fontSize: 20,
                              fontFamily: famBold),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: EdgeInsets.all(20),
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: headerColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Saldo anda saat ini',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: famSemi,
                              ),
                            ),
                            Text(
                              numFormat.format(akun.saldo),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontFamily: 'Poppins-bold',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Expanded(
                        child: ListView.builder(
                          itemCount: listTransaksi.length,
                          padding: const EdgeInsets.all(10),
                          itemBuilder: (context, index) {
                            return ListItem(
                              transaksi: listTransaksi[index],
                              akun: akun,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/tambah', arguments: {'akun': akun});
          },
          backgroundColor: primaryColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: const Icon(Icons.add),
        ));
  }
}
