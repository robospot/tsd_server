import 'package:tsd/model/dm.dart';
import 'package:tsd/model/packList.dart';
import 'package:tsd/tsd.dart';

class PackListController extends ResourceController {
  PackListController(this.context);
  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllPackList() async {
    final query = Query<PackList>(context);
    return Response.ok(await query.fetch());
  }

  @Operation.post()
  Future<Response> addPackList(@Bind.body() PackList pl) async {
    
    //Проверяем на существование SSCC
    var query3 = Query<Dm>(context)
    ..where((data) => data.sscc).equalTo(pl.sscc);
    final Dm checkData = await query3.fetchOne();
    if (checkData == null){
      return Response.badRequest(body: 'Запрошенного SSCC кода не существует');
    }


    //Проверяем на наличие связки PL + SSCC, если такой нет - добавляем в БД, иначе удаляем
    var query = Query<PackList>(context)
      // ..where((data) => data.packList).equalTo(pl.packList)
      ..where((data) => data.sscc).equalTo(pl.sscc);
    PackList _packList = await query.fetchOne();
    
    if (_packList == null) {
      //Добавляем в БД
      var query2 = Query<PackList>(context)
        ..values.packList = pl.packList
        ..values.sscc = pl.sscc;
      return Response.ok(await query2.insert());
    } else {
      // Если SSCC уже существует то проверяем паклист если совпадает - удаляем из БД иначе сообщение об ошибке
      if (_packList.packList == pl.packList){
      //Удаляем из БД
      final query2 = Query<PackList>(context)
        ..where((data) => data.sscc).equalTo(pl.sscc);
      return Response.ok(await query2.delete());
      }
      else 
      return Response.badRequest(body: 'SSCC код уже включен в упаковочный лист ${_packList.packList}');
    }
  }
//Отдаем перечень SSCC по коду паклиста
  @Operation.get('id')
  Future<Response> getPackListById(@Bind.path("id") String plCode) async {
    final query = Query<PackList>(context)
      ..where((u) => u.packList).equalTo(plCode)
      ..returningProperties((u) => [u.sscc]);
      
    return Response.ok(await query.fetch());
  }
}
