import 'package:tsd/model/dm.dart';
import 'package:tsd/model/sscc.dart';
import 'package:tsd/model/user.dart';

import '../tsd.dart';

class DmController extends ResourceController {
  DmController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllDm() async {
    final query = Query<Dm>(context);
    query.sortBy((dm) => dm.datamatrix, QuerySortOrder.ascending);
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(await query.fetch());
  }

  @Operation.put()
  Future<Response> updateDm(@Bind.body() Dm dm) async {
    //Проверка на принадлежность организации
    final queryUser = Query<User>(context)
      ..where((user) => user.id).identifiedBy(request.authorization.ownerID);

    final User user = await queryUser.fetchOne();

//Блок проверок на коды
    final query1 = Query<Dm>(context)
      ..where((u) => u.datamatrix).equalTo(dm.datamatrix)
      ..where((x) => x.organization).equalTo(user.vendororg.id);
    final Dm checkIsUsed = await query1.fetchOne();
    //Проверяем на соответствие DM и EAN
    if (checkIsUsed == null) {
      return Response.badRequest(body: 'Datamatrix не найден');
    } else if (checkIsUsed.ean != dm.ean) {
      return Response.badRequest(body: 'Datamatrix не соответствует EAN');
    } else
    //Проверяем использована ли DM ранее
    if (checkIsUsed.isUsed == true) {
      return Response.badRequest(body: 'Datamatrix уже был использован');
    } else {
      //Если DM не была использована, сохраняем
      final query2 = Query<Dm>(context)
        
        ..values.organization = user.vendororg.id
        ..values.sscc = dm.sscc
        ..values.isUsed = true
        ..where((u) => u.datamatrix).equalTo(dm.datamatrix);

      await query2.updateOne();
//Подсчет кол-ва КМ по SSCC
      final query3 = Query<Dm>(context)
        ..where((u) => u.sscc).equalTo(dm.sscc)
        ..where((u) => u.isUsed).equalTo(true);
      final int ssccCount = await query3.reduce.count() ?? 0;

//Подсчет кол-ва КМ по EAN
      final query4 = Query<Dm>(context)
        ..where((x) => x.sscc).equalTo(dm.sscc)
        ..where((u) => u.ean).equalTo(dm.ean)
        ..where((u) => u.isUsed).equalTo(true);
      final int eanCount = await query4.reduce.count() ?? 0;

//Передача подсчета
      final object = Sscc();
      object.ssccCount = ssccCount;
      object.eanCount = eanCount;
      final Map<String, dynamic> map = object.asMap();
      return Response.ok(map);
    }
  }

  // Очистка таблицы
  @Operation.delete()
  Future<Response> clearDmTable() async {
    final query = Query<Dm>(context)..canModifyAllInstances = true;
    await query.delete();

    return Response.ok('Таблица очищена');
  }
}
