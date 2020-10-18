import 'package:aqueduct/aqueduct.dart';
import 'package:random_string/random_string.dart';
import 'package:tsd/model/user.dart';
import 'package:tsd/utils/mailer.dart';

class RestorePasswordController extends ResourceController {
  RestorePasswordController(this.context, this.authServer);

  final AuthServer authServer;
  final ManagedContext context;

  @Operation.post('email')
  Future<Response> restorePassword(@Bind.path("email") String email) async {
    print('email:');
    print(email);
    final String randomPass = randomAlphaNumeric(10);
    String salt = AuthUtility.generateRandomSalt();
    final query = Query<User>(context)
      ..where((n) => n.email).equalTo(email)
      ..values.salt = salt
      ..values.hashedPassword = authServer.hashPassword(randomPass, salt);

    final createdUser = await query.updateOne();
    if (createdUser == null) {
      return Response.notFound();
    } else {
      MailService.mailRestorePassword(createdUser, randomPass);
      final q = Query<User>(context)
        ..where((u) => u.id).equalTo(createdUser.id)
        ..join(object: (u) => u.vendor);

      return Response.ok(await q.fetchOne());
    }
  }
}
