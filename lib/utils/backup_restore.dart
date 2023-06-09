
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';

class BackupRestore {

  static Future<List<FileSystemEntity>> getFilesFromDir(String directoryPath) async {
    var dir = (await getApplicationDocumentsDirectory()).path;
    var directory = dir + directoryPath;
    var filesList = Directory("$directory").listSync(); //use your folder name insted of resume.
    return filesList;
  }

  static  String zipFile({
    required String zipFileSavePath,
    required String zipFileName,
    required List<File> fileToZips,
  }) {
    final ZipFileEncoder encoder = ZipFileEncoder();
    // Manually create a zip at the zipFilePath
    List<String> files = [zipFileSavePath, zipFileName];
    final String zipFilePath = files.join();
    encoder.create(zipFilePath);
    // Add all the files to the zip file
    for (final File fileToZip in fileToZips) {
      encoder.addFile(fileToZip);
    }
    encoder.close();
    return zipFilePath;
  }

  static Future<File> unzipFile({
    required File zipFile,
    required String extractToPath,
  }) async {
    // Read the Zip file from disk.
    final bytes = await zipFile.readAsBytes();
    File? filePath;
    // Decode the Zip file
    final Archive archive = ZipDecoder().decodeBytes(bytes);
    // Extract the contents of the Zip archive to extractToPath.
    for (final ArchiveFile file in archive) {
      final String filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        filePath = File('$extractToPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        // it should be a directory
        Directory('$extractToPath/$filename').create(recursive: true);
      }
    }
    return filePath!;
  }

  static Future<File> changeFileNameOnly(File file, String newFileName ) async {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }
}