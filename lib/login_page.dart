import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'main.dart';
import 'dart:ui';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        await context
            .read<AuthService>()
            .login(_emailController.text, _passwordController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login bem sucedido'),
          ),
        );
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    HomePage(email: _emailController.text, selectedIndex: 1)));
      } on AuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/backLogPage.jpg'),
                fit: BoxFit.fitHeight,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/IPC-PRETO.png',
                width: MediaQuery.of(context).size.width * 0.5,
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor insira o email';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Por favor insira a senha';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _login,
                              child: Text('Iniciar sessão'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
