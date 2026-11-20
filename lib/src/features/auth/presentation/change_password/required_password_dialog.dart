import 'dart:math' as math;

import 'package:private_deals/src/shared/app_exports.dart';

/// Opens the required password dialog once when an admin-created account
/// still has `ask_password_change` set. The dialog cannot be dismissed.
class RequiredPasswordReset {
  static bool _showing = false;

  static Future<void> maybeShow() async {
    if (_showing || !app.wUser.changePassword) return;
    final context = Get.overlayContext ?? Get.context;
    if (context == null || !context.mounted) return;
    app.pendingRoute = null;
    _showing = true;
    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (_) => const RequiredPasswordDialog(),
      );
    } finally {
      _showing = false;
    }
  }
}

class RequiredPasswordDialog extends StatefulWidget {
  const RequiredPasswordDialog({super.key});

  @override
  State<RequiredPasswordDialog> createState() => _RequiredPasswordDialogState();
}

class _RequiredPasswordDialogState extends State<RequiredPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    final res = await WAuthApi.changePassword(
      _newPassword.text,
      _confirmPassword.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (!res.isSuccess) {
      toast(res.m, MessageEnum.error);
      return;
    }
    if (app.wUser.changePassword) {
      toast(
        'Your password still needs to be changed before you can continue.',
        MessageEnum.error,
      );
      return;
    }
    toast(res.m, MessageEnum.success);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = math.min(440.0, MediaQuery.sizeOf(context).width - 48);
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: SizedBox(
          width: cardWidth,
          child: CustomCardWidget(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set your password',
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This account was created by an administrator and is still using a temporary password. Choose your own password to continue. This step is required, and you will use the new password the next time you sign in.',
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TitleTextField(
                      isRequired: true,
                      name: 'New Password',
                      hintText: 'Enter New Password',
                      controller: _newPassword,
                      obscureText: _hideNew,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        iconSize: 20,
                        splashRadius: 20,
                        onPressed: () => setState(() => _hideNew = !_hideNew),
                        icon: Icon(
                          _hideNew
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TitleTextField(
                      isRequired: true,
                      name: 'Confirm Password',
                      hintText: 'Enter Confirm Password',
                      controller: _confirmPassword,
                      obscureText: _hideConfirm,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _newPassword.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        iconSize: 20,
                        splashRadius: 20,
                        onPressed: () =>
                            setState(() => _hideConfirm = !_hideConfirm),
                        icon: Icon(
                          _hideConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomElevatedButton(
                      height: 48,
                      width: cardWidth - 48,
                      text: 'Save password',
                      analyticsName: 'required_password_save',
                      isLoading: _loading,
                      onPressed: _submit,
                    ),
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
