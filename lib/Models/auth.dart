import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Auth with ChangeNotifier {

  Future<String> signup(String email, String password) async {
    final url = Uri.parse('https://cuaca-kita.herokuapp.com/auth/register');
    final response = await http.post(url, body: json.encode({
      'email': email,
      'password': password
      }),
    headers: {"Content-type":"application/json"}
    );
    var result = response.body;
    return result;
  }

  Future<String> login(String email, String password) async {
    final url = Uri.parse('https://cuaca-kita.herokuapp.com/auth/login');
    final response = await http.post(url, body: json.encode({
      'email': email,
      'password': password
    }),
    headers: {"Content-type":"application/json"}
    );
    var result = response.body;
      return result;
  }
}