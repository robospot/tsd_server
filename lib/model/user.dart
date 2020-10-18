import 'package:aqueduct/managed_auth.dart';

import '../tsd.dart';
import 'company.dart';
import 'customer.dart';

class User extends ManagedObject<_User>
    implements _User, ManagedAuthResourceOwner<_User> {
  @Serialize(input: true, output: false)
  String password;

  @override
  void willUpdate() {
    updatedAt = DateTime.now().toUtc();
  }

  @override
  void willInsert() {
    createdAt = DateTime.now().toUtc();
    updatedAt = DateTime.now().toUtc();
  }
}

@Table(name: "Users")
class _User extends ResourceOwnerTableDefinition {
  @Column(unique: true)
  String email;
  @Column(nullable: true)
  String name;
  @Relate(#vendorUsers)
  Company vendor;

  @Relate(#customerUsers)
  Customer customer;
    

 
  @Column(indexed: true)
  DateTime createdAt;
  @Column(indexed: true)
  DateTime updatedAt;
}
