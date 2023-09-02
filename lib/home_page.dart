import 'dart:developer';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void getMessages() async {
    await for (final message in getMessage()) {
      log("message : $message");
    }
  }

  void _incrementCounter() {
    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder<String>(
            stream: getMessage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Text('Error');
                } else if (snapshot.hasData) {
                  return Text(DateFormat.Hms().format(DateTime.parse(snapshot.data.toString())),
                      style: const TextStyle(color: Colors.red, fontSize: 40));
                } else {
                  return const Text('Empty data');
                }
              } else {
                return Text('State: ${snapshot.connectionState}');
              }
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

Stream<String> getMessage() {
  final rp = ReceivePort();
  return Isolate.spawn(_getMessage, rp.sendPort)
      .asStream()
      .asyncExpand((event) => rp)
      .takeWhile((element) => element is String)
      .cast();
}

Future<void> _getMessage(SendPort sp) async {
  await for (final now in Stream.periodic(const Duration(seconds: 1),
      (_) => DateTime.now().toIso8601String())) {
    sp.send(now);
  }
}
