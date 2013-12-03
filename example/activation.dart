// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import "package:dartbeans/dartbeans.dart";

void main() {
  DartBean account = new DartBean();
  DartBean operation = new DartBean();
  DartBeanList operations = new DartBeanList();
  DartBean transaction = new DartBean();

  transaction.onBubblePropertyChanged.listen((event) => print("Event on transaction: ${event.newValue}"));

  account["name"] = "Account1";

  account.activeBubbleTargeting();

  account["name"] = "Account2";

  operation["account"] = account;

  operations.add(operation);

  account["name"] = "Account4";

  transaction["operations"] = operations;

  account["name"] = "Account5";

  operation.activeBubbleTargeting(); // TODO cascade
  operations.activeBubbleTargeting(); // TODO cascade
  transaction.activeBubbleTargeting();

  account["name"] = "Account6";

  transaction.deactiveBubbleTargeting();
  operations.deactiveBubbleTargeting();
  operation.deactiveBubbleTargeting();
  transaction = null;

  account["name"] = "Account7";
}