import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

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
  List<List<double>> _timeSeries = List<List<double>>.filled(
      1, List<double>.filled(3, 0, growable: false),
      growable: true);
  Timer? _timer;
  bool _scanning = false;

  void _updateScanningStatus() {
    setState(() {
      _scanning = !_scanning;
      if (_scanning) _updateSensorDataOutput();
    });
  }

  void _updateSensorDataOutput() async {
    while (_scanning) {
      await Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          accelerometerEvents.listen(
            (AccelerometerEvent event) {
              if (_timeSeries.length == 1000) {
                _timeSeries.removeAt(0);
                _timeSeries.add([event.x, event.y, event.z]);
              } else {
                _timeSeries.add([event.x, event.y, event.z]);
              }
            },
          );
        });
      });
    }
  }

  void _sensorRead() {}

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
          height: 50,
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
          onPressed: _updateScanningStatus,
        ),
        const ListTile(
          title: Text('X axis acceleration is:'),
          leading: Icon(Icons.arrow_circle_down),
        ),
        Text(
          '${_timeSeries[0][0]}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const ListTile(
          title: Text('Y axis acceleration is:'),
          leading: Icon(Icons.arrow_right),
        ),
        Text(
          '${_timeSeries[0][1]}',
          style: Theme.of(context).textTheme.headline4,
        ),
        const ListTile(
          title: Text('Z axis acceleration is:'),
          leading: Icon(Icons.arrow_upward),
        ),
        Text(
          '${_timeSeries[0][2]}',
          style: Theme.of(context).textTheme.headline4,
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
