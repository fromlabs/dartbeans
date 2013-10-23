// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import "package:dartbeans/dartbeans.dart";

import "dart:async";

class Person extends DartBean {
	// property names
	static const NAME = "name";
	static const MOTHER = "mother";

	// custom event types
	static const REFRESHED_EVENT_TYPE = "refreshed";

	Stream<FLEvent> get onRefreshed => onEvents[REFRESHED_EVENT_TYPE];
  Stream<PropertyChangedEvent> get onNameChanged => onPropertyChangedEvents[NAME];

	Stream<FLEvent> get onBubbleRefreshed => onBubbleEvents[REFRESHED_EVENT_TYPE];
  Stream<PropertyChangedEvent> get onBubbleNameChanged => onBubblePropertyChangedEvents[NAME];

	Person();

  String get name => this[NAME];

  void set name(String name) {
    this[NAME] = name;
  }

  Person get mother => this[MOTHER];

  void set mother(Person mother) {
    this[MOTHER] = mother;
  }

	void refresh() {
		notifyEvent(REFRESHED_EVENT_TYPE, new FLEvent());
	}

  String toString() => "[Person: $name ${mother != null ? "with mother $mother" : "without mother"}]";
}

void main() {
  Person person = new Person();

	person.onNameChanged.listen((PropertyChangedEvent event) {
		print("Property change ${event.property} = ${event.newValue} on ${event.target}");
	});

	person.onRefreshed.listen((event) {
		print("Refresh on ${event.target}");
	});

	person.onBubbleNameChanged.listen((PropertyChangedEvent event) {
		print("Bubble property change ${event.property} = ${event.newValue} on ${event.target} [bubbled: ${event.bubbled}]");
	});

	person.onBubbleRefreshed.listen((event) {
		print("Bubble refresh on ${event.target} [bubbled: ${event.bubbled}]");
	});

	person.name = "Hans";
	person.mother = new Person();
	person.mother.name = "Helga";
	person.mother.refresh();
	person.refresh();
}