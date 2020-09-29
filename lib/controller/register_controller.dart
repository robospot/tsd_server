import 'dart:async';

import 'package:aqueduct/aqueduct.dart';
import 'package:tsd/model/user.dart';

class RegisterController extends ResourceController {
  RegisterController(this.context, this.authServer);

  final ManagedContext context;
  final AuthServer authServer;

  @Operation.post()
  Future<Response> createUser(@Bind.body() User user) async {
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
      final User response = await Query(context, values: user).insert();
      return Response.ok(response);
    } catch (e) {
      print('error: $e');
      return Response.unauthorized();
    }
  }
}
