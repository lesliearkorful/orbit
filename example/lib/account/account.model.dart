import 'package:orbit/orbit.dart';

class AccountModel extends Model<Account> {
  AccountModel() : super(Account());
}

@Table('accounts')
class Account extends Entity {
  @primaryKey
  int? id;

  @Column()
  String? accountNumber;

  @Column()
  String? accountName;

  @Column(databaseType: ColumnType.doublePrecision)
  double? balance;

  @Column()
  String? currency;

  @Column(
    databaseType: ColumnType.datetime,
    defaultValue: 'NOW()',
    omitInJson: true,
  )
  DateTime? createdAt;

  @Column(
    databaseType: ColumnType.datetime,
    defaultValue: 'NOW()',
    omitInJson: true,
  )
  DateTime? updatedAt;
}
