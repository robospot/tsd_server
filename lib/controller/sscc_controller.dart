import 'package:tsd/model/dm.dart';

import '../tsd.dart';

class SsccController extends ResourceController {
  SsccController(this.context);

  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getSsccById(@Bind.path("id") String ssccCode) async {
    final query = Query<Dm>(context)
      ..where((u) => u.sscc).equalTo(ssccCode)
      ..where((u) => u.isUsed).equalTo(true);
    final int ssccCount = await query.reduce.count() ?? 0;
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(ssccCount);
  }
}
