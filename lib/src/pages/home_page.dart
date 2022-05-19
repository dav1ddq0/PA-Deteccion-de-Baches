import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:deteccion_de_baches/src/utils/algs.dart';
import 'package:deteccion_de_baches/src/providers/menu_provider.dart';
import 'package:deteccion_de_baches/src/utils/icon_string.dart';
import 'package:deteccion_de_baches/src/pages/saved_data.dart';

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
  static const int _accelReadIntervals = 100;
  static const int _geoLocReadIntervals = 1000;
  String cp = 'None';

  final _streamSubscriptions = <StreamSubscription<dynamic>>[];
  final List<Position?> _geoLoc = [];
  final List<Tuple3<double, double, double>> _accelRead =
      []; // Serie temporal acelerómetro
  final List<Tuple3<double, double, double>> _gyroRead =
      []; // Serie temporal giroscopio
  final List<double> _speedRead =
      []; // Velocidad en cada momento que se realiza una medición en km/h

  late Timer _accelTimer;
  late Timer _geoLocTimer;
  late GyroscopeEvent _gyroEvent;
  late UserAccelerometerEvent _accelEvent;
  JData data_prueba = JData();
  bool _scanning = false;
  bool _bumpDetected = false; // Para saber si la app está escaneando o no

  @override
  void initState() {
    super.initState();
  }

  // Métodos auxiliares

  Tuple2<double, double> updateGeoData(
      double currLat, currLong, prevLat, prevLong) {
    if (_geoLoc.length == 1000) {
      _geoLoc.removeAt(0);
    }

    late double currSpeed;
    if (_geoLoc.length > 1) {
      var currSpeed = _updateSpeedRead(prevLat, prevLong, currLat, currLong);

      if (_speedRead.isEmpty) {
        currSpeed = currSpeed * 0.1;
      } else {
        currSpeed = _speedRead.last * 0.9 + currSpeed * 0.1;
      }

      currSpeed = double.parse(currSpeed.toStringAsPrecision(6));
      _speedRead.add(currSpeed);
    }

    return biAxialLowpassFilter(prevLat, prevLong, currLat, currLong);
  }

  Tuple3<double, double, double> updateGyroData(
      double currReadX,
      double currReadY,
      double currReadZ,
      double prevReadX,
      double prevReadY,
      double prevReadZ) {
    if (_gyroRead.length == 1000) {
      _gyroRead.removeAt(0);
    }

    return triAxialHighpassFilter(
        prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ);
  }

  Tuple3<double, double, double> updateAccelData(
      double currReadX,
      double currReadY,
      double currReadZ,
      double prevReadX,
      double prevReadY,
      double prevReadZ) {
    if (_accelRead.length == 1000) {
      _accelRead.removeAt(0);
    }

    return triAxialHighpassFilter(
        prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ);
  }

  double _updateSpeedRead(
      double prevLat, double prevLong, double currLat, double currLong) {
    if (_speedRead.length == 1000) {
      _speedRead.removeAt(0);
    }

    final double currSpeed = computeSpeed(
        prevLat, prevLong, currLat, currLong, (_geoLocReadIntervals / 1000));
    return double.parse(currSpeed.toStringAsPrecision(5));
  }

  void subscribeAccelEventListener() {
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _accelEvent = event;
      });
    }));
  }

  void subscribeGyroEventListener() {
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroEvent = event;
      });
    }));
  }

  // Métodos activados por onPressed

  void _switchTimerAndEvents() {
    if (_scanning) {
      _accelTimer = Timer.periodic(
          const Duration(milliseconds: _accelReadIntervals), (timer) {
        _updateFilterAccelData();
        _updateFilterGyroData();
      });
      _geoLocTimer = Timer.periodic(
          const Duration(milliseconds: _geoLocReadIntervals), (timer) {
        _updateFilterGeoData();
      });

      if (_streamSubscriptions.isEmpty) {
        subscribeAccelEventListener();
        subscribeGyroEventListener();
      } else {
        for (var subscription in _streamSubscriptions) {
          subscription.resume();
        }
      }
    } else {
      _geoLocTimer.cancel();
      _accelTimer.cancel();
      for (var subscription in _streamSubscriptions) {
        subscription.pause();
      }
    }
  }

  void _switchScanning() {
    setState(() {
      _scanning = !_scanning;
    });

    data_prueba.localPath.then((value) {
      setState(() {
        cp = value;

        _grantStoragePermissions();
        data_prueba.createBumpFolder();
        data_prueba.templocalFile;
        print(cp);
      });
    });
    _switchTimerAndEvents();
  }

  // Métodos para obtener lecturas de los senspores y realizar operaciones con esta información
  Future<void> _grantStoragePermissions() async {
    var storage_status = await Permission.storage.status;
    var media_location_status = await Permission.accessMediaLocation.status;
    var external_storage_status = await Permission.manageExternalStorage.status;
    if (!storage_status.isGranted) {
      await Permission.storage.request();
    }

    if (!storage_status.isGranted) {
      await Permission.storage.request();
    }
    if (!media_location_status.isGranted) {
      await Permission.accessMediaLocation.request();
    }

    if (!external_storage_status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  Future<void> _updateFilterGeoData() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position newRead = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // double currLat = double.parse(newRead.latitude.toStringAsPrecision(10));
    // double currLong = double.parse(newRead.longitude.toStringAsPrecision(10));

    final double prevLat = _geoLoc.isEmpty ? 0 : _geoLoc.last!.latitude;
    final double prevLong = _geoLoc.isEmpty ? 0 : _geoLoc.last!.longitude;

    var newGeoFilt =
        Tuple2<double, double>(newRead.latitude, newRead.longitude);

    if (prevLat != 0 && prevLong != 0) {
      newGeoFilt =
          updateGeoData(newRead.latitude, newRead.longitude, prevLat, prevLong);
    }
    // Actualizar lecturas de velocidad y coordenadas.

    final readFiltered = Position(
      latitude: newGeoFilt.item1,
      longitude: newGeoFilt.item2,
      timestamp: newRead.timestamp,
      accuracy: newRead.accuracy,
      altitude: newRead.altitude,
      heading: newRead.heading,
      speed: newRead.speed,
      speedAccuracy: newRead.speedAccuracy,
    );

    setState(() {
      _geoLoc.add(readFiltered);
    });
  }

  Future<void> _updateFilterAccelData() async {
    // Obtener lecturas del giroscopio y acelerómetro
    final double currReadX = double.parse(_accelEvent.x.toStringAsPrecision(6));
    final double currReadY = double.parse(_accelEvent.y.toStringAsPrecision(6));
    final double currReadZ = double.parse(_accelEvent.z.toStringAsPrecision(6));

    final double prevReadX = _accelRead.isEmpty ? 0 : _accelRead.last.item1;
    final double prevReadY = _accelRead.isEmpty ? 0 : _accelRead.last.item2;
    final double prevReadZ = _accelRead.isEmpty ? 0 : _accelRead.last.item3;

    final newAccelFilt = updateAccelData(
        currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ);

    setState(() {
      _accelRead.add(newAccelFilt);
      if (prevReadX != 0) {
        _bumpDetected = scanPotholes(
            prevReadX, prevReadY, prevReadZ, currReadX, currReadY, currReadZ);
        if (_bumpDetected) {
          HapticFeedback.vibrate();
        }
      }
    });
  }

  Future<void> _updateFilterGyroData() async {
    final double currReadX = double.parse(_gyroEvent.x.toStringAsPrecision(6));
    final double currReadY = double.parse(_gyroEvent.y.toStringAsPrecision(6));
    final double currReadZ = double.parse(_gyroEvent.z.toStringAsPrecision(6));

    final double prevReadX = _gyroRead.isEmpty ? 0 : _gyroRead.last.item1;
    final double prevReadY = _gyroRead.isEmpty ? 0 : _gyroRead.last.item2;
    final double prevReadZ = _gyroRead.isEmpty ? 0 : _gyroRead.last.item3;

    final newGyroFilt = updateGyroData(
        currReadX, currReadY, currReadZ, prevReadX, prevReadY, prevReadZ);

    setState(() {
      _gyroRead.add(newGyroFilt);
    });
  }

  // Método para construir el Widget

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bump Record'),
      ),
      body: _createHomePageItems(),
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
    return Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
          onPressed: _switchScanning),
      const SizedBox(
        height: 10,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text(
              'Y axis accel is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              //   _accelRead.isEmpty ? 'None' : '${_accelRead.last.item2}',
              //   _accelRead.isEmpty
              cp == 'None' ? 'No hay path' : cp,
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Z axis accel is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _accelRead.isEmpty ? 'None' : '${_accelRead.last.item3}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
      ]),
      Column(
        children: [
          const ListTile(
            leading: Icon(Icons.speed),
            title: Text(
              'curr speed',
              style: TextStyle(fontSize: 24),
            ),
          ),
          Text(
            _speedRead.isEmpty ? 'None' : '${_speedRead.last} km/h',
            style: TextStyle(
                fontSize: 40,
                color: _speedRead.isEmpty ? Colors.blueAccent : Colors.amber),
          ),
        ],
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text(
              'Y axis gyro is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _gyroRead.isEmpty ? 'None' : '${_gyroRead.last.item2}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Z axis gyro is',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _gyroRead.isEmpty ? 'None' : '${_gyroRead.last.item3}',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
      ]),
      const SizedBox(
        height: 10,
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Column(
          children: [
            const Text(
              'Latitude',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _geoLoc.isNotEmpty ? '${_geoLoc.last?.latitude}' : 'None',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
        Column(
          children: [
            const Text(
              'Longitude',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              _geoLoc.isNotEmpty ? '${_geoLoc.last?.longitude}' : 'None',
              style: const TextStyle(fontSize: 20, color: Colors.purple),
            ),
          ],
        ),
      ]),
      const SizedBox(
        height: 20,
      ),
      //   const Text(
      //     'Bump Detected',
      //     style: TextStyle(fontSize: 24),
      //   ),
      //   Text(
      //     _bumpDetected ? 'Yes' : 'No',
      //     style: TextStyle(
      //         fontSize: 40,
      //         color: _bumpDetected
      //             ? Colors.redAccent.shade700
      //             : Colors.greenAccent.shade700),
      //   ),
    ]);
  }
}
