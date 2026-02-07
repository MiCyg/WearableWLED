import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ble_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WLED BLE',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BleService ble = BleService();
  List devices = [];
  String? connectedId;
  Map state = {};
  List<String> modes = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> scan() async {
    setState(() => devices = []);
    final ds = await ble.scanForDevices();
    setState(() => devices = ds);
  }

  Future<void> connect(String id) async {
    final sub = ble.connect(id).listen((ev) async {
      if (ev.connectionState == DeviceConnectionState.connected) {
        setState(() => connectedId = id);
        final s = await ble.readState();
        if (s != null) setState(() => state = jsonDecode(s));
        final m = await ble.requestModes();
        if (m != null) setState(() => modes = List<String>.from(jsonDecode(m)));
      } else if (ev.connectionState == DeviceConnectionState.disconnected) {
        setState(() => connectedId = null);
      }
    });
  }

  Future<void> setEffect(int fx) async {
    await ble.writeJson({"fx": fx});
    final s = await ble.readState();
    if (s != null) setState(() => state = jsonDecode(s));
  }

  Future<void> setBri(int bri) async {
    await ble.writeJson({"bri": bri});
    final s = await ble.readState();
    if (s != null) setState(() => state = jsonDecode(s));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WLED BLE Controller')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(children: [
              ElevatedButton(onPressed: scan, child: const Text('Scan')),
              const SizedBox(width: 12),
              Expanded(child: Text(connectedId == null ? 'Not connected' : 'Connected: $connectedId'))
            ]),
            const SizedBox(height: 12),
            Expanded(child: ListView(
              children: [
                ...devices.map((d) => ListTile(
                  title: Text(d.name.isNotEmpty ? d.name : d.id),
                  subtitle: Text(d.id),
                  trailing: ElevatedButton(onPressed: () => connect(d.id), child: const Text('Connect')),
                )),

                if (connectedId != null) ...[
                  const Divider(),
                  const Text('Effects', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (modes.isEmpty) const Text('Loading effects...') else DropdownButton<int>(
                    value: state['seg'] != null ? state['seg'][0]['mode'] : state['seg']?['mode'] ?? state['fx'] ?? 0,
                    items: List.generate(modes.length, (i) => DropdownMenuItem(value: i, child: Text('$i: ${modes[i]}'))),
                    onChanged: (v) { if (v!=null) setEffect(v); },
                  ),
                  const SizedBox(height: 12),
                  const Text('Brightness', style: TextStyle(fontWeight: FontWeight.bold)),
                  Slider(value: (state['bri'] ?? 128).toDouble(), min: 0, max: 255, onChanged: (d) => setBri(d.toInt())),
                ]
              ],
            ))
          ],
        ),
      ),
    );
  }
}
