import 'dart:async';
import 'dart:convert';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

const Uuid svcUuid = Uuid.parse("12345678-1234-1234-1234-1234567890ab");
const Uuid chrUuid = Uuid.parse("abcdefab-1234-5678-1234-abcdefabcdef");

class BleService {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSub;
  StreamSubscription<ConnectionStateUpdate>? _connSub;
  QualifiedCharacteristic? _char;
  late StreamSubscription<List<int>> _notifySub;

  Future<List<DiscoveredDevice>> scanForDevices({Duration timeout = const Duration(seconds:5)}) async {
    final devices = <DiscoveredDevice>[];
    _scanSub = _ble.scanForDevices(withServices: [svcUuid]).listen((d) {
      if (!devices.any((x) => x.id == d.id)) devices.add(d);
    });
    await Future.delayed(timeout);
    await _scanSub?.cancel();
    _scanSub = null;
    return devices;
  }

  Stream<ConnectionStateUpdate> connect(String id) {
    final conn = _ble.connectToDevice(id: id, servicesWithCharacteristicsToDiscover: {svcUuid: [chrUuid]});
    conn.listen((update) {
      if (update.connectionState == DeviceConnectionState.connected) {
        _char = QualifiedCharacteristic(serviceId: svcUuid, characteristicId: chrUuid, deviceId: id);
      }
    });
    return conn;
  }

  Future<String?> readState() async {
    if (_char == null) return null;
    final data = await _ble.readCharacteristic(_char!);
    return utf8.decode(data);
  }

  Future<void> writeJson(Map<String, dynamic> obj) async {
    if (_char == null) return;
    final s = jsonEncode(obj);
    await _ble.writeCharacteristicWithResponse(_char!, value: utf8.encode(s));
  }

  Future<String?> requestModes() async {
    if (_char == null) return null;
    final req = jsonEncode({"get": "modes"});
    await _ble.writeCharacteristicWithResponse(_char!, value: utf8.encode(req));
    // read characteristic value or wait for notification
    try {
      final data = await _ble.readCharacteristic(_char!);
      return utf8.decode(data);
    } catch (e) {
      return null;
    }
  }

  Future<String?> requestPalettes() async {
    if (_char == null) return null;
    final req = jsonEncode({"get": "palettes"});
    await _ble.writeCharacteristicWithResponse(_char!, value: utf8.encode(req));
    try {
      final data = await _ble.readCharacteristic(_char!);
      return utf8.decode(data);
    } catch (e) {
      return null;
    }
  }

  Stream<String> subscribeNotifications() {
    if (_char == null) return Stream.empty();
    return _ble.subscribeToCharacteristic(_char!).map((b) => utf8.decode(b));
  }

  Future<void> dispose() async {
    await _scanSub?.cancel();
    await _connSub?.cancel();
  }
}
