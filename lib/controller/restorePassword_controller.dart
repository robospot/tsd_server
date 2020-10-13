
import 'package:aqueduct/aqueduct.dart';
import 'package:random_string/random_string.dart';
import 'package:tsd/model/user.dart';
import 'package:tsd/utils/mailer.dart';

class RestorePasswordController extends ResourceController {
  RestorePasswordController(this.context, this.authServer);

  final AuthServer authServer;
  final ManagedContext context;

  @Operation.post()
  Future<Response> restorePassword( @Bind.body() User user) async {

   final String randomPass = randomAlphaNumeric(10);
   String salt = AuthUtility.generateRandomSalt();
      final query = Query<User>(context)
      ..where((n) => n.email).equalTo(user.email)
      ..values.salt = salt
       ..values.hashedPassword = authServer.hashPassword(randomPass, salt);

   final u = await query.updateOne();
    if (u == null) {
      return Response.notFound();
    }

else{
  MailService.mailRestorePassword(u, randomPass);
    return Response.ok(u);
}
  }   
     
}
