import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Ayuda"),
        ),
        body:SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ExpansionTile(
                    title: Text("1. COMO SE JUEGA "),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Se compra una jugada "
                          "compuesta de un candado de 2 centenas.[pick 3] la de "
                          "la mañana y la de la noche la cual es valida por 31día si la "
                          "compras el día 1 del mes sino es valida por los diasrestantes "
                          "del mes dependiendo del día que la compres."),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text("2. COMO SE GANA"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Acierta las 2 centenas del candado combinacion que "
                          "jugastes no importa en el orden entre elorden entre el dia y la "
                          "noche que salga la centena."),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text("3- CUANTO VALE LA JUGADA"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("El valor de la jugada es de un minimo de \$15 con "
                          "una limitacion de \$100 si elegiste jugada doble y de \$200 si elegiste jugada simple."),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text("4- CUANTO SE PAGA POR JUGADA"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Se paga en los premios diarios 500 x 1 y en el fin de "
                          "mes que es el premio mayor 5000 x 1 ejemplo si compras la jugada "
                          "de \$50 Puedes ganar diario 25,000 y el premio mayor 250,000 "
                          "y si Compras la jugada de \$100 puedos ganar diario 50,000 y"
                          " esta la opcion de la doble jugada [ DOUBLE PLAY ] que seria \$200 "
                          "el valor de la jugada y puedes ganar diario 100,000 y el premio mayor sería 1,000,000."),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text("5- QUE PASA SI GANO Y NO ENCUENTRO EL LISTERO PARA COBRAR"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Si resultaras ganador se te notíficara por la aplicacion la cual "
                          "confirmastes tu jugada el día que la comprastes por esta razon es "
                          "muy importante que confirmes tu jugada con nosotros por medio"
                          "de la aplicacion."),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text("6- CUANTOS DIAS ES VALIDA MI JUGADA"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Las jugadas que compres puede ser valida por todo el mes solamente en el caso que "
                          "la compres el mes anterior o el primer dia del mes si la "
                          "compras ya empezado el mes es valida por los dias restantes "
                          "del mes en curso, porque el ultimo día del mes se dara el premio mayor."),
                    )
                  ],
                ),
                ExpansionTile(
                  title: Text("7- QUE PASA SI DE LAS 2 CENTENAS QUE JUEGUE SOLO SALE 1"),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Si de las 2 centenas que jugastes solo sale 1 no ganas, solo "
                          "ganarias si aciertas las 2 centenas del día."),
                    )
                  ],
                ),
              ]
          ),
        )
    );
  }
}
