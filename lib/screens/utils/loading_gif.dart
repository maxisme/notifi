import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingGif extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 40.0,
        width: 40.0,
        child: Center(
          child: SizedBox(
              height: 20.0,
              width: 20.0,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              )),
        ));
  }
}
