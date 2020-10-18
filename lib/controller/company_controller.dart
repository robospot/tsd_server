import 'package:tsd/model/company.dart';
import '../tsd.dart';

class CompanyController extends ResourceController {
  CompanyController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllCompany(@Bind.header('X-TENANT-ID') String customer) async {

    var response = await context.persistentStore.executeQuery('Select * from public.company ', {}, 60);
    print('response: $response');


     final query = Query<Company>(context);
    return Response.ok(await query.fetch());
    // return Response.ok(response);
  }

  @Operation.post()
  Future<Response> addCompany( @Bind.body(ignore: ['id']) Company company) async {
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(await Query.insertObject(context, company));
  }
}
