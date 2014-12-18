// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

import 'package:dartbeans/dartbeans.dart';
import 'package:unittest/unittest.dart';

const String RENDERED_EVENT_TYPE = "rendered";
const String UPDATED_EVENT_TYPE = "updated.";
const String NAME_DISCRIMINATOR = "name";
const String ADDRESS_DISCRIMINATOR = "address";

void main() {

	/* Simple event stream provider */

	group('Simple event stream provider - management:', () {
		FLEventTarget target = new EventTargetProxy();

		test('Target no set', () {
			FLEventStreamProvider provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE);
			expect(() => provider.stream, throwsStateError);
		});
		test('Target set twice', () {
			FLEventStreamProvider provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE);
			provider.target = target;
			provider.forTarget(target);
			provider.target = target;
			expect(() => provider.stream, isNotNull);
		});
		test('Target set twice but different', () {
			FLEventStreamProvider provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE);
			provider.forTarget(target);
			expect(() => provider.target = new EventTargetProxy(), throwsStateError);
		});
	});

	group('Simple event stream provider bubble - management:', () {
		FLEventTarget target = new EventTargetProxy();
		FLEventTarget bubbleTarget = new EventTargetProxy();

		test('Already added bubble provider', () {
			FLEventStreamProvider provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, target);
			FLEventStreamProvider bubbleProvider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, bubbleTarget);

			provider.addBubbleTargetProvider("provider", bubbleProvider);
			expect(() => provider.addBubbleTargetProvider("provider", bubbleProvider), throwsStateError);
		});

		test('Bubble provider to remove not present', () {
			FLEventStreamProvider provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, target);
			FLEventStreamProvider bubbleProvider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, bubbleTarget);

			expect(() {
				provider.removeBubbleTargetProvider("provider", bubbleProvider);
			}, throwsStateError);
		});
	});
/*
	group('Simple event stream provider - events:', () {
		FLEventTarget target = new EventTargetProxy();
		FLEventStreamProvider provider;

		setUp(() {
			provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, target);
		});
		tearDown(() {
			provider = null;
		});

		test('Listen events', () {
			provider.stream.listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 2));

			provider.dispatch(new FLEvent());
			provider.dispatch(new FLEvent());
		});
	});

	group('Simple event stream provider bubble - events:', () {
		FLEventTarget target = new EventTargetProxy();
		FLEventTarget bubbleTarget = new EventTargetProxy();

		test('Listen bubble events', () {
			FLEventStreamProvider provider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, target);
			FLEventStreamProvider bubbleProvider = new FLEventStreamProvider(RENDERED_EVENT_TYPE, bubbleTarget);

			provider.stream.listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 3));
			provider.bubbleStream.listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 3));
			bubbleProvider.stream.listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 3));
			bubbleProvider.bubbleStream.listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 4));

			provider.dispatch(new FLEvent());
			bubbleProvider.dispatch(new FLEvent());

			provider.addBubbleTargetProvider("provider", bubbleProvider);

			provider.dispatch(new FLEvent());
			bubbleProvider.dispatch(new FLEvent());

			provider.removeBubbleTargetProvider("provider", bubbleProvider);

			provider.dispatch(new FLEvent());
			bubbleProvider.dispatch(new FLEvent());
		});
	});
*/
	/* Discriminated event stream provider */
/*
	group('Discriminated event stream provider - management:', () {
		FLEventTarget target = new EventTargetProxy();

		test('Event type with discriminator postfix', () {
			expect(() => new DiscriminatedEventStreamProvider(RENDERED_EVENT_TYPE, "name"), throwsArgumentError);
		});
	});

	group('Discriminated event stream provider - events:', () {
		FLEventTarget target = new EventTargetProxy();
		DiscriminatedEventStreamProvider nameUpdatedProvider;
		DiscriminatedEventStreamProvider addressUpdatedProvider;
		setUp(() {
			nameUpdatedProvider = new DiscriminatedEventStreamProvider(UPDATED_EVENT_TYPE, NAME_DISCRIMINATOR, target);
			addressUpdatedProvider = new DiscriminatedEventStreamProvider(UPDATED_EVENT_TYPE, ADDRESS_DISCRIMINATOR, target);
		});
		tearDown(() {
			nameUpdatedProvider = null;
			addressUpdatedProvider = null;
		});
		test('Listen events', () {
			nameUpdatedProvider.stream.listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 2));
			addressUpdatedProvider.stream.listen(expectAsync1((event) => expect(false, 'Should not be reached'), count: 0));

			nameUpdatedProvider.dispatch(new DiscriminatedEvent());
			nameUpdatedProvider.dispatch(new DiscriminatedEvent());
		});
	});
*/
	/* To discriminate event stream provider */

	group('To discriminate event stream provider - management:', () {
		FLEventTarget target = new EventTargetProxy();

		test('Target set on hosted provider', () {
			ToDiscriminateEventStreamProvider updatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE);
			expect(() => updatedProvider[NAME_DISCRIMINATOR].target = target, throwsUnsupportedError);
		});
		test('Dispatch from host provider', () {
			ToDiscriminateEventStreamProvider updatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE, target);
			expect(() => updatedProvider.dispatch(new DiscriminatedEvent()), throwsUnsupportedError);
		});
		test('Event type with discriminator postfix', () {
			expect(() => new ToDiscriminateEventStreamProvider(RENDERED_EVENT_TYPE), throwsArgumentError);
		});
	});

	group('To discriminate event stream provider bubble - management:', () {
		FLEventTarget target = new EventTargetProxy();
		FLEventTarget bubbleTarget = new EventTargetProxy();

		test('Add bubble provider on hosted provider', () {
			ToDiscriminateEventStreamProvider updatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE);
			ToDiscriminateEventStreamProvider bubbleUpdatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE);

			expect(() => updatedProvider[NAME_DISCRIMINATOR].addBubbleTargetProvider("provider", bubbleUpdatedProvider), throwsUnsupportedError);
		});

		test('Remove bubble provider from hosted provider', () {
			ToDiscriminateEventStreamProvider updatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE);
			ToDiscriminateEventStreamProvider bubbleUpdatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE);

			expect(() => updatedProvider[NAME_DISCRIMINATOR].removeBubbleTargetProvider("provider", bubbleUpdatedProvider), throwsUnsupportedError);
		});
	});
/*
	group('To discriminate event stream provider - events:', () {
		FLEventTarget target = new EventTargetProxy();
		ToDiscriminateEventStreamProvider updatedProvider;
		setUp(() {
			updatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE, target);
		});
		tearDown(() {
			updatedProvider = null;
		});
		test('Listen events', () {
			updatedProvider.onDiscriminatorEvents[NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE))));
			updatedProvider.onDiscriminatorEvents[ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE))));
			updatedProvider.stream.listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 2));

			updatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			updatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
		});
	});

	group('To discriminate event stream provider bubble - events:', () {
		FLEventTarget target = new EventTargetProxy();
		FLEventTarget bubbleTarget = new EventTargetProxy();

		ToDiscriminateEventStreamProvider updatedProvider;
		ToDiscriminateEventStreamProvider bubbleUpdatedProvider;
		setUp(() {
			updatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE, target);
			bubbleUpdatedProvider = new ToDiscriminateEventStreamProvider(UPDATED_EVENT_TYPE, bubbleTarget);
		});
		tearDown(() {
			updatedProvider = null;
			bubbleUpdatedProvider = null;
		});
		test('Listen events', () {
			updatedProvider.onDiscriminatorEvents[NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			updatedProvider.onDiscriminatorEvents[ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			updatedProvider.stream.listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 6));
			bubbleUpdatedProvider.onDiscriminatorEvents[NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			bubbleUpdatedProvider.onDiscriminatorEvents[ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			bubbleUpdatedProvider.stream.listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 6));

			updatedProvider.onBubbleDiscriminatorEvents[NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			updatedProvider.onBubbleDiscriminatorEvents[ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			updatedProvider.bubbleStream.listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 6));
			bubbleUpdatedProvider.onBubbleDiscriminatorEvents[NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 4));
			bubbleUpdatedProvider.onBubbleDiscriminatorEvents[ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 4));
			bubbleUpdatedProvider.bubbleStream.listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 8));

			updatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			updatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbleUpdatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbleUpdatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());

			updatedProvider.addBubbleTargetProvider("provider", bubbleUpdatedProvider);

			updatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			updatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbleUpdatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbleUpdatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());

			updatedProvider.removeBubbleTargetProvider("provider", bubbleUpdatedProvider);

			updatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			updatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbleUpdatedProvider[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbleUpdatedProvider[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
		});
	});
*/
	/* To route event stream provider */
/*
	group('To route event stream provider - management:', () {
		FLEventTarget target = new EventTargetProxy();

		test('Target set on hosted provider', () {
			ToRouteEventStreamProvider provider = new ToRouteEventStreamProvider();
			expect(() => provider[RENDERED_EVENT_TYPE].target = target, throwsUnsupportedError);
			expect(() => provider[UPDATED_EVENT_TYPE].target = target, throwsUnsupportedError);
			expect(() => (provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].target = target, throwsUnsupportedError);
			expect(() => (provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].target = target, throwsUnsupportedError);
		});
		test('Dispatch from host provider', () {
			ToRouteEventStreamProvider provider = new ToRouteEventStreamProvider(target);
			expect(() => provider[UPDATED_EVENT_TYPE].dispatch(new DiscriminatedEvent()), throwsUnsupportedError);
		});
	});

	group('To route event stream provider - events:', () {
		FLEventTarget target = new EventTargetProxy();
		ToRouteEventStreamProvider provider;
		setUp(() {
			provider = new ToRouteEventStreamProvider(target);
		});
		tearDown(() {
			provider = null;
		});
		test('Listen events', () {
			provider.onEvents[RENDERED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE))));
			provider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE))));
			provider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE))));
			provider.onEvents[UPDATED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 2));

			provider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
		});
	});

	group('To route event stream provider bubble - events:', () {
		FLEventTarget target = new EventTargetProxy();
		FLEventTarget bubbleTarget = new EventTargetProxy();

		ToRouteEventStreamProvider provider;
		ToRouteEventStreamProvider bubbledProvider;
		setUp(() {
			provider = new ToRouteEventStreamProvider(target);
			bubbledProvider = new ToRouteEventStreamProvider(bubbleTarget);
		});
		tearDown(() {
			provider = null;
			bubbledProvider = null;
		});
		test('Listen events', () {
			provider.onEvents[RENDERED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 3));
			provider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			provider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			provider.onEvents[UPDATED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 6));
			bubbledProvider.onEvents[RENDERED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 3));
			bubbledProvider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			bubbledProvider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			bubbledProvider.onEvents[UPDATED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 6));

			provider.onBubbleEvents[RENDERED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 3));
			provider.onBubbleToDiscriminateEvents[UPDATED_EVENT_TYPE][NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			provider.onBubbleToDiscriminateEvents[UPDATED_EVENT_TYPE][ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 3));
			provider.onBubbleEvents[UPDATED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 6));
			bubbledProvider.onBubbleEvents[RENDERED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(RENDERED_EVENT_TYPE)), count: 4));
			bubbledProvider.onBubbleToDiscriminateEvents[UPDATED_EVENT_TYPE][NAME_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 4));
			bubbledProvider.onBubbleToDiscriminateEvents[UPDATED_EVENT_TYPE][ADDRESS_DISCRIMINATOR].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 4));
			bubbledProvider.onBubbleEvents[UPDATED_EVENT_TYPE].listen(expectAsync1((event) => expect(event.type, equals(UPDATED_EVENT_TYPE)), count: 8));

			provider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbledProvider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(bubbledProvider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(bubbledProvider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());

			provider.addBubbleTargetProvider("provider", bubbledProvider);

			provider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbledProvider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(bubbledProvider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(bubbledProvider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());

			provider.removeBubbleTargetProvider("provider", bubbledProvider);

			provider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			bubbledProvider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(bubbledProvider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(bubbledProvider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
		});
	});
*/
	/* Stream binders */
/*
	group('To route event stream provider - events:', () {
		FLEventTarget target = new EventTargetProxy();
		ToRouteEventStreamProvider provider;
		setUp(() {
			provider = new ToRouteEventStreamProvider(target);
		});
		tearDown(() {
			provider = null;
		});
		test('Listen events', () {

			new ListenerBinder(expectAsync1((event) => true, count: 5))
					..listen(provider.onEvents[RENDERED_EVENT_TYPE])
					..listen(provider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][NAME_DISCRIMINATOR])
					..listens([provider.onToDiscriminateEvents[UPDATED_EVENT_TYPE][ADDRESS_DISCRIMINATOR], provider.onEvents[UPDATED_EVENT_TYPE]]);

			provider[RENDERED_EVENT_TYPE].dispatch(new FLEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[NAME_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
			(provider[UPDATED_EVENT_TYPE] as ToDiscriminateEventStreamProvider)[ADDRESS_DISCRIMINATOR].dispatch(new DiscriminatedEvent());
		});
	});
*/
}
