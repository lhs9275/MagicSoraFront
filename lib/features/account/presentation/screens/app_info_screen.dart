import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';

const _infoText = Color(0xFF30476D);
const _infoTextMuted = Color(0xFF6C7C9B);
const _infoLineStrong = Color(0xFFC7D4E9);
const _infoTeal = Color(0xFF75D6E6);
const _infoTealStrong = Color(0xFF4A69AA);
const _infoIconBgTop = Color(0xFFF9FBFF);
const _infoIconBgBottom = Color(0xFFEBF1FF);

const _appDisplayName = '마법의 소라고동';
const _appVersion = 'v1.0.0';
const _appLegalName = '마법의 소라고동 (Magic Sora Debate)';

/// 계정 설정 > 앱 정보 화면. 버전, 약관, 개인정보, 오픈소스 라이선스를 모아 보여준다.
class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

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
                      const _AppInfoTopBar(),
                      const SizedBox(height: 18),
                      const _AppInfoHero(),
                      const SizedBox(height: 16),
                      _AppInfoMenuPanel(
                        onTerms: () => _openTextScreen(
                          context,
                          title: '이용약관',
                          sections: _termsSections,
                        ),
                        onPrivacy: () => _openTextScreen(
                          context,
                          title: '개인정보 처리방침',
                          sections: _privacySections,
                        ),
                        onLicenses: () => showLicensePage(
                          context: context,
                          applicationName: _appDisplayName,
                          applicationVersion: _appVersion,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _AppInfoFootnote(),
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

  void _openTextScreen(
    BuildContext context, {
    required String title,
    required List<_LegalSection> sections,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LegalDocumentScreen(title: title, sections: sections),
      ),
    );
  }
}

class _AppInfoTopBar extends StatelessWidget {
  const _AppInfoTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AppInfoBackButton(onPressed: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            '앱 정보',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _infoText,
              fontSize: 28,
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

class _AppInfoBackButton extends StatelessWidget {
  const _AppInfoBackButton({required this.onPressed});

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
          highlightColor: _infoTeal.withValues(alpha: 0.08),
          splashColor: _infoTeal.withValues(alpha: 0.12),
          onTap: onPressed,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _infoLineStrong),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_infoIconBgTop, _infoIconBgBottom],
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
              color: _infoTealStrong,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppInfoHero extends StatelessWidget {
  const _AppInfoHero();

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      child: Column(
        children: [
          Container(
            width: 86,
            height: 86,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_infoIconBgTop, _infoIconBgBottom],
              ),
              border: Border.all(color: _infoLineStrong),
            ),
            child: Image.asset(
              'assets/images/brand/magic_conch.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _appDisplayName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _appVersion,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _infoTextMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '질문하고, 토론하고, 기록하는 마법의 소라고동',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppInfoMenuPanel extends StatelessWidget {
  const _AppInfoMenuPanel({
    required this.onTerms,
    required this.onPrivacy,
    required this.onLicenses,
  });

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;
  final VoidCallback onLicenses;

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Column(
        children: [
          _AppInfoMenuTile(
            icon: Icons.description_outlined,
            title: '이용약관',
            subtitle: '서비스 이용 시 알아둘 점',
            onTap: onTerms,
          ),
          const _AppInfoDivider(),
          _AppInfoMenuTile(
            icon: Icons.shield_outlined,
            title: '개인정보 처리방침',
            subtitle: '수집·이용되는 정보 안내',
            onTap: onPrivacy,
          ),
          const _AppInfoDivider(),
          _AppInfoMenuTile(
            icon: Icons.code_rounded,
            title: '오픈소스 라이선스',
            subtitle: '사용된 패키지 목록',
            onTap: onLicenses,
          ),
        ],
      ),
    );
  }
}

class _AppInfoMenuTile extends StatelessWidget {
  const _AppInfoMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      highlightColor: _infoTeal.withValues(alpha: 0.08),
      splashColor: _infoTeal.withValues(alpha: 0.1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_infoIconBgTop, _infoIconBgBottom],
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _infoLineStrong),
              ),
              child: Icon(icon, color: _infoTealStrong, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _infoText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: _infoTextMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: _infoTealStrong,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppInfoDivider extends StatelessWidget {
  const _AppInfoDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        height: 1,
        color: _infoLineStrong.withValues(alpha: 0.5),
      ),
    );
  }
}

class _AppInfoFootnote extends StatelessWidget {
  const _AppInfoFootnote();

  @override
  Widget build(BuildContext context) {
    return Text(
      '© $_appLegalName',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}

class _LegalDocumentScreen extends StatelessWidget {
  const _LegalDocumentScreen({required this.title, required this.sections});

  final String title;
  final List<_LegalSection> sections;

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
                      _LegalTopBar(title: title),
                      const SizedBox(height: 18),
                      OceanPanel(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < sections.length; i++) ...[
                              Text(
                                sections[i].title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppTheme.primaryDark,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sections[i].body,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      height: 1.6,
                                    ),
                              ),
                              if (i != sections.length - 1) ...[
                                const SizedBox(height: 18),
                                Container(
                                  height: 1,
                                  color:
                                      _infoLineStrong.withValues(alpha: 0.5),
                                ),
                                const SizedBox(height: 18),
                              ],
                            ],
                          ],
                        ),
                      ),
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

class _LegalTopBar extends StatelessWidget {
  const _LegalTopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AppInfoBackButton(onPressed: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: _infoText,
              fontSize: 26,
              height: 1.08,
            ),
          ),
        ),
      ],
    );
  }
}

const List<_LegalSection> _termsSections = [
  _LegalSection(
    title: '1. 서비스 소개',
    body:
        '"마법의 소라고동"은 학생이 다양한 주제로 AI와 토론하고, 그 결과를 기록·재방문할 수 있도록 돕는 학습용 도구입니다. '
        '이 약관은 본 서비스를 이용하는 사용자와 운영자 사이의 권리·의무를 안내합니다.',
  ),
  _LegalSection(
    title: '2. 계정과 이용 자격',
    body:
        '서비스 일부 기능(질문 기록, 추가 질문 등)은 로그인이 필요합니다. 카카오 계정 또는 이메일/비밀번호로 가입할 수 있습니다. '
        '교실에서 단체로 이용하는 경우 교사·운영자의 안내를 따라주세요.',
  ),
  _LegalSection(
    title: '3. 콘텐츠 책임',
    body:
        'AI가 생성한 응답은 항상 정확하지 않을 수 있어요. 토론 결과나 평가 점수는 참고용 자료로만 활용하고, '
        '학교 과제·논문 등 공식 자료에 인용할 때는 반드시 본인의 검증을 거치도록 합니다.',
  ),
  _LegalSection(
    title: '4. 금지 행위',
    body:
        '욕설·차별 표현·타인 비방·불법 정보 요청 등은 금지됩니다. 부적절한 요청이 감지될 경우 서비스 이용이 제한될 수 있어요.',
  ),
  _LegalSection(
    title: '5. 서비스 변경과 종료',
    body:
        '운영자는 서비스 품질을 위해 일부 기능을 추가하거나 중단할 수 있습니다. 큰 변경이 있을 때는 앱 안에서 미리 알려드릴게요.',
  ),
];

const List<_LegalSection> _privacySections = [
  _LegalSection(
    title: '1. 수집하는 정보',
    body:
        '서비스 이용을 위해 다음 정보를 수집합니다. (1) 카카오 로그인 시 카카오에서 제공하는 닉네임·프로필 사진·이메일 일부, '
        '(2) 사용자가 직접 입력한 질문과 토론 기록, (3) 알림·글자 크기 등 환경 설정 값.',
  ),
  _LegalSection(
    title: '2. 정보 이용 목적',
    body:
        '수집한 정보는 (1) 로그인과 본인 확인, (2) 토론 결과 저장과 추후 재조회, (3) 서비스 품질 개선과 오류 디버깅을 위해 사용합니다. '
        '광고 목적의 외부 공유는 하지 않습니다.',
  ),
  _LegalSection(
    title: '3. 보관과 파기',
    body:
        '계정 정보는 회원 탈퇴 또는 운영자에게 삭제 요청 시 즉시 파기합니다. '
        '토론 기록은 학생 본인이 언제든 삭제할 수 있고, 장기간 미접속 시에는 안내 후 정리될 수 있어요.',
  ),
  _LegalSection(
    title: '4. 사용자 권리',
    body:
        '본인의 정보 열람·정정·삭제를 언제든 요청할 수 있습니다. '
        '계정 정보 화면에서 닉네임을 직접 바꿀 수 있고, 로그아웃 후 운영자에게 계정 삭제를 요청할 수 있어요.',
  ),
  _LegalSection(
    title: '5. 문의처',
    body:
        '개인정보 관련 문의는 운영자에게 직접 알려주세요. 빠르게 확인해 답변해 드리겠습니다.',
  ),
];
