import 'package:aqueduct/managed_auth.dart';

import 'controller/company_controller.dart';
import 'controller/dm_controller.dart';
import 'controller/ean_controller.dart';
import 'controller/identity_controller.dart';
import 'controller/media_controller.dart';
import 'controller/packList_controller.dart';
import 'controller/register_controller.dart';
import 'controller/restorePassword_controller.dart';
import 'controller/sscc_controller.dart';
import 'controller/user_controller.dart';
import 'model/user.dart';
import 'tsd.dart';

// aqueduct db upgrade --connect postgres://tsd:master15s0@localhost:5432/tsd
//aqueduct auth add-client --id com.monitoo --connect postgres://monitoo:monitoo@localhost:5432/monitoo
class TsdChannel extends ApplicationChannel {
  ManagedContext context;
  AuthServer authServer;

  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
         logger.parent.level = Level.ALL;

    final config = DatabaseConfig(options.configurationFilePath);

    final dataModel = ManagedDataModel.fromCurrentMirrorSystem();

    final persistentStore = PostgreSQLPersistentStore.fromConnectionInfo(
      config.database.username,
      config.database.password,
      config.database.host,
      config.database.port,
      config.database.databaseName,
    );

    context = ManagedContext(dataModel, persistentStore);

    //Auth
    final authStorage = ManagedAuthDelegate<User>(context);
    authServer = AuthServer(authStorage);
  }

  @override
  Controller get entryPoint {
    final router = Router();

    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });

    router
        .route('/register')
        .link(() => RegisterController(context, authServer));
    router.route('/auth/token').link(() => AuthController(authServer));
    /* Gets profile for user with bearer token */
    router
        .route("/me")
        .link(() => Authorizer.bearer(authServer))
        .link(() => IdentityController(context));

router.route("/media/").link(() => MediaController(context));
router.route("/company").link(() => CompanyController(context));
router.route("/dm").link(() => Authorizer.bearer(authServer)) 
.link(() => DmController(context));
router.route("/sscc/[:id]").link(() => Authorizer.bearer(authServer)) 
.link(() => SsccController(context));
router.route("/ean/[:id]").link(() => Authorizer.bearer(authServer)) 
.link(() => EanController(context)); 
router.route("/packlist/[:id]").link(() => PackListController(context));
router.route("/user/[:id]").link(() => UserController(context));
 router.route('/restorepass')
    .link(() => RestorePasswordController(context, authServer));
    return router;


    
  }
}

class DatabaseConfig extends Configuration {
  DatabaseConfig(String path) : super.fromFile(File(path));
  DatabaseConfiguration database;

  @optionalConfiguration
  int identifier;
}
