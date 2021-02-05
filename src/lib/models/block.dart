import 'package:json_annotation/json_annotation.dart';
import 'package:date_time_format/date_time_format.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Block {
  final int blockSize;
  final String hash;
  final String appHash;
  final String chainId;
  final String consensusHash;
  final String dataHash;
  final String evidenceHash;
  final int height;
  final String lastCommitHash;
  final String lastResultsHash;
  final String nextValidatorsHash;
  final String proposerAddress;
  final DateTime time;
  final String validatorsHash;
  final int txAmount;

  Block({ this.blockSize = 0, this.hash = "", this.appHash = "", this.chainId = "", this.consensusHash = "", this.dataHash = "",
    this.evidenceHash = "", this.height = 0, this.lastCommitHash = "", this.lastResultsHash = "",
    this.nextValidatorsHash = "", this.proposerAddress = "", this.time, this.validatorsHash = "", this.txAmount = 0 }) {
    assert(this.blockSize != null || this.hash != null || this.appHash != null || this.chainId != null || this.consensusHash != null
      || this.dataHash != null || this.evidenceHash != null || this.height != null || this.lastCommitHash != null
      || this.lastResultsHash != null || this.dataHash != null || this.nextValidatorsHash != null
      || this.proposerAddress != null || this.time != null || this.validatorsHash != null || this.txAmount != null);
  }

  String getTimeString() { return time.relative(appendIfAfter: 'ago'); }

  String getProposerString() {
    return "0x" + proposerAddress;
  }

  String getHeightString() {
    if (height > -1000 && height < 1000)
      return height.toString();

    final String digits = height.abs().toString();
    final StringBuffer result = StringBuffer(height < 0 ? '-' : '');
    final int maxDigitIndex = digits.length - 1;
    for (int i = 0; i <= maxDigitIndex; i += 1) {
      result.write(digits[i]);
      if (i < maxDigitIndex && (maxDigitIndex - i) % 3 == 0)
        result.write(',');
    }
    return result.toString();
  }

  // factory Block.fromJson(Map<String, dynamic> json) =>
  //     _$BlockFromJson(json);
  //
  // Map<String, dynamic> toJson() => _$BlockToJson(this);
}

