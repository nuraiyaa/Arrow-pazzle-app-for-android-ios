import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  if (args.length < 2) {
    print('Usage: dart extract.dart <inputFile> <outputFile> [type: html|image]');
    return;
  }
  final inputFile = File(args[0]);
  final outputFile = File(args[1]);
  final type = args.length > 2 ? args[2] : 'html';

  final jsonContent = jsonDecode(inputFile.readAsStringSync());
  if (type == 'image') {
    final imageBase64 = jsonContent['image'] as String;
    outputFile.writeAsBytesSync(base64Decode(imageBase64));
    print('Wrote image ${outputFile.path} (${outputFile.lengthSync()} bytes)');
  } else {
    final html = jsonContent['html'] as String;
    outputFile.writeAsStringSync(html);
    print('Wrote html ${outputFile.path} (${outputFile.lengthSync()} bytes)');
  }
}
