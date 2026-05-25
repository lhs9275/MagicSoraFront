import 'package:flutter/material.dart';
import 'package:magicsorafront/core/theme/app_theme.dart';
import 'package:magicsorafront/core/widgets/ocean_shell_widgets.dart';
import 'package:magicsorafront/features/auth/controllers/login_controller.dart';
import 'package:magicsorafront/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:magicsorafront/features/home/presentation/screens/magic_conch_home_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  void _openSignUp(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SignUpScreen()));
  }

  void _openGuest(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MagicConchHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OceanShellBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 380 ? 16.0 : 20.0;
            const topPadding = 28.0;
            const bottomPadding = 28.0;
            final minHeight =
                constraints.maxHeight - topPadding - bottomPadding;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                bottomPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minHeight > 0 ? minHeight : 0,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _BrandBlock(),
                        const SizedBox(height: 22),
                        _AuthActionPanel(
                          onSignUp: () => _openSignUp(context),
                          onLoginSuccess: () => _openGuest(context),
                          onGuest: () => _openGuest(context),
                        ),
                      ],
                    ),
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

class _BrandBlock extends StatelessWidget {
  const _BrandBlock();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTight = constraints.maxWidth < 340;
        final targetConchWidth = isTight ? 252.0 : 296.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : targetConchWidth;
        final conchWidth = availableWidth < targetConchWidth
            ? availableWidth
            : targetConchWidth;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/brand/magic_conch.png',
              width: conchWidth,
              height: conchWidth * 0.72,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              '질문하고, 토론하고, 기록하는 마법의 소라고동',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AuthActionPanel extends StatelessWidget {
  const _AuthActionPanel({
    required this.onSignUp,
    required this.onLoginSuccess,
    required this.onGuest,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLoginSuccess;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return _InlineLoginPanel(
      onSignUp: onSignUp,
      onLoginSuccess: onLoginSuccess,
      onGuest: onGuest,
    );
  }
}

class _InlineLoginPanel extends StatefulWidget {
  const _InlineLoginPanel({
    required this.onSignUp,
    required this.onLoginSuccess,
    required this.onGuest,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLoginSuccess;
  final VoidCallback onGuest;

  @override
  State<_InlineLoginPanel> createState() => _InlineLoginPanelState();
}

class _InlineLoginPanelState extends State<_InlineLoginPanel> {
  static const _kakaoLoginAsset = 'assets/images/auth/kakao_login_medium.png';

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _loginController.submitLogin(
      email: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));

    if (!result.isSuccess) {
      return;
    }

    widget.onLoginSuccess();
  }

  void _submitKakaoLogin() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('카카오 로그인은 준비 중입니다.')));
  }

  @override
  Widget build(BuildContext context) {
    return OceanPanel(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '시작하기',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 18),
              ShellTextField(
                controller: _identifierController,
                labelText: '아이디',
                hintText: '아이디 입력',
                icon: Icons.person_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.username],
                autocorrect: false,
                validator: _loginController.validateIdentifier,
              ),
              const SizedBox(height: 12),
              ShellTextField(
                controller: _passwordController,
                labelText: '비밀번호',
                hintText: '8자 이상 입력',
                icon: Icons.lock_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLogin(),
                autofillHints: const [AutofillHints.password],
                autocorrect: false,
                enableSuggestions: false,
                validator: _loginController.validatePassword,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _KakaoLoginButton(
                      assetPath: _kakaoLoginAsset,
                      onPressed: _submitKakaoLogin,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OceanPillButton(
                      label: '로그인',
                      icon: Icons.login_rounded,
                      backgroundColor: AppTheme.shellPurple,
                      isLoading: _isSubmitting,
                      onPressed: _isSubmitting ? null : _submitLogin,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 8,
                children: [
                  _TextLink(label: '회원가입', onTap: widget.onSignUp),
                  Text(
                    '/',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _TextLink(label: '비로그인으로 사용', onTap: widget.onGuest),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({required this.assetPath, required this.onPressed});

  final String assetPath;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '카카오 로그인',
      button: true,
      child: Material(
        color: const Color(0xFFFEE500),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onPressed,
          child: SizedBox(
            height: 58,
            child: Center(
              child: Image.asset(assetPath, height: 45, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

class _TextLink extends StatelessWidget {
  const _TextLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
