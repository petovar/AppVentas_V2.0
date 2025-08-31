import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

import 'library.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.mIndicator, this.mColor, this.mSize});

  final Indicator? mIndicator;
  final Color? mColor;
  final double? mSize;

  @override
  Widget build(BuildContext context) {
    Color colorAccent = HexColor.fromHex('#02dfbb');
    return Container(
      alignment: Alignment.center,
      width: (mSize ?? 20),
      height: (mSize ?? 20),
      child: Center(
        child: LoadingIndicator(
          indicatorType:
              (mIndicator == null ? Indicator.ballBeat : mIndicator!),
          colors: [(mColor ?? colorAccent)],
        ),
      ),
    );
  }
}
