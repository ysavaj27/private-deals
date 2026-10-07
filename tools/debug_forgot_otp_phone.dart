import 'dart:convert';
import 'dart:io';

/// Mirrors lib/src/shared/extensions/num_extensions.dart toHidePhoneNo
extension _Hide on int {
  String get toHidePhoneNo {
    final accountNumber = toString();
    if (accountNumber.length <= 2) {
      return accountNumber;
    }
    final masked = '*' * (accountNumber.length - 2);
    final lastTwo = accountNumber.substring(accountNumber.length - 2);
    return masked + lastTwo;
  }
}

void main() {
  // Same defaults as InvestorModel / session when not logged in
  const iUserMobile = 0;
  // Number entered on forgot-password mobile step
  const phoneNoCTRL = '9876543210';
  // Wrong source currently used by OTPWidget / DOtpWidget
  final displayedFromIUser = iUserMobile.toHidePhoneNo;
  // Correct source: the number the user just submitted
  final displayedFromCTRL = (int.tryParse(phoneNoCTRL) ?? 0).toHidePhoneNo;

  final payload = {
    'sessionId': 'd3aa53',
    'runId': 'self-check',
    'hypothesisId': 'A,C,E',
    'location': 'tools/debug_forgot_otp_phone.dart',
    'message': 'forgot-password OTP display sources',
    'data': {
      'iUserMobile': iUserMobile,
      'displayedFromIUser': displayedFromIUser,
      'phoneNoCTRL': phoneNoCTRL,
      'displayedFromCTRL': displayedFromCTRL,
      'bugConfirmed': displayedFromIUser == '0',
      'fixWouldShow': displayedFromCTRL,
    },
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };

  final logFile = File(
    '${Directory.current.path}/.cursor/debug-d3aa53.log',
  );
  logFile.writeAsStringSync('${jsonEncode(payload)}\n', mode: FileMode.append);
  stdout.writeln(jsonEncode(payload));
}
