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
import '../shimmer.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key,}): super(key: key);
  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {

  bool loading = false;
  bool update = false;
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
      await mm.updatePadlocks(filter: PadlockFilter(month: mm.padlock.month.toString()));
      mm.plays = [];
      List<int> padlocks = [];
      for (var padlock in mm.padlocks) {
        padlocks.add(padlock.id);
      }
      mm.updatePlays(filter: PlayFilter(padlocks: padlocks),loadMore: true);
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
  resetScreen() async{
    dayNumberPicked = false;
    nightNumberPicked = false;
    betNumberPicked = false;
    random = false;

    _refresh();
  }
  Future<void> _refresh() async {
    await mm.updatePadlocks(filter: PadlockFilter(month: mm.padlock.month.toString()));
    mm.plays = [];
    await mm.updatePlays(filter: PlayFilter(month: mm.padlock.month.toString(),padlocks: [mm.padlock.id]),);
    mm.updateDisabledNumbers();
    mm.updateDisabledBets();
  }

  List prices = [5, 10, 15, 20, 25, 30, 40, 50, 100, 200];
  List<Widget> getPrices() {
    var list = <Widget>[];
    int bet = 0;
    if (dayNumberPicked && nightNumberPicked){
      int cant = 0;
      for (var play in mm.plays){
        if (mm.play.nightNumber == play.nightNumber && mm.play.dayNumber == play.dayNumber){
          print("${play.toUpdateMap()}");
          bet += play.bet;
        }
        if (mm.play.dayNumber == play.nightNumber && mm.play.nightNumber == play.dayNumber && [PlayType.JDA,PlayType.JD].contains(play.type)){
          print("${play.toUpdateMap()}");
          bet += play.bet;
        }
        if (mm.play.dayNumber == play.nightNumber && mm.play.nightNumber == play.dayNumber && [PlayType.JSA,PlayType.JS].contains(play.type) && [PlayType.JDA,PlayType.JD].contains(mm.play.type)){
          print("${play.toUpdateMap()}");
          bet += play.bet;
        }
      }
    }
    int sub = 0;
    if ([PlayType.JDA,PlayType.JD].contains(mm.play.type)){
      sub = 100;
    }
    print(bet);
    for (var price in prices) {

      if ((bet + price - sub) <= 100 ) {
        if (([PlayType.JDA,PlayType.JD].contains(mm.play.type) && price == 200) || ![PlayType.JDA,PlayType.JD].contains(mm.play.type) && price != 200) {
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
                        mm.play.bet = 1;
                        betNumberPicked = false;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: (price == mm.play.bet && betNumberPicked)
                        ? Colors.green
                        : Colors.black,
                    minimumSize: Size.zero, // Set this
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  ),
                  child: Text("\$$price",
                    style: TextStyle(color: Colors.white),
                  )
              )
          );
        }
      }
    }
    return list;
  }

  void getRandomNumbers()
  {

    _isVisible = true;
    dayNumberPicked = false;
    nightNumberPicked = false;
    random = true;
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

  Future<void> updatePlays() async{
    update = false;
    await mm.updatePlays(filter: PlayFilter(dayNumber: mm.play.dayNumber.toString(),nightNumber: mm.play.nightNumber.toString(),month: mm.padlock.month.toString(),confirmed: true),loadMore: true);
    await mm.updatePlays(filter: PlayFilter(dayNumber: mm.play.nightNumber.toString(),nightNumber: mm.play.dayNumber.toString(),month: mm.padlock.month.toString(),confirmed: true),loadMore: true);
  }

  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);
    if (mm.user.userStatus == UserStatus.unauthorized){
      mm.user.userStatus = UserStatus.unauthenticated;
      Future.delayed(Duration(milliseconds:1), (){
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text("Tu usuario ha sido deshabilitado o eliminado no puedes acceder a la app hasta que se te permita por un admin."),
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
            }).then((value){
          if (value != null){
            if (value){
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
            }
          }else{
            SystemNavigator.pop();
          }
        });
      });
    }else if (mm.user.userStatus == UserStatus.appNotActive) {
      mm.user.userStatus = UserStatus.unauthenticated;
      Future.delayed(Duration(milliseconds: 1), () {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                icon: const Icon(Icons.warning),
                title: Text(
                    "La aplicacion no esta habilitada, se podra usar cuando un administrador la habilite."),
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
              Navigator.of(context).pushNamedAndRemoveUntil(Routes.welcome, (Route<dynamic> route) => false);
            }
          }else{
            SystemNavigator.pop();
          }
        });
      });
    }

    if (!random && dayNumberPicked && nightNumberPicked && update){
      Future.delayed(Duration(milliseconds: 1),(){
        updatePlays();
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
          break;
        }
      }
    }
    if (random){
      if (mm.play.type == PlayType.JS){
        mm.play.type = PlayType.JSA;
      }
      if (mm.play.type == PlayType.JD){
        mm.play.type = PlayType.JDA;
      }
    }else{
      if (mm.play.type == PlayType.JSA){
        mm.play.type = PlayType.JS;
      }
      if (mm.play.type == PlayType.JDA){
        mm.play.type = PlayType.JD;
      }
    }


    return Scaffold(
      appBar: AppBar(
        leading: (getCurrentPlayLength() == 0)?IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          onPressed: (){
            mm.removePadlock(model: mm.padlock);
            mm.showContinuePlayingDialog = false;
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (Route<dynamic> route) => false);
          },
        ): null,
        title: CustomTextButton(
          label: "${(mm.play.type == PlayType.JS || mm.play.type == PlayType.JSA)? simplePlayLabel: doublePlayLabel}${ (random)? " Aleatoria": "" }",
          onPressed: (random)? null:() {
            setState(() {

              betNumberPicked = false;
              if (mm.play.type == PlayType.JS){
                mm.play.type = PlayType.JD;
              }else {
                if (mm.play.type == PlayType.JD) {
                  mm.play.type = PlayType.JS;
                }
              }

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
              if (mm.play.nRandom >= 3) {
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

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Shimmer(
          child: ShimmerLoading(
            isLoading: loading,
            child: Stack(
              children: [
                ListView(

                    children: [
                      (!random)? Text(""):ListTile(
                        title: Text("Intentos restatnes de la jugada aleatoria: ${3 - mm.play.nRandom}"),
                      ),
                      ListTile(
                        title: Text("Cantidad de jugadas: ${getCurrentPlayLength()} de 10 jugadas"),
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
                      SizedBox(
                        height: 500,
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
                                                  update = true;
                                                  betNumberPicked = false;
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
                                                  update = true;
                                                  betNumberPicked = false;
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
                                  onPressed: (getCurrentPlayLength() < 9 && (dayNumberPicked && nightNumberPicked && betNumberPicked))? () async {

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

                                  }: null,
                                  child: const Text("Confirmar jugada y seguir jugando"),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                  onPressed: ((dayNumberPicked && nightNumberPicked && betNumberPicked) || (getPrices().isEmpty && (getCurrentPlayLength() == 9 && !random)))?() async {

                                    mm.padlock.playing = false;
                                    if (getPrices().isNotEmpty ) {
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
                                      Future.delayed(Duration(milliseconds: 1), (){
                                        Navigator.of(context).pushNamedAndRemoveUntil(Routes.padlock, (Route<dynamic> route) => false);
                                      });
                                    });

                                  }: null,
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
          ),
        ),
      ),
    );

  }
  int getCurrentPlayLength(){
    int length = 0;
    for (var play in mm.plays ){
      if (play.padlock.id == mm.padlock.id){
        length++;
      }
    }
    return length;
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
class Plays{
  Plays({
    required dayNumber,
    required nightNumber,
    required bet,
    required type
  });
  int dayNumber = 0;
  int nightNumber = 0;
  int bet = 0;
  PlayType type = PlayType.JD;
}
