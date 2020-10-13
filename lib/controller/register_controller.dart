import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:tsd/model/user.dart';
import 'package:tsd/utils/mailer.dart';

class RegisterController extends ResourceController {
  RegisterController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.post()
  Future<Response> createUser(@Bind.body(ignore: ['id']) User user) async {
    // Check for required parameters before we spend time hashing
    if (user.username == null || user.password == null) {
      return Response.badRequest(
          body: {"error": "username and password required."});
    }
    user
      ..salt = AuthUtility.generateRandomSalt()
      ..hashedPassword = authServer.hashPassword(user.password, user.salt);
    //
    try {
      final User createdUser = await Query(context, values: user).insert();
   //   MailService.mailRegisterUser(user);
       final q = Query<User>(context)
      ..where((u) => u.id).equalTo(createdUser.id)
      ..join(object: (u) => u.vendororg);
      
      
      return Response.ok(await q.fetchOne());
    } catch (e) {
      print('error: $e');
      return Response.unauthorized();
    }
  }
}
