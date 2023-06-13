  import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final senha = TextEditingController();

  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;
  late Image imagem;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  setFormAction(bool acao) {
    setState(() {
      isLogin = acao;
      if (isLogin) {
        titulo = 'Bem-vindo ao "InforDocente"';
        actionButton = 'Entrar';
        toggleButton = 'Ainda não tem conta? Registe-se agora.';
        imagem = Image.asset('images/ipc.png');
      } else {
        titulo = 'Crie sua conta';
        actionButton = 'Registar';
        toggleButton = 'Voltar ao Login.';
        imagem = Image.asset('images/login.png');
      }
    });
  }

  
login() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  registar() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().registar(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar:PreferredSize(
        preferredSize: Size.fromHeight(100.0),
        child: Container(
          decoration: 
            BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/IPC-PRETO.png'),
                fit: BoxFit.fitHeight,
        ),
      ),
  ),),
        
      body: Wrap(
        alignment: WrapAlignment.spaceBetween,
        children: [
            Form(
            key: formKey,
            child: 
              Container(
                padding: EdgeInsets.symmetric(horizontal: width *0.05,vertical: height*0.05),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("/images/backLogPage.jpg"), 
                      scale: 1,
                      fit: BoxFit.fitWidth),    
                      
                ),
                child:
                  Wrap(
                    alignment: WrapAlignment.center,
                    children:[
                    Padding(
                      padding: EdgeInsets.only(top: width *0.1),
                      child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              titulo,
                              style: TextStyle(
                                fontSize: 45,
                                //fontWeight: FontWeight.bold,
                                letterSpacing: -1.5,
                                color: Colors.white,
                              ),
                            )])),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: width *0.2,vertical: height*0.1),
                        child: 
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        TextFormField(
                          controller: email,
                          decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        filled: true,
                                        fillColor: Color.fromARGB(255, 233, 247, 171),
                                        labelText: 'Email',
                                      ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Introduzir o email corretamente!';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20,),
                        TextFormField(
                          controller: senha,
                          obscureText: true,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Color.fromARGB(255, 233, 247, 171),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.grey,
                              ),
                            ),
                            labelText: 'Senha',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Introduza senha!';
                            } else if (value.length < 6) {
                              return 'A senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: width *0.1,vertical: height*0.05),
                          child: 
                            ElevatedButton(
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.grey)),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  if (isLogin) {
                                    login();
                                  } else {
                                    registar();
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: (loading)
                                  ? [
                                    Wrap(
                                      children:[
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                  ])
                                  ]
                                : [
                                      Icon(Icons.check),
                                      Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: 
                                          Text(
                                          actionButton,
                                          style: TextStyle(fontSize: 20),
                                          ),)]
                                    ),
                          ),
                        ),
                      TextButton(
                        onPressed: () => setFormAction(!isLogin),
                        child: Text(toggleButton),
                        
                      ),
        ]))],
            ),
          ),
        ),
    ])
    );
  }
}