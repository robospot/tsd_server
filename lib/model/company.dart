
import 'package:tsd/model/user.dart';
import 'package:tsd/tsd.dart';

class Company extends ManagedObject<_Company> implements _Company {
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

@Table(name: "Company")
class _Company {
  @primaryKey
  int id;

  @Column(nullable: false)
  String shortName;

  @Column(nullable: false)
  String fullName;

  ManagedSet<User> vendorUsers;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;


}
