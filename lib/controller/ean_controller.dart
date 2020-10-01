import 'package:tsd/model/dm.dart';
import 'package:tsd/model/ean.dart';
import 'package:tsd/model/sscc.dart';
import 'package:excel/excel.dart';
import 'package:mime/mime.dart';
import 'package:http_server/http_server.dart';

import '../tsd.dart';

class EanController extends ResourceController {
  EanController(this.context) {
    acceptedContentTypes = [ContentType("multipart", "form-data")];
  }
  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getEanById(@Bind.path("id") String eanCode) async {
//Подсчет кол-ва КМ по EAN
    final query = Query<Dm>(context)
      ..where((u) => u.ean).equalTo(eanCode)
      ..where((u) => u.isUsed).equalTo(true);
    final int eanCount = await query.reduce.count() ?? 0;
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

//Получаем название EAN
    final query2 = Query<Ean>(context)
      ..where((u) => u.ean).equalTo(eanCode);
    final Ean eanName = await query2.fetchOne();      

    
//Передача подсчета
    final object = Sscc();
    object.eanDescription = eanName?.description;
    object.eanCount = eanCount;
    final Map<String, dynamic> map = object.asMap();
    return Response.ok(map);
  }

  @Operation.get()
  Future<Response> getAllEan() async {
    final query = Query<Ean>(context);

    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(await query.fetch());
  }

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
              final query = Query<Ean>(context)
                ..values.ean = t[0].toString()
                ..values.language = t[1].toString()
                ..values.description = t[2].toString();
              final ean = await query.insert();
            } catch (e) {
              print(e);
            }
          }
        }
      }
    }

    return Response.ok({});
  }
}
