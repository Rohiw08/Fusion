import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fusion/CustomWidgets/bottom_modal.dart';
import 'package:fusion/CustomWidgets/custom_button.dart';
import 'package:fusion/CustomWidgets/web_tile.dart';
import 'package:fusion/CustomWidgets/widget_grid_tile.dart';
import 'package:fusion/services/auth/auth_controller.dart';
import 'dart:ui';

import 'package:fusion/services/auth/auth_repository.dart';

List<Widget> customWidgets = [
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/ETHUSD/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.reddit.com/r/CryptoCurrency/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl:
        "https://www.binance.com/en/square/news/all?ref=T79EQ4P0&gad_source=1&gclid=CjwKCAjwzMi_BhACEiwAX4YZULULWZfPshy3-KjjdlL0TQcPnP5qirbV2QiDfb4zTbIaRNxWDchGOxoCWlgQAvD_BwE&ads=true&utm_source=googleadwords_int&utm_medium=cpc",
  ),
];

List<Widget> setWidgets = [
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/ETHUSD/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/BTCUSD/",
  ),
  const WebOnlyGridTile(
    height: 2,
    width: 2,
    webUrl: "https://www.tradingview.com/symbols/XRPUSD/",
  ),
].toList(); // Convert to a mutable list

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HOME",
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddCustomerModal(context);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: StaggeredGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 4,
            children: setWidgets,
          ),
        ),
      ),
    );
  }
}
