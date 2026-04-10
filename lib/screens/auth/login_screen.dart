import 'package:flutter/material.dart';

import '../../features/auth/controllers/login_controller.dart';
import '../home/debate_home_screen.dart';

/// 앱 첫 진입 화면이다. 인증이 완료되면 토론 대시보드로 이동한다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginController = LoginController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 입력값 검증과 임시 인증을 수행한 뒤 다음 화면으로 이동시킨다.
  Future<void> _handleLogin() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = await _loginController.submitLogin(
      email: _emailController.text.trim(),
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DebateHomeScreen()),
    );
  }

  /// 인증 없이 화면 구조만 확인하고 싶을 때 데모 홈으로 바로 이동시킨다.
  void _openPreview() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DebateHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleLogin,
            child: _isSubmitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text('로그인 후 시작하기'),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Magic Sora',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF3182F6),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 52),
                    Text(
                      '로그인',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: 34,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '토론 기록과 개인 설정을 연결하기 위해 먼저 계정을 확인합니다.',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 36),
                    // 화면을 과하게 장식하지 않고 입력 영역만 선명하게 드러낸다.
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E8EB)),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: _loginController.validateEmail,
                            decoration: const InputDecoration(
                              labelText: '이메일',
                              hintText: 'you@example.com',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                            validator: _loginController.validatePassword,
                            decoration: const InputDecoration(
                              labelText: '비밀번호',
                              hintText: '8자 이상 입력',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '현재는 인증 API 연결 전 단계이므로, 형식 검증이 통과되면 데모 홈으로 이동합니다.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF8B95A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: _openPreview,
                        child: const Text('계정 없이 UI만 둘러보기'),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
