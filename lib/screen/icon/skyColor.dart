import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  static ValueListenable<Box> getColorBoxListenable() {
    return Hive.box('settings').listenable(keys: ['colorIndex']);
  }

  static Future<void> saveColorIndex() async {
    var box = await Hive.openBox('settings');
    await box.put('colorIndex', colorIndex);
  }

  static BoxDecoration get skyDecoration {
    return BoxDecoration(gradient: colors[colorIndex]);
  }

  ValueListenable<Box> get listenableSettingsBox {
    return Hive.box('settings').listenable();
  }
}



class MoonIconButton extends StatefulWidget {
  final Function callback;

  MoonIconButton({required this.callback});

  @override
  MoonIconButtonState createState() => MoonIconButtonState();
}

class MoonIconButtonState extends State<MoonIconButton> {
  final List<IconData> moonPhases = [
    MdiIcons.moonWaxingCrescent,
    MdiIcons.moonFirstQuarter,
    MdiIcons.moonWaxingGibbous,
    MdiIcons.moonFull,
    MdiIcons.moonWaningGibbous,
    MdiIcons.moonLastQuarter,
    MdiIcons.moonWaningCrescent,
  ];
  static int currentPhase = 0;

  static Future<void> saveCurrentPhase() async {
    var box = await Hive.openBox('settings');
    await box.put('moonPhase', currentPhase);
  }

  static ValueListenable<Box> getMoonPhaseBoxListenable() {
    return Hive.box('settings').listenable(keys: ['moonPhase']);
  }

  static Future<void> loadCurrentPhase() async {
    var box = await Hive.openBox('settings');
    currentPhase = box.get('moonPhase', defaultValue: 0);
  }
  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      endRadius: 30,
      glowColor: Colors.blueGrey[300]!,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 500),
        child: IconButton(
          key: ValueKey<int>(currentPhase),
          icon: Icon(moonPhases[currentPhase], color: Colors.yellow[100], size: 30,),
          onPressed: () {
            setState(() {
              currentPhase = (currentPhase + 1) % moonPhases.length;
              saveCurrentPhase();  // Save the current phase of the moon icon
              SkyColor.colorIndex = (SkyColor.colorIndex + 1) % SkyColor.colors.length;
              SkyColor.saveColorIndex();
              widget.callback();
            });
          },
        ),
      ),
    );
  }
}