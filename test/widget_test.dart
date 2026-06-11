import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:magicsorafront/app/app.dart';
import 'package:magicsorafront/features/auth/models/app_user.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('앱 첫 화면으로 카카오 로그인 랜딩이 렌더링된다', (tester) async {
    await tester.pumpWidget(const DebateApp());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('질문하고, 토론하고, 기록하는 마법의 소라고동'), findsOneWidget);
    expect(find.bySemanticsLabel('카카오 로그인'), findsOneWidget);
  });

  testWidgets('홈 화면 기본 컴포넌트가 렌더링된다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(home: MagicConchHomeScreen(user: AppUser.fallback)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('마법의 소라고동!'), findsOneWidget);
    expect(find.text('질문 기록'), findsOneWidget);
    expect(find.text('계정 정보'), findsOneWidget);
    expect(find.text('무엇이 궁금한가요?'), findsOneWidget);
  });

  testWidgets('모바일 폭별 메인 메뉴 레이아웃이 유지된다', (tester) async {
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    for (final width in [280.0, 320.0, 360.0, 390.0, 430.0, 480.0]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 640);

      await tester.pumpWidget(const DebateApp());
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('질문하고, 토론하고, 기록하는 마법의 소라고동'), findsOneWidget);
      expect(find.bySemanticsLabel('카카오 로그인'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: '메인 메뉴 폭 $width');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });

  testWidgets('홈에서 프로필 화면으로 이동하고 로그아웃할 수 있다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(home: MagicConchHomeScreen(user: AppUser.fallback)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('계정 정보'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('계정정보'), findsOneWidget);
    expect(find.text('Sora Demo'), findsOneWidget);
    expect(find.text('demo@magicsora.app'), findsWidgets);

    await tester.ensureVisible(find.text('로그아웃'));
    await tester.tap(find.text('로그아웃'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('질문하고, 토론하고, 기록하는 마법의 소라고동'), findsOneWidget);
  });

  testWidgets('질문 기록 항목에서 이전 답변 보기 액션을 열 수 있다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(home: MagicConchHomeScreen(user: AppUser.fallback)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('질문 기록'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('나는 사람이다'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('이전 답변 보기'), findsOneWidget);
    expect(find.text('이어서 질문하기'), findsOneWidget);

    await tester.tap(find.text('이전 답변 보기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('이전에 받은 답변'), findsOneWidget);
  });

  testWidgets('질문 기록 항목에서 이어서 질문하기를 시작할 수 있다', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(home: MagicConchHomeScreen(user: AppUser.fallback)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('질문 기록'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('나는 사람이다'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('이어서 질문하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    expect(find.text('질문 이어가기'), findsOneWidget);
    expect(find.text('추가 질문 보내기'), findsOneWidget);
  });
}
