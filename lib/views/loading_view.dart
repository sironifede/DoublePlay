
import 'package:flutter/cupertino.dart';
import 'package:bolita_cubana/views/main/custom_scaffold.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context){

    return CustomScaffold(
      body: Center(
          child: CircularProgressIndicator()
      ),
    );

  }
}
