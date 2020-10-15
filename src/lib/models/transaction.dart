import 'package:json_annotation/json_annotation.dart';

part 'transaction.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Transaction {
  String hash;
  String action;
  String sender;
  String recipient;
  String token;
  String amount;
  String module;
  String gas;
  String status;
  String timestamp;

  Transaction({
    this.hash,
    this.action,
    this.sender,
    this.recipient,
    this.token,
    this.amount,
    this.module,
    this.gas,
    this.status,
    this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionToJson(this);
}
