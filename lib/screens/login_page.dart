import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/song_form_add.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../screens/nav_bar.dart';

import '/utils/fire_auth.dart';
import '/utils/validator.dart';

const kTextFieldDecoration = InputDecoration(
  //hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.blueGrey),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;
  bool _obscureText = true;

  String role = '';

  // @override
  // void dispose() {
  //   _emailTextController.dispose();
  //   _passwordTextController.dispose();
  //   _focusEmail.dispose();
  //   _focusPassword.dispose();
  //   super.dispose();
  // }

  Future<FirebaseApp> _initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        String email = userData['email'];
        role = userData['role'];

        print('Email: $email');
        print('Role: $role');

        if (role == 'admin') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SongFormAdd(),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              //builder: (context) => MusicPlayerScreen(),
              builder: (context) => NavBarDemo(user: user),
            ),
          );
        }
      }
    }

    return firebaseApp;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Log In',
            style: TextStyle(
                color: Color(0xFF4A55A2), fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: FutureBuilder(
          future: _initializeFirebase(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFC5DFF8), Color(0xFF4A55A2)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50.0),
                    const Text(
                      'Start listening with a\nFaSoLaSync account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF4A55A2),
                        fontSize: 30,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25.0),

                    // const SizedBox(height: 50.0),
                    // SvgPicture.asset(
                    //   'assets/undraw_music_re_a2jk.svg',
                    //   height: 200,
                    // ),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: _emailTextController,
                            focusNode: _focusEmail,
                            validator: (value) => Validator.validateEmail(
                              email: value,
                            ),
                            decoration: kTextFieldDecoration.copyWith(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Email",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          TextFormField(
                            controller: _passwordTextController,
                            focusNode: _focusPassword,
                            obscureText: _obscureText,
                            validator: (value) => Validator.validatePassword(
                              password: value,
                            ),
                            decoration: kTextFieldDecoration.copyWith(
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                                child: Icon(
                                    _obscureText
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Color(0xFF4A55A2)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              hintText: "Password",
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(6.0),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(height: 25.0),
                          _isProcessing
                              ? const CircularProgressIndicator()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          _focusEmail.unfocus();
                                          _focusPassword.unfocus();

                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              _isProcessing = true;
                                            });

                                            User? user = await FireAuth
                                                .signInUsingEmailPassword(
                                              email: _emailTextController.text,
                                              password:
                                                  _passwordTextController.text,
                                            );

                                            setState(() {
                                              _isProcessing = false;
                                            });
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            primary: Colors.white,
                                            onPrimary: Color(0xFF4A55A2),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 20.0)),
                                        child: const Text(
                                          'Log In',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),

                                      //   child: const Padding(
                                      //     padding: EdgeInsets.symmetric(
                                      //         vertical: 10.0, horizontal: 20.0),
                                      //     child: const Text(
                                      //       'Sign In',
                                      //       style: TextStyle(
                                      //         color: Color(0xFF4A55A2),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),

                                      //const SizedBox(width: 24.0),

                                      // Expanded(
                                      //   child: ElevatedButton(
                                      //     onPressed: () {
                                      //       Navigator.of(context).push(
                                      //         MaterialPageRoute(
                                      //           builder: (context) =>
                                      //               const RegisterPage(),
                                      //         ),
                                      //       );
                                      //     },
                                      //     child: const Text(
                                      //       'Register',
                                      //       style: TextStyle(color: Colors.white),
                                      //     ),
                                      //   ),
                                      // ),
                                    ),
                                  ],
                                )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }

            return const Center(
                //child: CircularProgressIndicator(),
                );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Membersihkan sumber daya ketika widget dihapus
    _emailTextController.dispose();
    _passwordTextController.dispose();
    _focusEmail.dispose();
    _focusPassword.dispose();
    super.dispose();
  }
}
