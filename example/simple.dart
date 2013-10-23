// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import "package:dartbeans/dartbeans.dart";

void main() {
  DartBean person = new DartBean();

	person.onPropertyChangedEvents["name"]
		.listen((PropertyChangedEvent event) =>
			print("Property changed: ${event.property} = ${event.newValue}"));

	person["name"] = "Hans";
}