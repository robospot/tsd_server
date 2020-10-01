import 'package:tsd/model/dm.dart';
import 'package:tsd/model/sscc.dart';

import '../tsd.dart';

class SsccController extends ResourceController {
  SsccController(this.context);

  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getSsccById(@Bind.path("id") String ssccCode) async {

//Подсчет кол-ва КМ по SSCC
    final query = Query<Dm>(context)
      ..where((u) => u.sscc).equalTo(ssccCode)
      ..where((u) => u.isUsed).equalTo(true);
    final int ssccCount = await query.reduce.count() ?? 0;
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

//Передача подсчета      
      final object = Sscc();
      object.ssccCount = ssccCount;
      final Map<String, dynamic> map = object.asMap();
      return Response.ok(map);

  }
}
