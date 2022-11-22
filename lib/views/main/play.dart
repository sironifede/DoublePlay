import 'package:bolita_cubana/filters/filters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../models/models_manager.dart';
import 'dart:math';

import '../../models/play.dart';
import '../../routes/route_generator.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key,}): super(key: key);
  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {

  bool loading = false;
  late ModelsManager mm;

  final ScrollController _scrollDayController = ScrollController();
  final ScrollController _scrollNightController = ScrollController();
  List<int> scrollableNumbers = [0, 100, 200, 300, 400, 500, 600, 700, 800, 900, 999];


  List<int> dayNumbers = [for (var i = 1; i <= 999; i++) i];
  List<int> nightNumbers = [for (var i = 1; i <= 999; i++) i];


  bool dayNumberPicked = false;
  bool nightNumberPicked = false;
  bool betNumberPicked = false;
  bool random = false;


  var simplePlayLabel = "Jugada Sencilla";
  var doublePlayLabel = "Jugada Doble";

  var _isVisible = false;

  @override
  initState() {
    super.initState();
    mm = context.read<ModelsManager>();
    Future.delayed(Duration(milliseconds: 1),() async{
      if (!mm.firstPlay){
        setState(() {
          mm.firstPlay = false;
          if (mm.play.type == PlayType.JSA || mm.play.type == PlayType.JDA){
            random = true;
          }
          dayNumberPicked = true;
          nightNumberPicked = true;
          betNumberPicked = true;
        });

      }else{
        mm.updateDisabledNumbers();
        mm.updateDisabledBets();
      }
    });
  }
  List prices = [5, 10, 15, 20, 25, 30, 40, 50, 100, 200, 300];
  List<Widget> getPrices() {
    var list = <Widget>[];
    for (var price in prices) {
      int spBet = 0;
      int dpBet = 0;
      for (var play in mm.plays){
        if (play.padlock.id == mm.padlock.id) {

          if (play.confirmed) {

            if (play.type == PlayType.JS || play.type == PlayType.JSA) {
              spBet += play.bet;
            } else {
              dpBet += play.bet;
            }
          }
        }
      }

      int maxBet = 300;
      int totalBet = dpBet;
      if (mm.play.type == PlayType.JS || mm.play.type == PlayType.JSA){
        maxBet = 200;
        totalBet = spBet;
      }
      //print("totalBet: ${totalBet}");
      if (price + totalBet <= maxBet) {
        list.add(
            OutlinedButton(
                onPressed: () {
                  if (price != mm.play.bet) {
                    setState(() {
                      mm.play.bet = price;
                      betNumberPicked = true;
                    });
                  } else {
                    setState(() {
                      mm.play.bet = 0;
                      betNumberPicked = false;
                    });
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: (price == mm.play.bet && betNumberPicked) ? Colors.green : Colors.black,
                  minimumSize: Size.zero, // Set this
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
                child: Text("$price",
                  style: TextStyle(color: Colors.white),
                )));
      }
    }
    return list;
  }

  getRandomNumbers()
  {

    List a=[];
    var rng = Random();
    for (var i = 0; i < 6; i++) {
      a.add(rng.nextInt(9));
      // print();
    }
    _isVisible = true;
    dayNumberPicked = false;
    nightNumberPicked = false;
    random = true;
    mm.play.dayNumber = a[0]*100 + a[1]*10 + a[2];
    mm.play.nightNumber = a[3]*100 + a[4]*10 + a[5];
    mm.play.type = (mm.play.type == PlayType.JD || mm.play.type == PlayType.JDA)? PlayType.JDA: PlayType.JSA;
    if (mm.padlock.id != mm.play.padlock.id){
      mm.createPlay(model: mm.play).then((value) {
        setState(() {
          double toOffset = mm.play.dayNumber * 60;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollDayController.animateTo(
                toOffset,
                duration: Duration(seconds: 3),
                curve: Curves.easeIn
            );
          });
          toOffset = mm.play.nightNumber * 60;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollNightController.animateTo(
                toOffset,
                duration: Duration(seconds: 3),
                curve: Curves.easeIn
            ).then((value) {
              setState(() {
                dayNumberPicked = true;
                nightNumberPicked = true;
                _isVisible = false;
              });
            });
          });
        });
      });
    }else {
      mm.updatePlay(model: mm.play).then((value) {
        setState(() {
          double toOffset = mm.play.dayNumber * 60;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollDayController.animateTo(
                toOffset,
                duration: Duration(seconds: 3),
                curve: Curves.easeIn
            );
          });
          toOffset = mm.play.nightNumber * 60;
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _scrollNightController.animateTo(
                toOffset,
                duration: Duration(seconds: 3),
                curve: Curves.easeIn
            ).then((value) {
              setState(() {
                dayNumberPicked = true;
                nightNumberPicked = true;
                _isVisible = false;
              });
            });
          });
        });
      });
    }

  }

  resetScreen(){
    dayNumberPicked = false;
    nightNumberPicked = false;
    betNumberPicked = false;
    random = false;
    mm.updateDisabledNumbers();
    mm.updateDisabledBets();
    mm.updatePadlocks();
  }


  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);
    if (mm.showActiveAppDialog){
      mm.showActiveAppDialog = false;
      Future.delayed(Duration(milliseconds: 1), () {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text(
                    "La aplicacion no esta habilitada, se podra usar cuando un administrador la habilite."),
                content: Text(
                    "La aplicacion se cerro a las: ${mm.app.stopHour.format(
                        context)}"),
                actions: [
                  TextButton(
                    child: Text("CERRAR SESION"),
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    child: Text("ACEPTAR"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              );
            }).then((value) {
          if (value != null){
            if (value){
              mm.user = User();
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
            }
          }else{
            SystemNavigator.pop();
          }
        });
      });
    }



    for (var j in mm.disabledBets) {
      if (j.month == mm.padlock.month) {
        prices = prices.toSet().difference(j.betNumbers.toSet()).toList();
        break;
      }
    }


    for (var i in mm.disabledNumbers) {
      if (i.month == mm.padlock.month) {
        if (mm.padlock.playing) {
          dayNumbers =
              dayNumbers.toSet().difference(i.dayNumbers.toSet()).toList();
          nightNumbers =
              nightNumbers.toSet().difference(i.nightNumbers.toSet()).toList();
          for (var i in mm.plays) {
            if (i.confirmed) {
              if (mm.padlock.id == i.padlock.id) {
                dayNumbers.remove(i.dayNumber);
                nightNumbers.remove(i.nightNumber);
              }
            }
          }
          break;
        }
      }
    }






    return Scaffold(
      appBar: AppBar(
        title: CustomTextButton(
          label: "${(mm.play.type == PlayType.JS || mm.play.type == PlayType.JSA)? simplePlayLabel: doublePlayLabel}${ (random)? " Aleatoria": "" }",
          onPressed: (random)? null:() {
            setState(() {
              mm.play.type = (random)?(mm.play.type == PlayType.JS)? PlayType.JD:PlayType.JS: (mm.play.type == PlayType.JSA)? PlayType.JDA:PlayType.JSA ;
            });
          },
          backgroundColor: Colors.black54,
        ),
        centerTitle: true,
        elevation: 1,

        actions: [
          InkWell(child: Image.asset(
            'assets/gifs/dice_rolling.gif', height: 60, width: 60,color: Colors.red,colorBlendMode: BlendMode.modulate),
            onTap:(){
              if (mm.play.nRandom >= 3 || getPrices().isEmpty) {

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("No puedes realizar mas jugadas aleatorias.")),
                );
              }else{
                getRandomNumbers();
              }
            },
          )
        ],
      ),

      body: (loading)?LinearProgressIndicator(): Stack(
        children: [
          Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                (!random)? Text(""):ListTile(
                  title: Text("Intentos restatnes de la jugada aleatoria: ${3 - mm.play.nRandom}"),
                ),
                SizedBox(
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(child: Row(
                        children: [
                          Image.asset('assets/images/sun.png'),
                          (dayNumberPicked)? Text(""):IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () async {
                              double toOffset = 0;
                              for (int i = 1; i < scrollableNumbers.length; i ++){
                                if (_scrollDayController.offset /60 > scrollableNumbers[i]){
                                  toOffset = scrollableNumbers[i] * 60;
                                }
                              }
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                _scrollDayController.jumpTo(
                                  toOffset,
                                );
                              });
                            },
                          ),
                          (dayNumberPicked)? Text(""):IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () async {
                              double toOffset = 900;
                              for (int i = 1; i < scrollableNumbers.length; i ++){
                                if (_scrollDayController.offset /60 < scrollableNumbers[i]){
                                  toOffset = scrollableNumbers[i] * 60;
                                  break;
                                }
                              }
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                _scrollDayController.jumpTo(
                                  toOffset,
                                );
                              });
                            },
                          ),
                        ],
                      )),
                      const SizedBox(
                        width: 16,
                      ),
                      Center(child: Row(
                        children: [
                          Image.asset('assets/images/moon.png',height: 100,),
                          (nightNumberPicked)? Text(""):IconButton(
                            icon: Icon(Icons.arrow_upward),
                            onPressed: () async {
                              double toOffset = 0;
                              for (int i = 1; i < scrollableNumbers.length; i ++){
                                if (_scrollNightController.offset /60 > scrollableNumbers[i]){
                                  toOffset = scrollableNumbers[i] * 60;
                                }
                              }
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                _scrollNightController.jumpTo(
                                  toOffset,
                                );
                              });
                            },
                          ),
                          (nightNumberPicked)? Text(""):IconButton(
                            icon: Icon(Icons.arrow_downward),
                            onPressed: () async {
                              double toOffset = 900;
                              for (int i = 1; i < scrollableNumbers.length; i ++){
                                if (_scrollNightController.offset /60 < scrollableNumbers[i]){
                                  toOffset = scrollableNumbers[i] * 60;
                                  break;
                                }
                              }
                              SchedulerBinding.instance.addPostFrameCallback((_) {
                                _scrollNightController.jumpTo(
                                  toOffset,
                                );
                              });
                            },
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          dayNumberPicked
                              ? Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.black,
                              child: Container(
                                color: Colors.red,
                                child: ListTile(
                                  focusColor: Colors.red.shade900,
                                  title: Center(
                                      child: Text(
                                        "${mm.play.dayNumber.toString().padLeft(3, '0')}",
                                        style: const TextStyle(fontSize: 40),
                                      )
                                  ),
                                  onTap: () {
                                    if (!random) {
                                      setState(() {
                                        dayNumberPicked = false;
                                      });
                                    }
                                  },
                                ),
                              )
                            ),
                          )
                              : Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.black,
                              child: ListView.separated(
                                controller: _scrollDayController,
                                shrinkWrap: true,
                                // Let the ListView know how many items it needs to build.
                                itemCount: dayNumbers.length,
                                // Provide a builder function. This is where the magic happens.
                                // Convert each item into a widget based on the type of item it is.
                                itemBuilder: (context, i) {
                                  return Container(
                                    color: Colors.red,
                                    child: ListTile(
                                      focusColor: Colors.red.shade900,
                                      title: Center(
                                          child: Text(
                                              "${dayNumbers[i].toString().padLeft(3, '0')}",
                                              style: const TextStyle(fontSize: 40)
                                          )
                                      ),
                                      onTap: () {
                                        if (!random) {
                                          setState(() {
                                            dayNumberPicked = true;
                                            mm.play.dayNumber = dayNumbers[i];
                                          });
                                        }
                                      },
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider(
                                    color: Colors.black,
                                    height: 4,
                                    thickness: 4,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          nightNumberPicked
                              ? Expanded(
                            child: Container(
                                padding: const EdgeInsets.all(5),
                                color: Colors.black,
                                child: Container(
                                  color: Colors.blue,
                                  child: ListTile(
                                    focusColor: Colors.blue.shade900,
                                    title: Center(
                                        child: Text(
                                          "${mm.play.nightNumber.toString().padLeft(3, '0')}",
                                          style: const TextStyle(fontSize: 40),
                                        )
                                    ),
                                    onTap: () {
                                      if (!random) {
                                        setState(() {
                                          nightNumberPicked = false;
                                        });
                                      }
                                    },
                                  ),
                                )
                            ),
                          )
                              : Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.black,
                              child: ListView.separated(
                                controller: _scrollNightController,
                                shrinkWrap: true,
                                // Let the ListView know how many items it needs to build.
                                itemCount: nightNumbers.length,
                                // Provide a builder function. This is where the magic happens.
                                // Convert each item into a widget based on the type of item it is.
                                itemBuilder: (context, i) {
                                  return Container(
                                    color: Colors.blue,
                                    child: ListTile(
                                      focusColor: Colors.blue.shade900,
                                      title: Center(
                                          child: Text(

                                            "${nightNumbers[i].toString().padLeft(3, '0')}",
                                            style: const TextStyle(fontSize: 40),
                                          )),
                                      onTap: () {
                                        if (!random) {
                                          setState(() {
                                            nightNumberPicked = true;
                                            mm.play.nightNumber = nightNumbers[i];
                                          });
                                        }
                                      },
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const Divider(
                                    color: Colors.black,
                                    height: 4,
                                    thickness: 4,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text("Apuesta:"),
                  subtitle: Wrap(
                    spacing: 2.0,
                    children: getPrices(),
                    alignment: WrapAlignment.spaceBetween,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () async {
                              if(dayNumberPicked && nightNumberPicked && betNumberPicked){
                                mm.play.padlock = mm.padlock;
                                mm.play.confirmed = true;
                                if (random){
                                  mm.updatePlay(model: mm.play).then((value) {
                                    mm.play = Play(padlock: Padlock(id: 0, user: mm.user));
                                    resetScreen();
                                  });
                                }else{
                                  mm.createPlay(model: mm.play).then((value) {
                                    mm.play = Play(padlock: Padlock(id: 0, user: mm.user));
                                    resetScreen();
                                  });
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Terminaste tu jugada")),
                                );
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Debe seleccionar los dos numeros y la apuesta")),
                                );
                              }
                            },
                            child: const Text("Confirmar jugada y seguir jugando"),
                        ),
                      ),
                    ),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () async {
                              if((dayNumberPicked && nightNumberPicked && betNumberPicked) || (getPrices().isEmpty)){
                                mm.padlock.playing = false;
                                if (getPrices().isNotEmpty) {
                                  mm.play.confirmed = true;
                                  if (random) {
                                    await mm.updatePlay(model: mm.play);
                                  } else {
                                    await mm.createPlay(model: mm.play);
                                  }
                                }
                                mm.updatePadlock(model: mm.padlock).then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("Terminaste tu jugada")),
                                  );
                                  Navigator.of(context).pushNamedAndRemoveUntil(Routes.padlock, (Route<dynamic> route) => false);
                                });
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Debe seleccionar los dos numeros y la apuesta")),
                                );
                              }
                            },
                            child: const Text("Confirmar Jugada"),
                        ),
                      ),
                    ),
                  ],
                ),
              ]
          ),
          Visibility(
            visible: _isVisible,
            child: Container(
                color: Colors.black54,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                    child: Image.asset('assets/gifs/dice_rolling.gif', height: 60, width: 60,color: Colors.red,colorBlendMode: BlendMode.modulate),
                )
            ),
          ),
        ],
      ),
    );
  }

}
class CustomTextButton extends StatelessWidget {
  final String label;
  final Function()? onPressed;
  final Color? backgroundColor;
  final bool? enabled;
  final Color? textColor;

  CustomTextButton({
    this.label = '',
    this.onPressed,
    this.textColor,
    this.enabled,
    this.backgroundColor,

  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor?.withOpacity(1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
      ),
      onPressed: enabled??true?onPressed:null,
      child: Row(mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label",
            style: TextStyle(
              fontSize: 16.0,
              color: textColor ?? (enabled??true
                  ? Colors.white
                  : Colors.white54),
            ),
          ),
        ],
      ),
    );
  }
}
