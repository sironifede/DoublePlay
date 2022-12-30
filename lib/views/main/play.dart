import 'package:bolita_cubana/filters/filters.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
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
      if (!mm.newPlay){
        if (mm.selectedPlay!.type == PlayType.JSA || mm.selectedPlay!.type == PlayType.JDA) {
          setState(() {
            random = true;
            dayNumberPicked = true;
            nightNumberPicked = true;
            betNumberPicked = true;
          });
        }else{
          setState(() {
            random = false;
            dayNumberPicked = false;
            nightNumberPicked = false;
            betNumberPicked = false;
          });
        }
      }
      _refresh();
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
    if (!mm.newPlay){
      await mm.updateModels(filter: PadlockFilter(users: [mm.user.id],playing: true), modelType: ModelType.padlock);
      for (var padlock in mm.padlocks){
        if (padlock.user == mm.user.id){
          if (padlock.playing){
            mm.selectedPadlock = padlock;
            break;
          }
        }
      }
      if (mm.selectedPadlock != null) {
        await mm.updateModels(filter: PlayFilter(padlocks: [mm.selectedPadlock!.id]), modelType: ModelType.play);
        for (var play in mm.plays){
          if (play.padlock == mm.selectedPadlock!.id){
            if (!play.confirmed){
              mm.selectedPlay = play;
              if (mm.selectedPlay!.type == PlayType.JSA || mm.selectedPlay!.type == PlayType.JDA) {
                setState(() {
                  random = true;
                  dayNumberPicked = true;
                  nightNumberPicked = true;
                  betNumberPicked = true;
                });
              }
              break;
            }
          }
        }
      }
    }
    mm.updateModels(modelType: ModelType.disabledNumbers);
    mm.updateModels(modelType: ModelType.disabledBets);
  }

  List prices = [5, 10, 15, 20, 25, 30, 40, 50, 100, 200];
  List<Widget> getPrices() {
    var list = <Widget>[];
    int bet = 0;
    if (dayNumberPicked && nightNumberPicked){
      int cant = 0;
      List<int> padlocks = [];
      for (var padlock in mm.padlocks){
        if (padlock.month == mm.selectedPadlock!.month && !padlock.selled) {
          padlocks.add(padlock.id);
        }
      }
      for (var play in mm.plays){
        if (padlocks.contains(play.padlock)) {
          if (play.confirmed) {

            if (mm.selectedPlay!.nightNumber == play.nightNumber &&
                mm.selectedPlay!.dayNumber == play.dayNumber) {
              bet += play.bet;
            }
            if (mm.selectedPlay!.dayNumber == play.nightNumber &&
                mm.selectedPlay!.nightNumber == play.dayNumber &&
                [PlayType.JDA, PlayType.JD].contains(play.type)) {
              bet += play.bet;
            }
            if (mm.selectedPlay!.dayNumber == play.nightNumber &&
                mm.selectedPlay!.nightNumber == play.dayNumber &&
                [PlayType.JSA, PlayType.JS].contains(play.type) &&
                [PlayType.JDA, PlayType.JD].contains(mm.selectedPlay!.type)) {
              bet += play.bet;
            }
          }
        }
      }
    }
    int sub = 0;
    if ([PlayType.JDA,PlayType.JD].contains(mm.selectedPlay!.type)){
      sub = 100;
    }
    print("total bet: $bet");

    for (var price in prices) {

      if ((bet + price - sub) <= 100 ) {
        if (([PlayType.JDA,PlayType.JD].contains(mm.selectedPlay!.type) && price == 200) || ![PlayType.JDA,PlayType.JD].contains(mm.selectedPlay!.type) && price != 200) {
          list.add(
              OutlinedButton(
                  onPressed: () {
                    if (mm.selectedPlay!.bet != price) {
                      setState(() {
                        mm.selectedPlay!.bet = price;
                        betNumberPicked = true;
                      });
                    } else {
                      setState(() {
                        mm.selectedPlay!.bet = 0;
                        betNumberPicked = false;
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: (price == mm.selectedPlay!.bet && betNumberPicked)
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

  void getRandomNumbers() async  {

    _isVisible = true;
    dayNumberPicked = false;
    nightNumberPicked = false;
    random = true;
    if (mm.selectedPlay != null) {
      mm.selectedPlay!.type = (mm.selectedPlay!.type == PlayType.JD || mm.selectedPlay!.type == PlayType.JDA) ? PlayType.JDA : PlayType.JSA;
      if (mm.newPlay){
        mm.newPlay = false;
        mm.selectedPadlock = await mm.createModel( modelType: ModelType.padlock, model: mm.selectedPadlock!) as Padlock;
        mm.selectedPlay!.padlock = mm.selectedPadlock!.id;
        mm.createModel( modelType: ModelType.play, model: mm.selectedPlay!).then((value) {
          mm.selectedPlay = value as Play;
          setState(() {
            dayNumberPicked = true;
            nightNumberPicked = true;
            _isVisible = false;
          });
        });
      }else{
        if (mm.selectedPlay!.padlock != mm.selectedPadlock!.id){
          mm.createModel( modelType: ModelType.play, model: mm.selectedPlay!).then((value) {
            mm.selectedPlay = value as Play;
            setState(() {
              dayNumberPicked = true;
              nightNumberPicked = true;
              _isVisible = false;
            });
          });
        }else{
          mm.updateModel(modelType: ModelType.play, model: mm.selectedPlay!).then((value) {
            mm.selectedPlay = value as Play;
            setState(() {
              dayNumberPicked = true;
              nightNumberPicked = true;
              _isVisible = false;
            });
          });
        }
      }

    }

  }

  Future<void> updatePlays() async{
    update = false;
    ModelOptions modelOptions = await mm.updateModels(modelType: ModelType.play,filter: PlayFilter(selled:false,dayNumber: mm.selectedPlay!.dayNumber.toString(),nightNumber: mm.selectedPlay!.nightNumber.toString(),month: mm.selectedPadlock!.month.toString(),confirmed: true));
    ModelOptions modelOptions2 = await mm.updateModels(modelType: ModelType.play,filter: PlayFilter(selled:false,dayNumber: mm.selectedPlay!.nightNumber.toString(),nightNumber: mm.selectedPlay!.dayNumber.toString(),month: mm.selectedPadlock!.month.toString(),confirmed: true));

    List<Model> models = modelOptions.fetchedModels.models;
    models.addAll(modelOptions2.fetchedModels.models);
    List<int> padlocks = [];
    for (var play in models){
      if (!padlocks.contains((play as Play).padlock)){
        padlocks.add((play as Play).padlock);
      }
    }

    await mm.updateModels(modelType: ModelType.padlock,filter: PadlockFilter(), newList: padlocks);
  }


  Widget build(BuildContext context) {
    mm = context.watch<ModelsManager>();
    loading = (mm.status == ModelsStatus.updating);

    if (!random && dayNumberPicked && nightNumberPicked && update){
      Future.delayed(Duration(milliseconds: 1),(){
        updatePlays();
      });
    }

    for (var j in mm.disabledBets) {
      if (j.month == mm.selectedPadlock!.month) {
        prices = prices.toSet().difference(j.betNumbers.toSet()).toList();
        break;
      }
    }

    for (var i in mm.disabledNumbers) {
      if (i.month == mm.selectedPadlock!.month) {
        if (mm.selectedPadlock!.playing) {
          dayNumbers =
              dayNumbers.toSet().difference(i.dayNumbers.toSet()).toList();
          nightNumbers =
              nightNumbers.toSet().difference(i.nightNumbers.toSet()).toList();
          break;
        }
      }
    }
    if (random){
      if (mm.selectedPlay!.type == PlayType.JS){
        mm.selectedPlay!.type = PlayType.JSA;
      }
      if (mm.selectedPlay!.type == PlayType.JD){
        mm.selectedPlay!.type = PlayType.JDA;
      }
    }else{
      if (mm.selectedPlay!.type == PlayType.JSA){
        mm.selectedPlay!.type = PlayType.JS;
      }
      if (mm.selectedPlay!.type == PlayType.JDA){
        mm.selectedPlay!.type = PlayType.JD;
      }
    }


    return CustomScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          onPressed: (){

            Navigator.of(context).pop();
          },
        ),
        title: CustomTextButton(
          label: "${(mm.selectedPlay!.type == PlayType.JS || mm.selectedPlay!.type == PlayType.JSA)? simplePlayLabel: doublePlayLabel}${ (random)? " Aleatoria": "" }",
          onPressed: (random)? null:() {
            setState(() {

              betNumberPicked = false;
             if (mm.selectedPlay!.type == PlayType.JS){
                mm.selectedPlay!.type = PlayType.JD;
              }else {
                if (mm.selectedPlay!.type == PlayType.JD) {
                  mm.selectedPlay!.type = PlayType.JS;
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
              if (mm.selectedPlay!.nRandom >= 3) {
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
                        title: Text("Intentos restatnes de la jugada aleatoria: ${3 - mm.selectedPlay!.nRandom}"),
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
                                              "${mm.selectedPlay!.dayNumber.toString().padLeft(3, '0')}",
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
                                                  mm.selectedPlay!.dayNumber = dayNumbers[i];
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
                                                "${mm.selectedPlay!.nightNumber.toString().padLeft(3, '0')}",
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
                                                  mm.selectedPlay!.nightNumber = nightNumbers[i];
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
                                  onPressed: (getCurrentPlayLength() < 9 && (dayNumberPicked && nightNumberPicked && betNumberPicked) && mm.selectedPadlock!.playing)? () async {
                                      if (mm.newPlay){
                                        mm.selectedPadlock = await mm.createModel(modelType: ModelType.padlock, model: mm.selectedPadlock!) as Padlock;
                                        mm.newPlay = false;
                                      }
                                      mm.selectedPlay!.padlock = mm.selectedPadlock!.id;
                                      mm.selectedPlay!.confirmed = true;
                                      if (random){
                                        mm.updateModel(modelType: ModelType.play, model: mm.selectedPlay!).then((value) {
                                          mm.selectedPlay = Play(
                                              id: 0,
                                              padlock: 0,
                                              bet: 5,
                                              confirmed: false,
                                              dayNumber: 1,
                                              nightNumber: 1,
                                              nRandom: 0,
                                              type: PlayType.JS
                                          );
                                          resetScreen();
                                        });
                                      }else{
                                        mm.createModel(modelType: ModelType.play, model: mm.selectedPlay!).then((value) {
                                          mm.selectedPlay = Play(
                                              id: 0,
                                              padlock: 0,
                                              bet: 5,
                                              confirmed: false,
                                              dayNumber: 1,
                                              nightNumber: 1,
                                              nRandom: 0,
                                              type: PlayType.JS
                                          );
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

                                    if (mm.newPlay){
                                      mm.selectedPadlock = await mm.createModel(modelType: ModelType.padlock, model: mm.selectedPadlock!) as Padlock;
                                      mm.newPlay = false;
                                    }
                                    mm.selectedPadlock!.playing = false;
                                    if (getPrices().isNotEmpty) {
                                      mm.selectedPlay!.confirmed = true;
                                      if (random) {
                                        await mm.updateModel(modelType: ModelType.play,model: mm.selectedPlay!);
                                      } else {
                                        await mm.createModel(modelType: ModelType.play,model: mm.selectedPlay!);
                                      }
                                    }
                                    mm.updateModel(modelType: ModelType.padlock,model: mm.selectedPadlock!).then((value) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Terminaste tu jugada")),
                                      );
                                      Future.delayed(Duration(milliseconds: 1), (){
                                        Navigator.of(context).pushNamed(Routes.padlock);
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
      if (play.padlock == mm.selectedPadlock!.id){
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
