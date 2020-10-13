import 'package:tsd/model/dm.dart';
import 'package:tsd/model/sscc.dart';
import 'package:tsd/model/user.dart';

import '../tsd.dart';

class SsccController extends ResourceController {
  SsccController(this.context);

  final ManagedContext context;

  @Operation.get('id')
  Future<Response> getSsccById(@Bind.path("id") String ssccCode) async {

//Подсчет кол-ва КМ по SSCC

 //Проверка на принадлежность организации   
    final queryUser = Query<User>(context)
    ..where((user) => user.id).identifiedBy(request.authorization.ownerID);

     final User user = await queryUser.fetchOne();
     
    final query = Query<Dm>(context)
      ..where((u) => u.sscc).equalTo(ssccCode)
      ..where((u) => u.isUsed).equalTo(true)
      ..where((x) => x.organization).equalTo(user.vendororg.id);
            
   
    final int ssccCount = await query.reduce.count() ?? 0;
   
//Передача подсчета      
      final object = Sscc();
      object.ssccCount = ssccCount;
      final Map<String, dynamic> map = object.asMap();
      return Response.ok(map);

  }
}
