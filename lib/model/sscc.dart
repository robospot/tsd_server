import 'package:tsd/tsd.dart';

class Sscc extends ManagedObject<_Sscc> implements _Sscc {
}

class _Sscc {
   @primaryKey
  int id;
  
  @Column(nullable: false)
  int ssccCount;

  @Column(nullable: false)
  int eanCount;

 }