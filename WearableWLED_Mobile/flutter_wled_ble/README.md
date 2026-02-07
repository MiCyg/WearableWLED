# WLED BLE Mobile (Flutter)

Simple Flutter mobile client that connects to the WLED BLE usermod and controls animations and basic configuration (effects, brightness).

Overview
- Scans for BLE devices advertising the WLED BLE service UUID.
- Connects and reads the full WLED JSON state from the BLE characteristic.
- Requests effect names and palettes via special JSON write commands ({"get":"modes"}).
- Allows selecting effect and adjusting brightness.

How to run
1. Install Flutter SDK (https://flutter.dev).
2. From this folder run:

```bash
flutter pub get
flutter run
```

Notes
- The app uses `flutter_reactive_ble` for BLE. On iOS you must add the required Bluetooth usage keys to `Info.plist`. On Android add the relevant permissions in `AndroidManifest.xml` and enable location if required.
- The app expects the WLED device to run the BLE usermod added to the repository and use the service/characteristic UUIDs in `ble_service.dart`.
