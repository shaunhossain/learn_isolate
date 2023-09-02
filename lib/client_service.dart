import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:learn_isolate/user_response.dart';

Future<void> parseJsoIsolateEntity(SendPort sp) async {
  final client = HttpClient();
  final url = Uri.parse("https://jsonplaceholder.typicode.com/posts");
  final users = await client
      .getUrl(url)
      .then((req) => req.close())
      .then((response) => response.transform(utf8.decoder).join())
      .then((value) => jsonDecode(value) as List<dynamic>)
      .then((json) => json.map((map) => UserResponse.fromJson(map)));
  sp.send(users);
}