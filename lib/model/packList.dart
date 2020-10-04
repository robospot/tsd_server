import 'package:tsd/tsd.dart';

class PackList extends ManagedObject<_PackList> implements _PackList {
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

@Table(name: "PackList")
class _PackList {
  @primaryKey
  int id;

  @Column(indexed: true)
  String packList;
  @Column(nullable: true)
  String sscc;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;
}
