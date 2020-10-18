
import 'package:tsd/model/user.dart';

import '../tsd.dart';

class IdentityController extends ResourceController {
  IdentityController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getIdentity() async {
    final q = Query<User>(context)
      ..where((u) => u.id).equalTo(request.authorization.ownerID)
     
      ..join(object: (u) => u.vendor);
      

    final u = await q.fetchOne();
    if (u == null) {
      return  Response.notFound();
    }

    return Response.ok(u);
  }
}
