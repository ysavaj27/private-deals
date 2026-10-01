import 'package:private_deals/src/shared/app_exports.dart';
import 'package:private_deals/src/app/routing/session_navigation.dart';
import 'package:private_deals/src/shared/widgets/partner_shell.dart';

class SessionRetryPage extends StatelessWidget {
  const SessionRetryPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                const Text('We could not verify your session.'),
                const SizedBox(height: 12),
                Text(app.sessionError(), textAlign: TextAlign.center),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: app.restoring()
                      ? null
                      : () async {
                          await app.restore();
                          SessionNavigation.goHome();
                        },
                  child: Text(app.restoring() ? 'Checking…' : 'Retry'),
                ),
                TextButton(
                  onPressed: () async {
                    await app.clear();
                    Get.offAllNamed(Routes.signIn);
                  },
                  child: const Text('Sign in again'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, size: 48),
            const SizedBox(height: 20),
            Text(
              Get.parameters['reason'] == 'account'
                  ? 'Your account is unavailable. Please contact support.'
                  : Get.parameters['reason'] == 'role'
                  ? 'This account type is not supported. Please contact support.'
                  : 'Your role does not have access to this page.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (Get.parameters['reason'] == null)
              FilledButton(
                onPressed: () =>
                    Get.offAllNamed(SessionNavigation.destination()),
                child: const Text('Go to my dashboard'),
              ),
            TextButton(
              onPressed: SessionNavigation.logout,
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});
  @override
  Widget build(BuildContext context) => PartnerShell(
    title: 'My account',
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(app.wUser.name, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        Text(app.wUser.email),
        const SizedBox(height: 8),
        Text(app.wUser.mobileNumber.toString()),
        const SizedBox(height: 8),
        Text(app.role.apiValue),
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton(
            onPressed: () => Get.toNamed(Routes.changePassword),
            child: const Text('Change password'),
          ),
        ),
      ],
    ),
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Page not found'),
          TextButton(
            onPressed: SessionNavigation.goHome,
            child: const Text('Go home'),
          ),
        ],
      ),
    ),
  );
}
