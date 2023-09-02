import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_isolate/message.dart';
import 'package:learn_isolate/user_response.dart';

import 'client_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textEditingController;
  String message = "Say Something!";
  List<UserResponse> usersList = <UserResponse>[];

  @override
  void initState() {
    _textEditingController = TextEditingController();
    sendMessage();
    super.initState();
  }

  Future<void> sendMessage() async {
    final rp = ReceivePort();
    Isolate.spawn(parseJsoIsolateEntity, rp.sendPort);

    final users = rp
        .takeWhile((element) => element is Iterable<UserResponse>)
        .cast<Iterable<UserResponse>>()
        .take(1);
    await for (final user in users) {
      setState(() {
        usersList.addAll(user);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
          itemCount: usersList.length,
          itemBuilder: (context, index) {
            return Container(
              width: double.infinity,
                height: 60,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(usersList[index].id.toString() ?? ""),
                    Text(usersList[index].title ?? ""),
                  ],
                ));
          }),
    );
  }
}
