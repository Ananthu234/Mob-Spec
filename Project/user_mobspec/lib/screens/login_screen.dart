import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>_LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
body: Form(
          child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(color: const Color.fromARGB(255, 20, 216, 138)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "LoginScreen",
                style: TextStyle(fontSize: 24),
              ),
              Container(
                width: 300,
                height: 250,
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 0, 10, 14),
                    borderRadius: BorderRadius.circular(30)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      
                      SizedBox(
                        height: 15,
                      ),
                      
                      
                      TextFormField(
                         
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Enter your email",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                     
                      TextFormField(
                        
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Enter your pass",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(
                        height: 15,
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
                         ();
                      }, child: Text("login")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}