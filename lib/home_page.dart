import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_isolate/message.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textEditingController;
  String message = "Say Something!";

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    setState(() {
      message = _textEditingController.text.isNotEmpty ? _textEditingController.text : message ;
    });
    super.didChangeDependencies();
  }

  Future<void> sendMessage() async {
      final line = _textEditingController.text.toLowerCase();
      switch (line.trim().toLowerCase()) {
        case null:
          break;
        case 'exit':
          exit(0);
        default:
          // try{
          //   final msg = await getMessages(line);
          //   log("test_message -> $msg");
          // }catch(e){
          //   log("test_message_error -> $e");
          // }
          final msg = await getMessages(line);
          log("test_message -> $msg");
          setState(() {
            message = msg;
          });
          false;
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Text(message),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 80),
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                  hintText: 'Type your messages',
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                      onPressed: () {
                        sendMessage();
                      }, icon: const Icon(Icons.send))),
            )),
      ),
    );
  }
}

Future<String> getMessages(String forGreeting) async {
  final rp = ReceivePort();
  Isolate.spawn(
    _communicator,
    rp.sendPort,
  );

  final broadcastRp = rp.asBroadcastStream();
  final SendPort communicatorSendPort = await broadcastRp.first;
  communicatorSendPort.send(forGreeting);

  return broadcastRp
      .takeWhile((element) => element is String)
      .cast<String>()
      .take(1)
      .first;
}

void _communicator(SendPort sp) async {
  final rp = ReceivePort();
  sp.send(rp.sendPort);

  final messages = rp.takeWhile((element) => element is String).cast<String>();

  await for (final message in messages) {
    for (final entry in messagesAndResponses.entries) {
      if (entry.key.trim().toLowerCase() == message.trim().toLowerCase()) {
        sp.send(entry.value);
        continue;
      }
    }
    sp.send('I have no response to that!');
  }
}
