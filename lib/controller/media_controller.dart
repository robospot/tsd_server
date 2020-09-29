import 'dart:async';
import 'dart:io';

import 'package:aqueduct/aqueduct.dart';
import 'package:excel/excel.dart';
import 'package:mime/mime.dart';
import 'package:http_server/http_server.dart';
import 'package:tsd/model/dm.dart';

class MediaController extends ResourceController {
  MediaController(this.context) {
    acceptedContentTypes = [ContentType("multipart", "form-data")];
  }

  final ManagedContext context;

  @Operation.post()
  Future<Response> postMultipartForm() async {
    final transformer = MimeMultipartTransformer(
        request.raw.headers.contentType.parameters["boundary"]);

    final bodyStream =
        Stream.fromIterable([await request.body.decode<List<int>>()]);
    final parts = await transformer.bind(bodyStream).toList();

    for (var part in parts) {
      final HttpMultipartFormData multipart = HttpMultipartFormData.parse(part);

      final List<String> tokens =
          part.headers['content-disposition'].split(";");
      String filename;
      for (var i = 0; i < tokens.length; i++) {
        if (tokens[i].contains('filename')) {
          filename = tokens[i]
              .substring(tokens[i].indexOf("=") + 2, tokens[i].length - 1);
        }
      }
      print('file $filename uploaded');

      final content = multipart.cast<List<int>>();

      final filePath =
          // "public/" + DateTime.now().millisecondsSinceEpoch.toString() + ".jpg";
          'public/$filename';

      final IOSink sink = File(filePath).openWrite();
      await for (List<int> item in content) {
        sink.add(item);
      }
      await sink.flush();
      await sink.close();

      var file = filePath;
      var bytes = File(file).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        excel.tables[table].removeRow(0);
        for (var row in excel.tables[table].rows) {
          final t = row.asMap();
          print(t);

          if (t[0] != null) {
            try {
              final query = Query<Dm>(context)
                ..values.organization = t[0] as int
                ..values.ean = t[1].toString()
                ..values.datamatrix = t[2].toString();
              final dm = await query.insert();
            } catch (e) {print('Not unique row');}
          }
        }
      }
    }

    return Response.ok({});
  }
}
