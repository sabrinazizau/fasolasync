import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tugas5/utils/fire_auth.dart';
import 'package:tugas5/utils/validator.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:tugas5/screens/login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final registerFormKey = GlobalKey<FormState>();

  final usernameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final focusUsername = FocusNode();
  final focusEmail = FocusNode();
  final focusPassword = FocusNode();

  bool isProcessing = false;

  @override
  Widget build(BuildContext context){
    return GestureDetector(
      onTap: () {
        focusUsername.unfocus();
        focusEmail.unfocus();
        focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/undraw_engineering_team_a7n2.svg',
                  height: 200,
                ),
                Form(
                  key: registerFormKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: usernameTextController,
                        focusNode: focusUsername,
                        validator: (value) => Validator.validateName(
                          name: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Username",
                          errorBorder: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height:16.0),
                      TextFormField(
                        controller: emailTextController,
                        focusNode: focusEmail,
                        validator: (value) => Validator.validateEmail(
                          email: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Email",
                          errorBorder:  UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height:16.0),
                      TextFormField(
                        controller: passwordTextController,
                        focusNode: focusPassword,
                        obscureText: true,
                        validator: (value) => Validator.validatePassword(
                          password: value,
                        ),
                        decoration: InputDecoration(
                          hintText: "Password",
                          errorBorder:  UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            borderSide: const BorderSide(
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height:32.0),
                      isProcessing
                          ? const CircularProgressIndicator()
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        isProcessing = true;
                                      });

                                      if (registerFormKey.currentState!
                                          .validate()) {
                                        User? user = await FireAuth
                                            .registerUsingEmailPassword(
                                              name: usernameTextController.text, 
                                              email: emailTextController.text, 
                                              password: 
                                                  passwordTextController.text,
                                            );

                                            setState(() {
                                              isProcessing = false;
                                            });

                                            if (user != null) {
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage(),
                                                ),
                                                ModalRoute.withName('/'),
                                              );
                                            }
                                          }
                                    },
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ), 
                                ),
                              ],
                          )
                    ],
                  ))
              ],
            ),
          ),
        )
      ),
    );
  }
}