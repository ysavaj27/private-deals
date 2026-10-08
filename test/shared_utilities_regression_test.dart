import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:private_deals/src/features/institution/support/extensions/num_extensions.dart'
    as institution;
import 'package:private_deals/src/features/institution/support/functions/parse.dart'
    as institution_parse;
import 'package:private_deals/src/shared/extensions/num_extensions.dart';
import 'package:private_deals/src/shared/functions/parse.dart';

void main() {
  final originalLocale = Intl.defaultLocale;
  tearDown(() => Intl.defaultLocale = originalLocale);

  test(
    'currency and number output retain grouping, rounding and empty values',
    () {
      Intl.defaultLocale = 'en_US';
      expect(1234567.89.toCurrency, '₹ 12,34,567.89');
      expect(1234567.89.toShowNum, '12,34,567.89');
      expect(12.345.toCurrency, '₹ 12.35');
      expect(100.toCurrency, '₹ 100');
      expect(0.toCurrency, '-');
      expect((-1).toShowNum, '-');
      expect(institution.FancyNum(1234567.89).toCurrency, '₹ 12,34,567.89');
    },
  );

  test('cached number formatting follows locale changes and switches back', () {
    Intl.defaultLocale = 'en_US';
    expect(1234.5.toShowNum, '1,234.5');
    Intl.defaultLocale = 'de_DE';
    expect(1234.5.toShowNum, '1.234,5');
    Intl.defaultLocale = 'en_US';
    expect(1234.5.toShowNum, '1,234.5');
  });

  test('shared and Institution parsing keep defaults and enum behavior', () {
    expect(Parse.toInt('42'), 42);
    expect(institution_parse.Parse.toInt(null, 7), 7);
    expect(institution_parse.Parse.toDouble('12.5'), 12.5);
    expect(institution_parse.Parse.toBool('1'), isTrue);
    expect(institution_parse.Parse.toBool(true), isTrue);
    expect(institution_parse.Parse.toBool('true'), isFalse);
    expect(institution_parse.Parse.toStrings(null, 'N/A'), 'N/A');
    expect(institution_parse.Parse.toDateTime('invalid'), DateTime(0));
    expect(
      institution_parse.Parse.toDateTime('2026-10-07T10:30:00Z'),
      DateTime.utc(2026, 10, 7, 10, 30).toLocal(),
    );
    expect(
      institution_parse.Parse.toEnum(
        TestMode.values,
        'LIVE',
        defaultValue: TestMode.draft,
      ),
      TestMode.live,
    );
    expect(
      institution_parse.Parse.toEnum(
        TestMode.values,
        'unknown',
        defaultValue: TestMode.draft,
      ),
      TestMode.draft,
    );
  });
}

enum TestMode { draft, live }
