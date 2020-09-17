import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/cache.dart';
import 'package:kira_auth/bloc/account_bloc.dart';
import 'package:kira_auth/widgets/token_balances_table.dart';
import 'package:kira_auth/widgets/deposit_transactions_table.dart';
import 'package:kira_auth/widgets/header_wrapper.dart';

class TokenBalanceScreen extends StatefulWidget {
  @override
  _TokenBalanceScreenState createState() => _TokenBalanceScreenState();
}

class _TokenBalanceScreenState extends State<TokenBalanceScreen> {
  @override
  void initState() {
    super.initState();
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
                  childWidget: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    addHeaderText(),
                    addTokenBalanceTable(context),
                    addDepositTransactionsTable(context),
                  ],
                ),
              ));
            }));
  }

  Widget addHeaderText() {
    return Container(
        margin: EdgeInsets.only(bottom: 50),
        child: Text(
          "Tokens",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: KiraColors.black,
              fontSize: 40,
              fontWeight: FontWeight.w900),
        ));
  }

  Widget addTokenBalanceTable(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30), child: TokenBalancesTable());
  }

  Widget addDepositTransactionsTable(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text("Deposit Transactions",
                textAlign: TextAlign.left,
                style: TextStyle(color: KiraColors.black, fontSize: 30)),
            SizedBox(height: 30),
            DepositTransactionsTable()
          ],
        ));
  }
}
