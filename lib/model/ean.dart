import 'package:tsd/tsd.dart';

class Ean extends ManagedObject<_Ean> implements _Ean {
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

@Table(name: 'Ean')

class _Ean {
@primaryKey
  int id;
  
  @Column(indexed: true)
  String ean;

@Column(indexed: true)
  String language;

  String description;

  @Column(indexed: true)
  DateTime createdAt;

  @Column(indexed: true)
  DateTime updatedAt;
}
