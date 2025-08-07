import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tech_festival/core/utils/secure_storage.dart';
import 'package:tech_festival/screens/auth/bloc/auth_bloc.dart';
import 'package:tech_festival/screens/auth/bloc/auth_event.dart';
import 'package:tech_festival/screens/auth/bloc/auth_state.dart';
import 'package:tech_festival/screens/nfc_scanner/nfc_scanner_page.dart';
import 'package:tech_festival/widgets/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthBloc _bloc = AuthBloc();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final accessToken =
          await SecStorage().read(key: SecStorageKeys.accessToken);
      if (accessToken?.isNotEmpty == true && accessToken != null) {
        _navigate();
      }
    });
    super.initState();
  }

  final _usernameKey = const TextFieldKey('username');
  final _passwordKey = const TextFieldKey('password');
  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => _bloc,
      child: BlocListener<AuthBloc, AuthState>(
        listener: _listener,
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: _builder,
        ),
      ),
    );
  }

  void _listener(BuildContext context, AuthState state) {
    if (state is LoginSuccess) {
      _navigate();
    } else if (state is LoginError) {
      showToast(
        context: context,
        showDuration: const Duration(seconds: 3),
        builder: (context, overlay) {
          return buildToast(
            context,
            overlay,
            title: 'Алдаа гарлаа',
            subtitle: state.message,
          );
        },
        location: ToastLocation.topCenter,
      );
    }
  }

  Widget _builder(BuildContext context, AuthState state) {
    return Scaffold(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: 100,
              child: Image.asset(
                'assets/images/title.png',
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Form(
                onSubmit: (context, values) {
                  // Get the values individually
                  String? username = _usernameKey[values];
                  String? password = _passwordKey[values];
                  FocusScope.of(context).unfocus();

                  _bloc.add(
                    LoginEvent(
                      username: username ?? '',
                      password: password ?? '',
                    ),
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FormField(
                          key: _usernameKey,
                          label: const SizedBox.shrink(),
                          hint: const Text('Нэвтрэх нэр'),
                          showErrors: const {FormValidationMode.submitted},
                          validator: const NotEmptyValidator(
                              message: 'Заавал оруулах талбар'),
                          child: TextField(
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                          ),
                        ),
                        const Gap(16),
                        FormField(
                          key: _passwordKey,
                          label: const SizedBox.shrink(),
                          hint: const Text('Нууц үг'),
                          showErrors: const {FormValidationMode.submitted},
                          validator: const NotEmptyValidator(
                              message: 'Заавал оруулах талбар'),
                          child: TextField(
                            onTapOutside: (event) {
                              FocusScope.of(context).unfocus();
                            },
                            obscureText: true,
                          ),
                        ),
                      ],
                    ),
                    const Gap(24),
                    FormErrorBuilder(
                      builder: (context, errors, child) {
                        return PrimaryButton(
                          onPressed: errors.isEmpty
                              ? () => context.submitForm()
                              : null,
                          child: state is LoginLoading
                              ? const CircularProgressIndicator(
                                  onSurface: true,
                                  size: 24,
                                )
                              : const Text('Нэвтрэх'),
                        );
                      },
                    )
                  ],
                ),
              ),
            ),
            Container(),
          ],
        ),
      ),
    );
  }

  void _navigate() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NfcScannerPage(),
      ),
    );
  }
}
