
import 'package:tsd/model/user.dart';
import 'package:tsd/tsd.dart';

class Customer extends ManagedObject<_Customer> implements _Customer {
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

@Table(name: "Customer")
class _Customer {
  @primaryKey
  int id;

  @Column(nullable: false)
  String customer;

  ManagedSet<User> customerUsers;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;


}
