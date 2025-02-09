import 'package:admin/dashboard.dart';
import 'package:admin/main.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email=TextEditingController();
  final TextEditingController _password=TextEditingController();
  void signin()async{
    try {
      String email=_email.text;
      String Password=_password.text;
      final AuthResponse res = await supabase.auth.signInWithPassword(
  email: email,
  password: Password,
);
print("sign-in succesfull");
final User? user = res.user;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error during sign-in.Please try agiain")),
      );
      print("Error");
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
          child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: const Color.fromARGB(255, 97, 235, 159)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Login",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                width: 600,
                height: 400,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 1, 11, 16),
                    borderRadius: BorderRadius.circular(60)),
                child: Column(
                  children: [
                    Column(
                      children: [],
                    ),
                    SizedBox(
                      height: 90,
                    ),
                    Text("Email"),
                    TextFormField(
                      controller: _email,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter your email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text("Password"),
                    TextFormField(
                      controller: _password,
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        hintText: "Enter your pass",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    // ElevatedButton(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (context) => Dashboard(),
                    //         ),
                    //       );
                    //     },
                    //     child: Text("Sign In")),
                    ElevatedButton(onPressed: (){
                      signin();
                    }, child: Text("sigin")),
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}