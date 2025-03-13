import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

class WifiProvider extends ChangeNotifier {
  Future<List<WifiNetwork>> scanWifiNetworks() async {
    List<WifiNetwork> networks = [];

    try {
      var status = await Permission.location.request();
      if (!status.isGranted) {
        print("Location permission is required to scan Wi-Fi networks.");
        return networks;
      }

      await Future.delayed(const Duration(seconds: 1));
      networks = (await WifiFlutter.wifiNetworks).toList();
      print("Found networks: ${networks.length}");
    } catch (e) {
      print('Error retrieving Wi-Fi networks: $e');
    }
    return networks;
  }
}
