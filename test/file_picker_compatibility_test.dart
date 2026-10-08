import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:private_deals/src/features/institution/data/models/common/enums.dart'
    as institution_model;
import 'package:private_deals/src/features/institution/support/plugins/file_picker.dart'
    as institution;
import 'package:private_deals/src/shared/models/enums.dart';
import 'package:private_deals/src/shared/plugins/file_picker.dart';

class _Picker extends FilePickerPlatform {
  PlatformFile? single;
  List<PlatformFile> multiple = [];
  int singleCalls = 0;
  int multipleCalls = 0;
  FileType? requestedType;
  List<String>? requestedExtensions;

  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    singleCalls++;
    requestedType = type;
    requestedExtensions = allowedExtensions;
    return single;
  }

  @override
  Future<List<PlatformFile>> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    multipleCalls++;
    requestedType = type;
    requestedExtensions = allowedExtensions;
    return multiple;
  }
}

// Simulates browser files, which have no local path or eager bytes field.
final class _PickedFile extends PlatformFile {
  _PickedFile(this.name, List<int> bytes, {this.failRead = false})
    : _bytes = Uint8List.fromList(bytes);

  @override
  final String name;
  final Uint8List _bytes;
  final bool failRead;
  int reads = 0;

  @override
  Uri get uri => Uri.parse('blob:https://example.test/$name');

  @override
  get xFile => throw UnimplementedError();

  @override
  int? lengthSync() => null;

  @override
  Future<int?> length() async => _bytes.length;

  @override
  Future<Uint8List> readAsBytes() async {
    reads++;
    if (failRead) throw StateError('File could not be read');
    return _bytes;
  }

  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(_bytes);
}

void main() {
  late FilePickerPlatform original;
  late _Picker platform;

  setUp(() {
    original = FilePickerPlatform.instance;
    platform = _Picker();
    FilePickerPlatform.instance = platform;
  });

  tearDown(() => FilePickerPlatform.instance = original);

  for (final useInstitution in [false, true]) {
    final name = useInstitution ? 'Institution' : 'Partner';
    final pickFile = useInstitution
        ? institution.FilePickers().pickFile
        : FilePickers().pickFile;

    test('$name reads single browser files and preserves filters', () async {
      final file = _PickedFile('prices.csv', [1, 2, 3]);
      platform.single = file;
      final files = await pickFile(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      expect(platform.singleCalls, 1);
      expect(platform.multipleCalls, 0);
      expect(platform.requestedType, FileType.custom);
      expect(platform.requestedExtensions, ['csv']);
      expect(file.path, isNull);
      expect(file.reads, 1);
      final dynamic media = files.single;
      expect(media.name, 'prices.csv');
      expect(media.uint8list, [1, 2, 3]);
      expect(
        media.dataType,
        useInstitution
            ? institution_model.FileDataType.bytes
            : FileDataType.bytes,
      );
    });

    test('$name preserves all selected files and their order', () async {
      platform.multiple = [
        _PickedFile('first.pdf', [1]),
        _PickedFile('second.pdf', [2, 3]),
      ];
      final files = await pickFile(multiple: true);

      expect(platform.singleCalls, 0);
      expect(platform.multipleCalls, 1);
      expect(files.map((dynamic file) => file.name), [
        'first.pdf',
        'second.pdf',
      ]);
      expect(files.map((dynamic file) => file.uint8list), [
        [1],
        [2, 3],
      ]);
    });

    test('$name treats single and multiple cancellation as empty', () async {
      expect(await pickFile(), isEmpty);
      expect(await pickFile(multiple: true), isEmpty);
    });

    test(
      '$name reports read errors instead of dropping selected files',
      () async {
        platform.single = _PickedFile('unreadable.pdf', [], failRead: true);
        await expectLater(pickFile(), throwsStateError);
      },
    );
  }
}
