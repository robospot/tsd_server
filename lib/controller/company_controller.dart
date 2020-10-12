import 'package:tsd/model/company.dart';
import '../tsd.dart';

class CompanyController extends ResourceController {
  CompanyController(this.context);

  final ManagedContext context;

  @Operation.get()
  Future<Response> getAllCompany() async {
    final query = Query<Company>(context);
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(await query.fetch());
  }

  @Operation.post()
  Future<Response> addCompany( @Bind.body(ignore: ['id']) Company company) async {
    // ..join(set: (u) => u.units).join(set: (f) => f.details).join(set:(v) => v.values)
    // ..where((n) => n.owner).identifiedBy(request.authorization.ownerID);

    return Response.ok(await Query.insertObject(context, company));
  }
}
