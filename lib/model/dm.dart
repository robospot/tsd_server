

import 'package:tsd/tsd.dart';

class Dm extends ManagedObject<_Dm> implements _Dm {
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

@Table(name: "Dm")
class _Dm {
  
  @Column(indexed: true)
  int organization;
  @Column(indexed: true,nullable: true)
  String sscc;
  @Column(indexed: true)
  String ean;
  @Column(indexed: true, primaryKey: true )
  String datamatrix;

  @Column(nullable: true)
  bool isUsed;
 
  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;


}
