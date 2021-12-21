import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'package:deteccion_de_baches/src/utils/algs.dart';
import 'package:deteccion_de_baches/src/providers/menu_provider.dart';
import 'package:deteccion_de_baches/src/utils/icon_string.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];
  late Timer _timer;

  late GyroscopeEvent _gyroEvent;
  late AccelerometerEvent _accelEvent;
  
  List<Tuple3<double, double, double>> _accelRead = []; // Serie temporal acelerómetro
  List<Tuple3<double, double, double>> _gyroRead = []; // Serie temporal giroscopio
  
  List<double> _speedRead = []; // Velocidad en cada momento que se realiza una medición en km/h
  List<int> _states = []; // Estados del vehículo, puede estar parado (0) o en movimiento (1)
  List<int> _changePointsIndexes = []; // Para saber cual de los estados representa un punto de cambio (frenar o comenzar a moverse)
  bool _motion = false; // Para saber si el teléfono se encuentra en un vehículo en movimiento
  bool _scanning = false; // Para saber si la app está escaneando o no

  @override
  void initState() {
    super.initState();
  }

  // Métodos auxiliares

  void updateAccelRelatedData (double accelReadX, double accelReadY, double accelReadZ, 
    double previousAccelX, double previousAccelY, double previousAccelZ, double previousSpeed) {
    
    var newAccel = updateAccel(accelReadX, accelReadY, accelReadY);
    var newMotion = detectMotion(_states, previousAccelX, previousAccelY, previousAccelZ, accelReadX, accelReadY, accelReadZ);
    _accelRead = [..._accelRead, newAccel];
    _motion = newMotion;

    var newState = _updateStates();
    _states = [..._states, newState];

    var newChangePointIndex = _updateChangePointsIndex();
    var newSpeed = _updateSpeedRead(previousSpeed, accelReadY);
    
    setState(() {
      _changePointsIndexes = newChangePointIndex == -1 ? _changePointsIndexes : [..._changePointsIndexes,  newChangePointIndex];

      if (_motion) {
        _speedRead = [..._speedRead, newSpeed];
      }
      else {
      _speedRead = [..._speedRead, 0];
      }
    });
  }

  Tuple3<double, double, double> updateAccel (double currentReadX, double currentReadY, double currentReadZ) {
    if (_accelRead.length == 1000) {
      _accelRead.removeAt(0);
      return Tuple3<double, double, double>(currentReadX, currentReadY, currentReadZ);
    }

    else {
      return Tuple3<double, double, double>(currentReadX, currentReadY, currentReadZ);
    }
  }

  int _updateStates () {
    if (_states.length == 1000) {
        _states.removeAt(0);
        return _motion == true ? 1 : 0;
    }

    else {
      return _motion == true ? 1 : 0;
    }
  }

  double _updateSpeedRead (double previousSpeed, double currentReadY) {
    if (_speedRead.length == 1000) {
      _speedRead.removeAt(0);
      if (_motion) {
        return double.parse(speedEstKinetic(previousSpeed, currentReadY, 0.1).toStringAsPrecision(8));
      }

      else {
        return 0;
      }
    }

    else {
      return _motion ? double.parse(speedEstKinetic(previousSpeed, currentReadY, 1).toStringAsPrecision(8)) : 0;
    }
  }
  
  int _updateChangePointsIndex() {
    if (_states.length > 2) {
      if (_changePointsIndexes.length == 999) {
        _changePointsIndexes.removeAt(0);
        return lastStateIsChangePoint(_states, _changePointsIndexes);
      }

      else {
        return lastStateIsChangePoint(_states, _changePointsIndexes);
      }
    }
    return -1;
  }

  void subscribeAccelEventListener () {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
           _accelEvent = event;
          });
        }));
  }

  void subscribeGyroEventListener () {
    _streamSubscriptions.add(
     gyroscopeEvents.listen(
       (GyroscopeEvent event) {
         setState(() {
           _gyroEvent = event;
         });
       }));
  }

  void _switchTimerAndEvents () {
    if (_scanning) {
      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          _updateAccelRelatedDataOutput();
          _updateGyroDataOutput();
        });

      if (_streamSubscriptions.isEmpty) {
        subscribeAccelEventListener();
        subscribeGyroEventListener();
      }

      else {
        for (var subscription in _streamSubscriptions) {
        subscription.resume();
        }
      }
    }

    else {
      _timer.cancel();
      for (var subscription in _streamSubscriptions) {
        subscription.pause();
      }
    }
  }
  // Métodos activados por onPressed
  void _switchScanning () {
    setState(() {
      _scanning = !_scanning;
    });
    _switchTimerAndEvents();
  }

  Future<void> _updateAccelRelatedDataOutput() async { // Obtener lecturas del giroscopio y acelerómetro
    final double currentReadX = double.parse(_accelEvent.x.toStringAsPrecision(6));
    final double currentReadY = double.parse(_accelEvent.y.toStringAsPrecision(6));
    final double currentReadZ = double.parse(_accelEvent.z.toStringAsPrecision(6));

    if (_accelRead.isNotEmpty) {
      final double previousReadX = _accelRead[_accelRead.length - 1].item1;
      final double previousReadY = _accelRead[_accelRead.length - 1].item2;
      final double previousReadZ = _accelRead[_accelRead.length - 1].item3;

      if(_speedRead.isNotEmpty) {
        final double previousSpeed = _speedRead[_speedRead.length - 1];                
        updateAccelRelatedData(currentReadX, currentReadY, currentReadZ, previousReadX, previousReadY, previousReadZ, previousSpeed);
      }
    }
    else {
      setState(() {
        var newAccelRead = updateAccel(currentReadX, currentReadY, currentReadZ);
        _accelRead = [..._accelRead, newAccelRead];
        _states = [0];
        _speedRead = [..._speedRead, 0];
      });
    }
  }

  Future<void> _updateGyroDataOutput () async {
    final double previousReadX = _gyroRead[_gyroRead.length - 1].item1;
    final double previousReadY = _gyroRead[_gyroRead.length - 1].item2;
    final double previousReadZ = _gyroRead[_gyroRead.length - 1].item3;
    if (_gyroRead[0].item1 == 0 ||_gyroRead.length == 1000) {
      _gyroRead.removeAt(0);
      _gyroRead.add(Tuple3<double, double, double>(_gyroEvent.x, _gyroEvent.y, _gyroEvent.z));
    }
    else {
      _gyroRead.add(Tuple3<double, double, double>(_gyroEvent.x, _gyroEvent.y, _gyroEvent.z));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bump Record'),
      ),
      body: _createHomePageItems(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'reload',
        child: const Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _createHomePageItems() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        FutureBuilder(
            future: menu_provider.loadData(),
            initialData: [],
            builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
              return ListView(
                  shrinkWrap: true,
                  children: _createPagesAccessItems(snapshot.data, context));
            }),
        const SizedBox(
          height: 20,
        ),
        _createAxisInfoItems(context)
      ],
    );
  }

  List<Widget> _createPagesAccessItems(
      List<dynamic>? data, BuildContext context) {
    List<Widget> pagesItems = [];

    if (data != null) {
      for (var elem in data) {
        final tempWidget = ListTile(
          title: Text(elem['text']),
          leading: getIcon(elem['icon']),
          trailing: const Icon(
            Icons.keyboard_arrow_right_rounded,
            color: Colors.amber,
          ),
          onTap: () {
            // final route = MaterialPageRoute(
            //   builder: (context) => InfoPage()
            // );
            // Navigator.push(context, route);

            Navigator.pushNamed(context, '/' + elem['route']);
          },
        );

        pagesItems
          ..add(tempWidget)
          ..add(const Divider());
      }
    }
    return pagesItems;
  }

  Widget _createAxisInfoItems(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            elevation: 20,
          ),
          child: _scanning
              ? const Text(
                  'Scannnig for bumps...Press again if you wish to stop scanning',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold))
              : const Text('Press here to start scanning for bumps',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
          onPressed: _switchScanning
        ),
        const ListTile(
          title: Text('Y axis acceleration is:'),
          leading: Icon(Icons.arrow_circle_down),
        ),
        Text(
          _accelRead.isEmpty 
            ? 'None' 
            : '${_accelRead[_accelRead.length - 1].item2}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const ListTile(
          title: Text('Current state is change point ??'),
          leading: Icon(Icons.star_rate_outlined),
        ),
        Text(
          _changePointsIndexes.isNotEmpty
            ? _states.length - 1 == _changePointsIndexes[_changePointsIndexes.length - 1]
              ? 'YES' 
              : 'NO'
            : 'List Empty',
          style: TextStyle(color: _changePointsIndexes.isNotEmpty
            ? _states.length - 1 == _changePointsIndexes[_changePointsIndexes.length - 1]
              ? Colors.green.shade900
              : Colors.red.shade900
            : Colors.amber.shade900, fontSize: 30),
        ),
        const ListTile(
          title: Text('Current speed'),
          leading: Icon(Icons.speed),
        ),
        Text(
          _speedRead.isEmpty
            ? 'None' 
            : '${_speedRead[_speedRead.length - 1]} km/h',
          style: Theme.of(context).textTheme.headline4,
        ),
        Text(
          _motion 
            ? 'In motion'
            : 'Steady', 
          style: TextStyle(
              color: _motion 
                ? Colors.green.shade900
                : Colors.red.shade900)
        )
      ],
    );
  }
}

// class HomePage extends StatefulWidget {
//   @override
//   createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final TextStyle _my_style = new TextStyle(fontSize: 25);
//   int _count = 10;

//   void _increase_counter() {
//     setState(() {
//       _count++;
//     });
//   }

//   void _decrease_counter() {
//     setState(() {
//       _count--;
//     });
//   }

//   void _counter_to_zero() {
//     setState(() {
//       _count = 0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Bump Record'),
//           centerTitle: true,
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               Text('Amount of clicks:', style: _my_style),
//               Text('$_count', style: _my_style)
//             ],
//           )
//         ),
//         floatingActionButton: createButtons()
//     );
//   }

//   Widget createButtons() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: <Widget>[
//         SizedBox(width: 30),
//         FloatingActionButton(
//             child: Icon(Icons.exposure_zero), onPressed: _counter_to_zero
//             ),
//         Expanded(
//           child: SizedBox()
//           ),
//         FloatingActionButton(
//             child: Icon(Icons.remove), onPressed: _decrease_counter
//             ),
//         FloatingActionButton(
//             child: Icon(Icons.add), onPressed: _increase_counter
//             ),
//       ],
//     );
//   }
// }
