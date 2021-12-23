import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sorted_list/sorted_list.dart';

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

  static const int _readIntervals = 1000;

  final _sortedSlopes = SortedList<double>((slope1, slope2) => slope1.compareTo(slope2));
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  late Timer _timer;

  late GyroscopeEvent _gyroEvent;
  late UserAccelerometerEvent _accelEvent;

  List<Tuple3<double, double, double>> _accelRead = []; // Serie temporal acelerómetro
  List<Tuple3<double, double, double>> _gyroRead = []; // Serie temporal giroscopio
  
  List<double> _speedRead = []; // Velocidad en cada momento que se realiza una medición en km/h
  bool _scanning = false; // Para saber si la app está escaneando o no

  @override
  void initState() {
    super.initState();
  }

  // Métodos auxiliares

  void updategGyroRelatedData (double gyroReadX, double gyroReadY, double gyroReadZ, 
    double previousGyroX, double previousGyroReadY, double previousGyroReadZ) {

      final newGyroSpeed = updateGyroData (gyroReadX, gyroReadY, gyroReadZ);

      setState(() {
        _gyroRead.add(newGyroSpeed);
      });
  }

  Tuple3<double, double, double> updateGyroData (double currentReadX, double currentReadY, double currentReadZ) {
    if (_gyroRead.length == 1000) {
      _gyroRead.removeAt(0);
      return Tuple3<double, double, double>(currentReadX, currentReadY, currentReadZ);
    }

    else {
      return Tuple3<double, double, double>(currentReadX, currentReadY, currentReadZ);
    }
  }

  void updateAccelRelatedData (double accelReadX, double accelReadY, double accelReadZ, 
    double previousAccelX, double previousAccelReadY, double previousAccelReadZ, double previousSpeed) {
    
    final newAccel = updateAccelData(accelReadX, accelReadY, accelReadZ);
    final newSpeed = _updateSpeedRead(previousSpeed, accelReadY, previousAccelReadY);
    
    setState(() {
      _accelRead.add(newAccel);
      _sortedSlopes.add((newSpeed - _speedRead.last) / (_readIntervals / 1000));
      _speedRead.add(newSpeed);
    });
  }

  Tuple3<double, double, double> updateAccelData (double currentReadX, double currentReadY, double currentReadZ) {
    if (_accelRead.length == 1000) {
      _accelRead.removeAt(0);
      return Tuple3<double, double, double>(currentReadX, currentReadY, currentReadZ);
    }

    else {
      return Tuple3<double, double, double>(currentReadX, currentReadY, currentReadZ);
    }
  }

  double _updateSpeedRead (double previousSpeed, double currentReadY, double previousReadY) {
    if (_speedRead.length == 1000) {
      _speedRead.removeAt(0);
    }

    double slopeMedian = _sortedSlopes.length % 2 == 0
      ? (_sortedSlopes[(_sortedSlopes.length / 2).round()] + _sortedSlopes[(_sortedSlopes.length / 2).round() - 1])  / 2
      : _sortedSlopes[(_sortedSlopes.length / 2).round() - 1];

    return double.parse(computeSpeed(previousSpeed, currentReadY, slopeMedian, (_readIntervals / 1000)).toStringAsPrecision(5));
  }

  void subscribeAccelEventListener () {
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
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
      _timer = Timer.periodic(Duration(milliseconds: _readIntervals), (timer) {
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
      final double previousReadX = _accelRead.last.item1;
      final double previousReadY = _accelRead.last.item2;
      final double previousReadZ = _accelRead.last.item3;

      if(_speedRead.isNotEmpty) {
        final double previousSpeed = _speedRead[_speedRead.length - 1];                
        updateAccelRelatedData(currentReadX, currentReadY, currentReadZ, previousReadX, previousReadY, previousReadZ, previousSpeed);
      }
    }
    else {
      setState(() {
        final newAccelRead = updateAccelData(currentReadX, currentReadY, currentReadZ);
        _accelRead.add(newAccelRead);
        _speedRead.add(0);
        _sortedSlopes.add(0);
      });
    }
  }

  Future<void> _updateGyroDataOutput () async {
    final double currentReadX = double.parse(_gyroEvent.x.toStringAsPrecision(6));
    final double currentReadY = double.parse(_gyroEvent.y.toStringAsPrecision(6));
    final double currentReadZ = double.parse(_gyroEvent.z.toStringAsPrecision(6));
    
    if (_gyroRead.isNotEmpty) {
      final double previousReadX = _gyroRead.last.item1;
      final double previousReadY = _gyroRead.last.item2;
      final double previousReadZ = _gyroRead.last.item3;
      
      updategGyroRelatedData(currentReadX, currentReadY, currentReadZ, previousReadX, previousReadY, previousReadZ);
    }

    else {
      setState(() {
        final newGyroRead = updateGyroData(currentReadX, currentReadY, currentReadZ);
        _gyroRead.add(newGyroRead);
      });
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        const SizedBox(
              height: 10,
            ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'Y axis accel is', 
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
                Text(
                  _accelRead.isEmpty 
                    ? 'None' 
                    : '${_accelRead.last.item2}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.purple
                  ),
                ),
              ],
            ),

            Column(
              children: [
                const Text(
                  'Z axis accel is', 
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
                Text(
                  _accelRead.isEmpty 
                    ? 'None' 
                    : '${_accelRead.last.item3}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.purple
                  ),
                ),
              ],
            ),
          ]
        ),
      
        Column(
          children: [
            const ListTile(
              leading: Icon(Icons.speed),
              title: Text(
                'Current speed',
                style: TextStyle(
                  fontSize: 24
                ),
              ),
            ),

            Text(
              _speedRead.isEmpty
                ? 'None' 
                : '${_speedRead.last} km/h',
              style: TextStyle(
                fontSize: 40,
                color: _speedRead.isEmpty
                  ? Colors.blueAccent
                  : Colors.amber
              ),
            ),
          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'Y axis gyro is', 
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
                Text(
                  _gyroRead.isEmpty 
                    ? 'None' 
                    : '${_gyroRead.last.item2}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.purple
                  ),
                ),
              ],
            ),

            Column(
              children: [
                const Text(
                  'Z axis gyro is', 
                  style: TextStyle(
                    fontSize: 24
                  ),
                ),
                Text(
                  _gyroRead.isEmpty
                    ? 'None' 
                    : '${_gyroRead.last.item3}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.purple
                  ),
                ),
              ],
            ),
          ]
        ),
      ]
    );
  }
}