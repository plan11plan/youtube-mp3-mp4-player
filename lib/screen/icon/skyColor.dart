import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SkyColor {
  static int colorIndex = 0;

  static final List<LinearGradient> colors = [
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.fromRGBO(57, 2, 63, 1),
        Color.fromRGBO(96, 18, 82, 1),
        Color.fromRGBO(125, 46, 86, 1),
        Color.fromRGBO(187, 135, 84, 1)
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigo.shade900,
        Colors.indigo.shade700,
            Colors.indigo.shade400,
            Colors.pink.shade200,
            Colors.yellow.shade200,
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigo.shade800,
        Colors.indigo.shade700,
        Colors.pink.shade200,
        Colors.yellow.shade200,
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.deepPurple.shade800.withOpacity(0.8),
        Colors.deepPurple.shade700.withOpacity(0.99),
        Colors.indigo.shade800.withOpacity(0.76),
        Colors.indigo.shade700.withOpacity(0.76),
        Colors.deepPurple.shade300.withOpacity(0.9),
        Colors.deepPurple.shade200.withOpacity(0.8),
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue[700]!,
        Colors.blue[200]!,
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.indigo[700]!,
        Colors.indigo[200]!,
      ],
    ),
    LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.purple[700]!,
        Colors.purple[200]!,
      ],
    ),
  ];

  static BoxDecoration get skyDecoration {
    return BoxDecoration(
      gradient: colors[colorIndex],
    );
  }
}

class MoonIconButton extends StatefulWidget {
  final Function callback;

  MoonIconButton({required this.callback});

  @override
  _MoonIconButtonState createState() => _MoonIconButtonState();
}

class _MoonIconButtonState extends State<MoonIconButton> {
  final List<IconData> moonPhases = [
    MdiIcons.moonWaxingCrescent,
    MdiIcons.moonFirstQuarter,
    MdiIcons.moonWaxingGibbous,
    MdiIcons.moonFull,
    MdiIcons.moonWaningGibbous,
    MdiIcons.moonLastQuarter,
    MdiIcons.moonWaningCrescent,
  ];
  int currentPhase = 0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(moonPhases[currentPhase], color: Colors.yellow[100]),
      onPressed: () {
        setState(() {
          currentPhase = (currentPhase + 1) % moonPhases.length;
          SkyColor.colorIndex = (SkyColor.colorIndex + 1) % SkyColor.colors.length;
          widget.callback();
        });
      },
    );
  }
}
