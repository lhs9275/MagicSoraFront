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
}
