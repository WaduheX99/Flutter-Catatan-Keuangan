import 'dart:io';

import 'package:catatan_keuangan/model/akun.dart';
import 'package:catatan_keuangan/model/transaksi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class FirebaseHelper {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<String> login({String email = '', String password = ''}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> register(
      {String nama = '',
      String email = '',
      String password = '',
      String confirmPassword = ''}) async {
    try {
      CollectionReference akunCollection = _firestore.collection('akun');

      QuerySnapshot querySnapshot =
          await akunCollection.where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return 'Email already registered!';
      } else {
        await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        final id = akunCollection.doc().id;

        await akunCollection.doc(id).set({
          'uid': _auth.currentUser!.uid,
          'nama': nama,
          'email': email,
          'saldo': 0,
          'docId': id,
        });

        return 'success';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> logout() async {
    try {
      await _auth.signOut();

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<Akun> getAkun() async {
    final User? user = _auth.currentUser;
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('akun')
          .where('uid', isEqualTo: user!.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return Akun(
            uid: userData['uid'],
            nama: userData['nama'],
            saldo: userData['saldo'],
            email: userData['email'],
            docId: userData['docId']);
      } else {
        throw ('Account not found!');
      }
    } catch (e) {
      return Akun(
        uid: '',
        nama: e.toString(),
        saldo: 0,
        email: '',
        docId: '',
      );
    }
  }

  Future<List<Transaksi>> getListTransaksi() async {
    List<Transaksi> listTransaksi = [];
    final User? user = _auth.currentUser;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('transaksi')
          .where('uid', isEqualTo: user!.uid)
          .orderBy('tanggal', descending: true)
          .get();

      for (var documents in querySnapshot.docs) {
        listTransaksi.add(Transaksi(
          uid: documents['uid'],
          nama: documents['nama'],
          tanggal: documents['tanggal'].toDate(),
          nominal: documents['nominal'],
          jenis: documents['jenis'],
          kategori: documents['kategori'],
          deskripsi: documents['deskripsi'],
          gambar: documents['gambar'],
          docId: documents['docId'],
        ));
      }
    } catch (e) {
      return listTransaksi;
    }

    return listTransaksi;
  }

  Future<String> addTransaksi(
      Transaksi transaksi, Akun akun, XFile? file) async {
    try {
      CollectionReference transaksiCollection =
          _firestore.collection('transaksi');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(transaksi.tanggal);

      String url = await uploadImage(file);

      final id = transaksiCollection.doc().id;

      await transaksiCollection.doc(id).set({
        'nama': transaksi.nama,
        'tanggal': timestamp,
        'nominal': transaksi.nominal,
        'jenis': transaksi.jenis,
        'kategori': transaksi.kategori,
        'deskripsi': transaksi.deskripsi,
        'gambar': url,
        'uid': _auth.currentUser!.uid,
        'docId': id,
      }).catchError((e) {
        throw e;
      });

      updateSaldo(transaksi, akun);

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> updateTransaksi(Transaksi transaksi, Akun akun, XFile? file,
      [int deficit = 0]) async {
    try {
      CollectionReference transaksiCollection =
          _firestore.collection('transaksi');

      // Convert DateTime to Firestore Timestamp
      Timestamp timestamp = Timestamp.fromDate(transaksi.tanggal);

      String url = transaksi.gambar;
      if (file != null) {
        url = await uploadImage(file, transaksi.gambar);
      }

      await transaksiCollection.doc(transaksi.docId).update({
        'nama': transaksi.nama,
        'tanggal': timestamp,
        'nominal': transaksi.nominal,
        'jenis': transaksi.jenis,
        'kategori': transaksi.kategori,
        'deskripsi': transaksi.deskripsi,
        'gambar': url,
        'uid': _auth.currentUser!.uid,
        'docId': transaksi.docId,
      });

      updateSaldo(transaksi, akun, deficit);
      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> deleteTransaksi(Transaksi transaksi) async {
    try {
      await _firestore.collection("transaksi").doc(transaksi.docId).delete();

      if (transaksi.gambar != '') {
        await _storage.refFromURL(transaksi.gambar).delete();
      }

      return 'success';
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> updateSaldo(Transaksi transaksi, Akun akun,
      [int deficit = 0]) async {
    var ref = _firestore.collection('akun').doc(akun.docId);

    int saldo = 0;
    if (deficit != 0) {
      saldo = transaksi.nominal - deficit;
    } else {
      saldo = transaksi.nominal;
    }

    if (!transaksi.jenis) {
      saldo *= -1;
    }
    return ref.update({'saldo': FieldValue.increment(saldo)});
  }

  Future<String> uploadImage(XFile? file, [String url = '']) async {
    if (file == null) return '';

    if (url != '') {
      try {
        await _storage.refFromURL(url).delete();
      } catch (e) {
        return '';
      }
    }

    String uniqueFilename = DateTime.now().millisecondsSinceEpoch.toString();

    Reference dirUpload =
        _storage.ref().child('upload/${_auth.currentUser!.uid}');
    Reference storedDir = dirUpload.child(uniqueFilename);

    try {
      await storedDir.putFile(File(file.path));

      return await storedDir.getDownloadURL();
    } catch (e) {
      return '';
    }
  }
}
