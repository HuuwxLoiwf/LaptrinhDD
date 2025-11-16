import 'package:flutter/material.dart';
import 'package:twitterclone/components/my_button.dart';
import 'package:twitterclone/components/my_loading_circle.dart';
import 'package:twitterclone/components/my_text_field.dart';
import 'package:twitterclone/services/auth/auth_service.dart';
import 'package:twitterclone/services/database/database_service.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // acess
  final _auth = AuthService();
  final _db = DatabaseService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  void register() async {
    // Kiểm tra mật khẩu
    if (pwController.text == confirmPwController.text) {
      showLoadingCircle(context);

      //attempt
      try {
        await _auth.registerEmailPassword(
          emailController.text,
          pwController.text,
        );
        if (mounted) hideLoadingCircle(context);

        await _db.saveUserInfoFirebase(
          name: nameController.text,
          email: emailController.text,
        );

        //btw
      }
      //
      catch (e) {
        if (mounted) hideLoadingCircle(context);

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(title: Text(e.toString())),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: Text("Passwords don't match")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Center(
              child: Icon(
                Icons.lock_open_rounded,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),

            const SizedBox(height: 50),
            Text(
              "Let's create an account for you",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 25),
            MyTextField(
              controller: nameController,
              hintText: "Enter name..",
              obscureText: false,
            ),

            const SizedBox(height: 10),
            MyTextField(
              controller: emailController,
              hintText: "Enter email..",
              obscureText: false,
            ),

            const SizedBox(height: 10),
            MyTextField(
              controller: pwController,
              hintText: "Enter password..",
              obscureText: true,
            ),

            const SizedBox(height: 10),
            MyTextField(
              controller: confirmPwController,
              hintText: "Confirm password..",
              obscureText: false,
            ),

            const SizedBox(height: 45),

            MyButton(text: "Register", onTap: register),

            const SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already a member?",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text(
                    "Login now",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
