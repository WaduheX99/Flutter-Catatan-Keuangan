import 'package:catatan_keuangan/components/input_components.dart';
import 'package:catatan_keuangan/tools/firebase_helper.dart';

import 'package:flutter/material.dart';
import 'package:catatan_keuangan/tools/styles.dart';

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final FirebaseHelper _firebaseHelper = FirebaseHelper();

  bool _isLoading = false;

  bool passwordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void initState() {
    super.initState();
    passwordVisible = true;
  }

  void toRegister() {
    Navigator.pushNamed(context, '/register');
  }

  void login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        throw ("Please fill all fields");
      }
      String respond = await _firebaseHelper.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (respond == 'success') {
        Navigator.pushReplacementNamed(context, '/home');
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
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [secondaryColor, headerColor, primaryColor]),
                ),
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      formTitle("WELCOME\nBACK"),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                        child: Container(
                          child: Column(
                            children: [
                              UserField(
                                  label: 'Email',
                                  controller: _emailController,
                                  inputType: TextInputType.emailAddress,
                                  icon: Icons.email),
                              PasswordField(
                                  label: 'Password',
                                  controller: _passwordController,
                                  passVisible: passwordVisible,
                                  visPresed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  }),
                              SizedBox(height: 30),
                              ButtonAuth(
                                  onPressed: () {
                                    login();
                                  },
                                  label: "LOGIN",
                                  fgColor: Colors.white,
                                  bgColor: headerColor),
                              const Divider(
                                color: primaryColor,
                                thickness: 1,
                              ),
                              ButtonAuth(
                                  label: "SIGN UP",
                                  onPressed: toRegister,
                                  fgColor: headerColor,
                                  bgColor: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
