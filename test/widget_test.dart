import 'package:flutter_test/flutter_test.dart';
import 'package:magicsorafront/app/app.dart';

void main() {
  testWidgets('앱 첫 화면으로 인증 메뉴가 렌더링된다', (tester) async {
    await tester.pumpWidget(const DebateApp());

    expect(find.text('magic sora'), findsOneWidget);
    expect(find.text('시작하기'), findsOneWidget);
    expect(find.text('회원가입'), findsOneWidget);
    expect(find.text('로그인으로 사용'), findsOneWidget);
    expect(find.text('비로그인으로 사용'), findsOneWidget);
  });

  testWidgets('인증 메뉴에서 로그인 화면으로 이동할 수 있다', (tester) async {
    await tester.pumpWidget(const DebateApp());

    await tester.tap(find.text('로그인으로 사용'));
    await tester.pumpAndSettle();

    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('로그인으로 시작'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
    expect(find.text('계정 없이 둘러보기'), findsOneWidget);
  });

  testWidgets('홈에서 프로필 화면으로 이동하고 로그아웃할 수 있다', (tester) async {
    await tester.pumpWidget(const DebateApp());

    await tester.tap(find.text('비로그인으로 사용'));
    await tester.pumpAndSettle();

    expect(find.text('마법의 소라고동!'), findsOneWidget);
    await tester.ensureVisible(find.text('라운드 대시보드로 이동'));
    await tester.tap(find.text('라운드 대시보드로 이동'));
    await tester.pumpAndSettle();

    expect(find.text('Magic Sora'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);

    await tester.tap(find.text('프로필'));
    await tester.pumpAndSettle();

    expect(find.text('계정'), findsOneWidget);
    expect(find.text('Sora Demo'), findsOneWidget);
    expect(find.text('demo@magicsora.app'), findsOneWidget);

    await tester.ensureVisible(find.text('로그아웃'));
    await tester.tap(find.text('로그아웃'));
    await tester.pumpAndSettle();

    expect(find.text('로그인으로 사용'), findsOneWidget);
  });
}
