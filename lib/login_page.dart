import 'package:chatappv2/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController emailcontroller;
  late TextEditingController passwordcontroller;
  late String error;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    emailcontroller = TextEditingController();
    passwordcontroller = TextEditingController();
    error = "";
  }

  @override
  void dispose() {
    emailcontroller.dispose();
    passwordcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[300],
      body: SafeArea(
        // ignore: prefer_const_literals_to_create_immutables
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // ignore: prefer_const_literals_to_create_immutables
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey[100],
                  maxRadius: 100,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const Text(
                  'Tara Usap!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    " instant messaging chat application",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                // const Text('developed by Peña'),
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: validateEmail,
                        controller: emailcontroller,
                        decoration: const InputDecoration(
                          labelText: 'Enter Email',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: TextFormField(
                        validator: validatePassword,
                        controller: passwordcontroller,
                        obscureText: _isObscure,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Enter Password',
                          suffixIcon: IconButton(
                              icon: Icon(
                                !_isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isObscure = !_isObscure;
                                });
                              }),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
                  child: GestureDetector(
                    onTap: () {
                      signIn();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Center(
                          child: Text(
                        "Sign In",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      )),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    const Text('Not a member? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Register(),
                          ),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text(' now')
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: Colors.red,
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

  String? validatePassword(String? formPassword) {
    if (formPassword == null || formPassword.isEmpty) {
      return 'Password is required';
    } else if (formPassword.length < 6) {
      return 'Password should atleast be 6 characters';
    } else if (formPassword.length > 12) {
      return 'Password must only be 12 characters';
    }

    return null;
  }

  String? validateEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return 'Email address is required';
    } else if (!formEmail.contains('@gmail.com')) {
      return 'Email badly formatted';
    }

    return null;
  }

  Future signIn() async {
    showDialog(
      context: context,
      useRootNavigator: false,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text.trim(),
        password: passwordcontroller.text.trim(),
      );
      setState(() {
        error = "";
      });
    } on FirebaseAuthException catch (e) {
      // ignore: avoid_print
      print(e);
      setState(() {
        error = e.message.toString();
      });
    }
    // ignore: use_build_context_synchronously
    if (error == '') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: const Duration(seconds: 1),
          content: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                "Logged in as ${emailcontroller.text}",
              ),
              const Icon(
                Icons.check,
                color: Colors.green,
              )
            ],
          )));
    }
    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }
}
