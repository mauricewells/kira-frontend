import 'dart:async';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kira_auth/utils/export.dart';
import 'package:kira_auth/models/export.dart';
import 'package:kira_auth/helpers/export.dart';
import 'package:kira_auth/services/export.dart';
import 'package:kira_auth/widgets/export.dart';
import 'package:kira_auth/blocs/export.dart';

class WithdrawalScreen extends StatefulWidget {
  @override
  _WithdrawalScreenState createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends State<WithdrawalScreen> {
  TokenService tokenService = TokenService();
  GravatarService gravatarService = GravatarService();
  RPCMethodsService rpcMethodService = RPCMethodsService();
  TransactionService transactionService = TransactionService();

  List<Token> tokens = [];
  List<Transaction> transactions = [];
  Account currentAccount;
  Token currentToken;
  double amountInterval;
  double withdrawalAmount;
  double transactionFee;
  String feeAmount;
  Token feeToken;
  String amountError;
  String addressError;
  String transactionHash;
  Timer timer;

  bool copied;

  FocusNode amountFocusNode;
  TextEditingController amountController;

  FocusNode addressFocusNode;
  TextEditingController addressController;

  FocusNode memoFocusNode;
  TextEditingController memoController;

  @override
  void initState() {
    super.initState();
    this.copied = false;
    getRPCMethods();

    transactionFee = 0.05;
    withdrawalAmount = 0;
    amountInterval = 0;

    amountError = '';
    addressError = '';
    transactionHash = '';

    amountFocusNode = FocusNode();
    amountController = TextEditingController();
    amountController.text = withdrawalAmount.toString();
    addressFocusNode = FocusNode();
    addressController = TextEditingController();
    memoFocusNode = FocusNode();
    memoController = TextEditingController();

    if (mounted) {
      setState(() {
        if (BlocProvider.of<AccountBloc>(context).state.currentAccount != null) {
          currentAccount = BlocProvider.of<AccountBloc>(context).state.currentAccount;
        }
        if (BlocProvider.of<TokenBloc>(context).state.feeToken != null) {
          feeToken = BlocProvider.of<TokenBloc>(context).state.feeToken;
        }
        getWithdrawalTransactions();
      });
    }

    getTokens();
    getCachedFeeAmount();

    if (feeToken == null) {
      getFeeToken();
    }
  }

  void getWithdrawalTransactions() async {
    if (currentAccount != null) {
      List<Transaction> wTxs =
          await transactionService.getTransactions(account: currentAccount, max: 100, isWithdrawal: true);

      setState(() {
        transactions = wTxs;
      });
    }
  }

  void getNewTransaction(hash) async {
    Transaction tx = await transactionService.getTransaction(hash: hash);
    tx.isNew = true;
    setState(() {
      transactions.add(tx);
    });
  }

  void getCachedFeeAmount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int cfeeAmount = prefs.getInt('feeAmount');
      if (cfeeAmount.runtimeType != Null)
        feeAmount = cfeeAmount.toString();
      else
        feeAmount = '100';
    });
  }

  void getFeeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      String feeTokenString = prefs.getString('feeToken');
      if (feeTokenString.runtimeType != Null) {
        feeToken = Token.fromString(feeTokenString);
      } else {
        feeToken = Token(assetName: "Kira", ticker: 'KEX', denomination: "ukex", decimals: 6);
      }
    });
  }

  void autoPress() {
    timer = new Timer(const Duration(seconds: 2), () {
      setState(() {
        copied = false;
      });
    });
  }

  void getTokens() async {
    if (currentAccount != null && mounted) {
      await tokenService.getTokens(currentAccount.bech32Address);

      setState(() {
        tokens = tokenService.tokens;
        currentToken = tokens.length > 0 ? tokens[0] : null;
        amountInterval = currentToken != null && currentToken.balance != 0 ? currentToken.balance / 100 : 0;
      });
    }
  }

  void getRPCMethods() async {
    await rpcMethodService.getRPCMethods();
  }

  @override
  Widget build(BuildContext context) {
    checkPasswordExpired().then((success) {
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });

    return Scaffold(
        body: BlocConsumer<AccountBloc, AccountState>(
            listener: (context, state) {},
            builder: (context, state) {
              return HeaderWrapper(
                  childWidget: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(top: 50, bottom: 50),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        addHeaderTitle(),
                        if (currentAccount != null) addGravatar(context),
                        if (currentToken == null) addDescription(),
                        ResponsiveWidget.isSmallScreen(context) ? addFirstLineSmall() : addFirstLineBig(),
                        ResponsiveWidget.isSmallScreen(context) ? addSecondLineSmall() : addSecondLineBig(),
                        ResponsiveWidget.isSmallScreen(context) ? addWithdrawalAmountSmall() : addWithdrawalAmountBig(),
                        addWithdrawalTransactionsTable(),
                      ],
                    )),
              ));
            }));
  }

  Widget addHeaderTitle() {
    return Container(
        margin: EdgeInsets.only(bottom: 40),
        child: Text(
          Strings.withdrawal,
          textAlign: TextAlign.left,
          style: TextStyle(color: KiraColors.white, fontSize: 30, fontWeight: FontWeight.w900),
        ));
  }

  Widget addDescription() {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Text(
          Strings.insufficientBalance,
          textAlign: TextAlign.center,
          style: TextStyle(color: KiraColors.green2, fontSize: 18),
        ));
  }

  Widget addToken() {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(width: 2, color: KiraColors.kPurpleColor),
            color: KiraColors.transparent,
            borderRadius: BorderRadius.circular(9)),
        // dropdown below..
        child: DropdownButtonHideUnderline(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.only(top: 10, left: 15, bottom: 0),
                child: Text(Strings.tokens, style: TextStyle(color: KiraColors.kGrayColor, fontSize: 12)),
              ),
              ButtonTheme(
                alignedDropdown: true,
                child: DropdownButton<String>(
                    value: currentToken != null ? currentToken.assetName : "",
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 32,
                    underline: SizedBox(),
                    onChanged: (String assetName) {
                      setState(() {
                        currentToken = tokens.singleWhere((token) => token.assetName == assetName);
                        amountInterval = currentToken.balance / 100;
                        withdrawalAmount = 0;
                        amountController.text = withdrawalAmount.toString();
                      });
                    },
                    items: tokens.map<DropdownMenuItem<String>>((Token token) {
                      return DropdownMenuItem<String>(
                        value: token.assetName,
                        child: Container(
                            height: 25,
                            alignment: Alignment.topCenter,
                            child: Text(token.assetName, style: TextStyle(color: KiraColors.white, fontSize: 18))),
                      );
                    }).toList()),
              ),
            ],
          ),
        ));
  }

  Widget withdrawalAmountInput() {
    String ticker = currentToken != null ? currentToken.ticker : "";

    return AppTextField(
      labelText: Strings.withdrawalAmount,
      hintText: 'Minimum Withdrawal 0.05 ' + ticker,
      focusNode: amountFocusNode,
      controller: amountController,
      textInputAction: TextInputAction.done,
      maxLines: 1,
      autocorrect: false,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.left,
      onChanged: (String text) {
        if (text == '' || double.parse(text) == null) {
          setState(() {
            amountError = "Withdrawal amount is invalid";
            withdrawalAmount = 0;
          });
          return;
        }
        double percent = double.parse(amountController.text) / amountInterval;

        if (double.parse(amountController.text) < 0.25 || percent > 100) {
          setState(() {
            amountError = percent > 100
                ? "Withdrawal amount is out of range"
                : "Amount to withdraw must be at least 0.05000000 " + ticker;
            withdrawalAmount = 0;
          });
          return;
        }

        setState(() {
          amountError = "";
          withdrawalAmount = double.parse(amountController.text);
        });
      },
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: KiraColors.white,
        fontFamily: 'NunitoSans',
      ),
    );
  }

  Widget addWithdrawalAmount() {
    int txFee = int.parse(feeAmount);
    String ticker = currentToken != null ? currentToken.ticker : "";
    double currentBalance = amountInterval == 0 ? 0 : withdrawalAmount / amountInterval;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'min',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KiraColors.kGrayColor,
            ),
          ),
          Text(
            'max',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KiraColors.kGrayColor,
            ),
          ),
        ],
      ),
      Container(
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: KiraColors.kYellowColor.withOpacity(.7),
            inactiveTrackColor: KiraColors.kPrimaryLightColor.withOpacity(.3),
            trackHeight: 5.0,
            thumbShape: CustomSliderThumbCircle(
              thumbRadius: 15,
              min: 0,
              max: 100,
            ),
            overlayColor: KiraColors.kPrimaryColor.withOpacity(.4),
            valueIndicatorShape: PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: Colors.black,
            tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 5),
            activeTickMarkColor: KiraColors.white.withOpacity(0.7),
            inactiveTickMarkColor: KiraColors.kPrimaryLightColor.withOpacity(.6),
          ),
          child: Slider(
              value: currentBalance,
              min: 0,
              max: 100,
              // divisions: 4,
              onChanged: (value) {
                setState(() {
                  withdrawalAmount = value * amountInterval;
                  amountController.text = withdrawalAmount.toStringAsFixed(6);
                  amountError = "";
                });
              }),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Transaction Fee: " + feeAmount + " " + ticker,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: KiraColors.kGrayColor)),
          Text(
            withdrawalAmount > txFee
                ? 'You Will Get: ' + (withdrawalAmount - txFee).toStringAsFixed(6) + " " + ticker
                : 'You Will Get: 0.000000 ' + ticker,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: KiraColors.kGrayColor,
            ),
          ),
        ],
      )
    ]);
  }

  Widget addWithdrawalAmountBig() {
    return Container(
        margin: EdgeInsets.only(bottom: 100),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
            ConstrainedBox(constraints: BoxConstraints(maxWidth: 500), child: addWithdrawalAmount()),
            addWithdrawButton(true)
          ]),
          addTransactionHashResult()
        ]));
  }

  Widget addWithdrawalAmountSmall() {
    return Container(
        margin: EdgeInsets.only(bottom: 100),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              addWithdrawalAmount(),
              addTransactionHashResult(),
              SizedBox(height: 30),
              addWithdrawButton(false)
            ]));
  }

  Widget addGravatar(BuildContext context) {
    final String gravatar = gravatarService.getIdenticon(currentAccount != null ? currentAccount.bech32Address : "");

    final String reducedAddress =
        currentAccount.bech32Address.replaceRange(10, currentAccount.bech32Address.length - 7, '....');

    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                FlutterClipboard.copy(currentAccount.bech32Address).then((value) => {
                      setState(() {
                        copied = !copied;
                      }),
                      if (copied == true) {autoPress()}
                    });
              },
              borderRadius: BorderRadius.circular(500),
              onHighlightChanged: (value) {},
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: new Border.all(
                    color: KiraColors.kPurpleColor,
                    width: 3,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(1000),
                  child: SvgPicture.string(
                    gravatar,
                    fit: BoxFit.contain,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 20,
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              curve: Curves.easeIn,
              child: Text(copied ? "Copied" : reducedAddress,
                  style: TextStyle(
                      color: copied ? KiraColors.green2 : KiraColors.white.withOpacity(0.8),
                      fontSize: 15,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w300)),
            ),
          ],
        ));
  }

  Widget addWithdrawButton(isBig) {
    String denomination = currentToken != null ? currentToken.denomination : "";
    return CustomButton(
      key: Key('withdraw'),
      text: 'Withdraw',
      width: isBig == true ? 200 : null,
      height: isBig == true ? 50.0 : 60,
      fontSize: 18,
      style: 2,
      onPressed: () async {
        if (withdrawalAmount == 0) {
          setState(() {
            amountError = "Please specify withdrawal amount";
          });
          return;
        }

        final message = MsgSend(
            fromAddress: currentAccount.bech32Address,
            toAddress: addressController.text,
            amount: [StdCoin(denom: denomination, amount: withdrawalAmount.toString())]);

        final feeV = StdCoin(amount: feeAmount, denom: feeToken.denomination);
        final fee = StdFee(gas: '200000', amount: [feeV]);
        final stdTx = TransactionBuilder.buildStdTx([message], stdFee: fee, memo: memoController.text);

        // Sign the transaction
        final signedStdTx = await TransactionSigner.signStdTx(currentAccount, stdTx);

        // Broadcast signed transaction
        final result = await TransactionSender.broadcastStdTx(account: currentAccount, stdTx: signedStdTx);

        if (result['height'] == "0") {
          print("Tx send error: " + result['check_tx']['log']);
          if (result['check_tx']['log'].toString().contains("invalid request")) {
            setState(() {
              transactionHash = "Transaction failed: Invalid request";
            });
          }
        } else {
          print("Tx send successfully. Hash: 0x" + result['hash']);
          setState(() {
            transactionHash = "Transaction successed";
          });
          getNewTransaction("0x" + result['hash']);
        }
      },
    );
  }

  Widget addWithdrawalTransactionsTable() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.withdrawalTransactions,
              textAlign: TextAlign.start,
              style: TextStyle(color: KiraColors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 30),
            WithdrawalTransactionsTable(transactions: transactions)
          ],
        ));
  }

  Widget addTransactionHashResult() {
    return Container(
        margin: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (transactionHash != '')
                  Container(
                    alignment: AlignmentDirectional(0, 0),
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text(transactionHash,
                        style: TextStyle(
                          fontSize: 16.0,
                          color: transactionHash.contains("success") ? KiraColors.green2 : KiraColors.kYellowColor,
                          fontFamily: 'NunitoSans',
                          fontWeight: FontWeight.w600,
                        )),
                  ),
              ],
            ),
          ],
        ));
  }

  Widget addWithdrawalAddress() {
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
      AppTextField(
        hintText: Strings.withdrawalAddress,
        labelText: Strings.withdrawalAddress,
        focusNode: addressFocusNode,
        controller: addressController,
        textInputAction: TextInputAction.done,
        maxLines: 1,
        autocorrect: false,
        keyboardType: TextInputType.text,
        textAlign: TextAlign.left,
        onChanged: (String text) {
          if (text == '') {
            setState(() {
              addressError = "";
            });
          }
        },
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: KiraColors.white,
          fontFamily: 'NunitoSans',
        ),
      ),
      if (addressError != '') SizedBox(height: 10),
      if (addressError != '')
        Text(
          addressError,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: KiraColors.kYellowColor.withOpacity(0.8),
          ),
        ),
    ]);
  }

  Widget addFirstLineSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            addToken(),
            SizedBox(height: 30),
            addWithdrawalAddress(),
          ]),
    );
  }

  Widget addFirstLineBig() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: addToken(), flex: 1),
            SizedBox(width: 60),
            Expanded(child: addWithdrawalAddress(), flex: 1),
          ]),
    );
  }

  Widget addMemo() {
    return AppTextField(
      hintText: Strings.memo,
      labelText: Strings.memo,
      focusNode: memoFocusNode,
      controller: memoController,
      textInputAction: TextInputAction.next,
      maxLines: null,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      textAlign: TextAlign.left,
      onChanged: (String text) {
        if (text == '') {
          setState(() {
            addressError = "";
          });
        }
      },
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 18,
        color: KiraColors.white,
        fontFamily: 'NunitoSans',
      ),
    );
  }

  Widget addWithdrawalAmountInput() {
    String ticker = currentToken != null ? currentToken.ticker : "";
    return Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
      withdrawalAmountInput(),
      SizedBox(height: 10),
      Text(
        'Available Balance ' + (amountInterval * 100).toStringAsFixed(6) + " " + ticker,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: KiraColors.white,
        ),
      ),
      if (amountError != '') SizedBox(height: 10),
      if (amountError != '')
        Text(
          amountError,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: KiraColors.kYellowColor.withOpacity(0.8),
          ),
        ),
    ]);
  }

  Widget addSecondLineSmall() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            addWithdrawalAmountInput(),
            SizedBox(height: 30),
            addMemo(),
          ]),
    );
  }

  Widget addSecondLineBig() {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: addWithdrawalAmountInput(), flex: 1),
            SizedBox(width: 60),
            Expanded(child: addMemo(), flex: 1),
          ]),
    );
  }
}
