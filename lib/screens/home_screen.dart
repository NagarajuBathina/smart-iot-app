import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/app/constants.dart';
import 'package:smart_iot_app/app/extensions.dart';
import 'package:smart_iot_app/provider.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late WifiProvider _provider;
  List<WifiNetwork> wifiNetworks = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _provider = context.read<WifiProvider>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      scanWifiNetworks();
    });
  }

  Future<void> scanWifiNetworks() async {
    setState(() {
      isLoading = true;
    });

    List<WifiNetwork> networks = await _provider.scanWifiNetworks();
    setState(() {
      wifiNetworks = networks;
      isLoading = false;
    });
  }

  void connectWifiNetwork(WifiNetwork network) async {
    String? wifiPassword;

    if (network.isSecure) {
      wifiPassword = await showPasswordDialog();
      if (wifiPassword == null) return;
    }

    // await _blueProvider.sendData(
    //     "wifi_id=${network.ssid};wifi_password=${wifiPassword ?? ""}"
    //     );

    // await _blueProvider.sendData(jsonEncode(
    //     {"wifi_id": network.ssid, "wifi_password": wifiPassword ?? ""}));

    if (!mounted) return;
    context.showMessage("Configure successfully");
    // Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: scanWifiNetworks,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wifiNetworks.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "No Wi-Fi networks available",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(8),
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemCount: wifiNetworks.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: mBlackColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        minLeadingWidth: 0,
                        leading: const Icon(
                          Icons.wifi,
                          color: mWhiteColor,
                        ),
                        title: Text(
                          wifiNetworks[index].ssid,
                          style:
                              const TextStyle(color: mWhiteColor, fontSize: 14),
                        ),
                        subtitle: Text(
                          wifiNetworks[index].isSecure
                              ? "Secured"
                              : "Not Secured",
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        trailing: TextButton(
                          onPressed: () =>
                              connectWifiNetwork(wifiNetworks[index]),
                          child: const Text("Connect"),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String?> showPasswordDialog() async {
    TextEditingController textFieldController = TextEditingController();

    return await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: mWhiteColor,
          title: Text(
            'Enter Wi-Fi Password',
            style: TextStyle(color: Colors.grey[900]),
          ),
          content: TextField(
            controller: textFieldController,
            style: TextStyle(color: Colors.grey[900]),
            decoration: InputDecoration(
              hintText: "Wi-Fi Password",
              hintStyle: TextStyle(color: Colors.grey[900]),
            ),
            obscureText: false,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(textFieldController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
