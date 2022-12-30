
import 'package:bolita_cubana/routes/route_generator.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Bienvenido"),
      ),
      body: Ventana(size: size),
    );
  }
}

class Ventana extends StatelessWidget {
  const Ventana({
    Key? key,
    required this.size,
  }) : super(key: key);

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  child: Text("Iniciar sesion"),
                  onPressed: (){
                    Navigator.of(context).pushNamed(Routes.login);
                  },
                )
              ),

            ],
          ),
        ),
      ),
    );
  }
}
