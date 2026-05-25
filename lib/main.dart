import 'package:flutter/material.dart';
import 'package:magicsorafront/app/app.dart';

void main() {
  // Flutter 바인딩을 먼저 초기화해 앱 전역 설정이 필요한 경우를 대비한다.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DebateApp());
}
