import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

const _helpText = Color(0xFF30476D);
const _helpLineStrong = Color(0xFFC7D4E9);
const _helpTeal = Color(0xFF75D6E6);
const _helpTealStrong = Color(0xFF4A69AA);
const _helpIconBgTop = Color(0xFFF9FBFF);
const _helpIconBgBottom = Color(0xFFEBF1FF);

/// 계정 설정 > 도움말 항목에서 진입하는 사용법 안내 화면.
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const List<_HelpSection> _sections = [
    _HelpSection(
      icon: Icons.lightbulb_outline_rounded,
      title: '시작하기',
      body:
          '홈 화면에서 궁금한 주제나 질문을 입력하고 전송 버튼을 누르거나 소라고동 줄을 오른쪽으로 당기면 토론이 시작돼요. '
          '주제는 한 문장으로 짧고 분명하게 적을수록 좋은 답을 받기 쉬워요.',
    ),
    _HelpSection(
      icon: Icons.forum_outlined,
      title: '토론 결과 읽기',
      body:
          'AI가 찬성·반대 입장으로 의견을 주고받은 뒤 마법의 소라고동이 최종 답을 들려줘요. '
          '답변 카드를 누르면 평가 결과(점수, 우세 의견)를 더 자세히 볼 수 있어요.',
    ),
    _HelpSection(
      icon: Icons.add_comment_outlined,
      title: '추가 질문 이어가기',
      body:
          '결과 화면 아래의 "추가로 질문하기"를 누르면 같은 주제로 이어서 물어볼 수 있어요. '
          '추가 질문은 분당 5회까지 가능하고, 토론이 끝난 뒤에만 받을 수 있어요.',
    ),
    _HelpSection(
      icon: Icons.history_rounded,
      title: '질문 기록 다시 보기',
      body:
          '홈 좌측의 "질문 기록"이나 모바일에서 상단의 기록 버튼을 누르면 이전 질문과 답을 다시 펼쳐볼 수 있어요. '
          '여기서 같은 질문을 한 번 더 던지거나 다른 입장으로 바꿔서 던질 수도 있어요.',
    ),
    _HelpSection(
      icon: Icons.account_circle_outlined,
      title: '계정 / 닉네임',
      body:
          '계정 정보 화면에서 닉네임을 바꾸거나 로그아웃할 수 있어요. '
          '닉네임은 토론 화면 우측 상단에 표시되고, 카카오 로그인을 쓰면 카카오 계정에서 가져온 이름이 기본으로 들어가요.',
    ),
    _HelpSection(
      icon: Icons.tips_and_updates_outlined,
      title: '좋은 질문 만드는 팁',
      body:
          '하나의 입장이 분명한 찬반형 주제일 때 결과 품질이 가장 좋아요. '
          '예: "교복 자율화는 학생에게 좋은가?", "AI 그림은 예술인가?" 처럼 한 문장으로 좁히면 답이 더 또렷해져요.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 22.0;
            final verticalPadding = constraints.maxHeight < 700 ? 18.0 : 26.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                verticalPadding,
                horizontalPadding,
                32,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _HelpTopBar(),
                      const SizedBox(height: 18),
                      const _HelpIntro(),
                      const SizedBox(height: 18),
                      for (final section in _sections) ...[
                        _HelpCard(section: section),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 4),
                      const _HelpFootnote(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HelpTopBar extends StatelessWidget {
  const _HelpTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HelpBackButton(onPressed: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '도움말',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _helpText,
              fontSize: 28,
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _HelpBackButton extends StatelessWidget {
  const _HelpBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '뒤로가기',
      child: Material(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          highlightColor: _helpTeal.withValues(alpha: 0.08),
          splashColor: _helpTeal.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _helpLineStrong),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_helpIconBgTop, _helpIconBgBottom],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x144C8ED4),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _helpTealStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpSection {
  const _HelpSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _HelpIntro extends StatelessWidget {
  const _HelpIntro();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '마법의 소라고동, 어떻게 쓰나요?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 6가지 가이드만 훑어보면 토론, 추가 질문, 기록 다시 보기까지 한 번에 익힐 수 있어요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.section});

  final _HelpSection section;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.skyBlue.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppTheme.skyBlue.withValues(alpha: 0.32),
              ),
            ),
            child: Icon(section.icon, color: AppTheme.primaryDark, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  section.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpFootnote extends StatelessWidget {
  const _HelpFootnote();

  @override
  Widget build(BuildContext context) {
    return Text(
      '더 궁금한 점이 있다면 운영자에게 알려주세요. 함께 다듬어 갈게요.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
