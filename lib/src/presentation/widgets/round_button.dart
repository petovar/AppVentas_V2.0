import 'dart:ui';

import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    required Key key,
    required this.color,
    required this.icon,
    required this.texto,
    required this.route,
    required this.context,
    required this.enabledBoton,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final String texto;
  final String route;
  final BuildContext context;
  final bool enabledBoton;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
      child: InkWell(
        onTap: enabledBoton ? () => Navigator.pushNamed(context, route) : null,
        child: Container(
          height: 120,
          margin: EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            color: Color.fromRGBO(31, 37, 42, enabledBoton ? 0.6 : 0.3),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 15.0),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 35.0,
                child: Icon(icon, color: Colors.white),
              ),
              Text(
                texto,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: enabledBoton ? color : Colors.grey[400],
                  fontSize: 17.0,
                ),
              ),
              SizedBox(height: 15.0),
            ],
          ),
        ),
      ),
    );
  }
}

class RoundedButton extends StatelessWidget {
  const RoundedButton({
    super.key,
    required this.color,
    required this.icon,
    required this.texto,
    required this.route,
    required this.context,
    required this.enabledBoton,
  });

  final Color color;
  final IconData icon;
  final String texto;
  final String route;
  final BuildContext context;
  final bool enabledBoton;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 0.0, sigmaY: 0.0),
      child: InkWell(
        onTap: enabledBoton ? () => Navigator.pushNamed(context, route) : null,
        child: Container(
          height: 110,
          margin: EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Color.fromRGBO(62, 67, 107, enabledBoton ? 0.6 : 0.3),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              width: 2.0,
              color: const Color.fromARGB(255, 201, 196, 196),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(height: 8.0),
              CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 25.0,
                child: Icon(icon, color: Colors.white, size: 32.0),
              ),
              Text(
                texto,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
      ),
    );
  }
}
