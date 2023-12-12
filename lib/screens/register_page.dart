import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tugas5/utils/fire_auth.dart';
import 'package:tugas5/utils/validator.dart';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:tugas5/screens/login_page.dart';

const kTextFieldDecoration = InputDecoration(
  //hintText: 'Enter a value',
  hintStyle: TextStyle(color: Colors.blueGrey),
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _backgroundColor;
  //late Animation<Color?> _textColor;

  final registerFormKey = GlobalKey<FormState>();

  final usernameTextController = TextEditingController();
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();

  final focusUsername = FocusNode();
  final focusEmail = FocusNode();
  final focusPassword = FocusNode();

  bool isProcessing = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _backgroundColor = ColorTween(
      begin: const Color(0xFFEBC7E6),
      end: const Color(0xFF645CBB),
    ).animate(_controller);

    //  _textColor = TweenSequence<Color?>(
    //   <TweenSequenceItem<Color?>>[
    //     TweenSequenceItem<Color?>(
    //       tween: ColorTween(
    //         begin: const Color(0xFF4A55A2),
    //         end: const Color(0xFFFFFFFF),
    //       ),
    //       weight: 50,
    //     ),
    //     TweenSequenceItem<Color?>(
    //       tween: ColorTween(
    //         begin: const Color(0xFFFFFFFF),
    //         end: const Color(0xFF4A55A2),
    //       ),
    //       weight: 50,
    //     ),
    //   ],
    // ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        focusUsername.unfocus();
        focusEmail.unfocus();
        focusPassword.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4A55A2)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            'Sign Up',
            style: TextStyle(
                color: Color(0xFF4A55A2), fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (BuildContext context, Widget? child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _backgroundColor.value ?? Color(0xFFEBC7E6),
                    _backgroundColor.value ?? Color(0xFF645CBB)
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50.0),
                      const Text(
                        'Sign up to start\nlistening.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 25.0),

                      // SvgPicture.asset(
                      //   'assets/undraw_music_re_a2jk.svg',
                      //   height: 200,
                      // ),

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
                              decoration: kTextFieldDecoration.copyWith(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Username",
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
                              controller: emailTextController,
                              focusNode: focusEmail,
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
                              controller: passwordTextController,
                              focusNode: focusPassword,
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
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32.0),
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
                                                name:
                                                    usernameTextController.text,
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
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.white,
                                              onPrimary: Color(0xFF4A55A2),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 10.0,
                                                  horizontal: 20.0)),
                                          child: const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                            // child: const Text(
                                            //   'Sign Up',
                                            //   style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
