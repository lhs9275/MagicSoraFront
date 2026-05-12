import 'package:flutter_test/flutter_test.dart';
import 'package:magicsorafront/app/app.dart';

void main() {
  testWidgets('앱 첫 화면으로 로그인 화면이 렌더링된다', (tester) async {
    // 최상위 앱을 띄운 뒤 로그인 폼의 핵심 요소가 보이는지 확인한다.
    await tester.pumpWidget(const DebateApp());

    expect(find.text('로그인'), findsOneWidget);
    expect(find.text('로그인 후 시작하기'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);
  });

  testWidgets('홈에서 프로필 화면으로 이동하고 로그아웃할 수 있다', (tester) async {
    // 데모 진입 버튼으로 홈 화면에 들어간 뒤 프로필 데모 버튼을 누른다.
    await tester.pumpWidget(const DebateApp());

    await tester.tap(find.text('계정 없이 둘러보기'));
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

    expect(find.text('로그인'), findsOneWidget);
  });
}
