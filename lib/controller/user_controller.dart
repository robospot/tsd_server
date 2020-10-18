import 'package:tsd/model/user.dart';
import '../tsd.dart';

class UserController extends ResourceController {
  UserController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllUsers() async {
    final query = Query<User>(context)
     ..join(object: (u) => u.vendor)
     ..join(object: (u) => u.customer);
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(await query.fetch());
  }

  
}
