// Copyright (c) 2013 the DartBeans project authors.
// Please see the AUTHORS file for details.
// Use of this source code is governed by a
// MIT-style license that can be found in the LICENSE file.

part of dartbeans;

/// A base event received by a [FLEventTarget].
class FLEvent {

	FLEventTarget _target;

	String _type;

	final List<BubbleTargetReference> _bubbleReferences;

	FLEvent() : _bubbleReferences = [];

	/// Returns the type of the event.
	String get type => _type;

	/// Returns the target that first received the event.
	FLEventTarget get target {
		return (_target is EventTargetDelegatee ? (_target as EventTargetDelegatee).delegatorTarget : _target);
	}

	/// Whether the event is received during the bubbling phase.
	bool get bubbled => _bubbleReferences.isNotEmpty;

	/**
   *  Returns the target that received the event
   *  during the bubbling phase.
   *  Returns null if the event doesn't come from the bubbling phase.
   */
	FLEventTarget get bubbleTarget {
		var bubbleTarget = bubbled ? _bubbleReferences.last.bubbleTarget : null;
		return (bubbleTarget is EventTargetDelegatee ? (bubbleTarget as EventTargetDelegatee).delegatorTarget : bubbleTarget);
	}

	/**
   *  Returns the indentifier of the target that bubbled the event.
   *  Returns null if the event doesn't come from the bubbling phase.
   */
	dynamic get bubblingId => bubbled ? _bubbleReferences.last.bubblingId : null;

	List<BubbleTargetReference> get bubbleReferences => _bubbleReferences;

	bool _contains(BubbleTargetReference reference) {
		return _bubbleReferences.contains(reference);
	}

	/**
   *  Clones the event.
   *  This method is used internally during the bubbling phase.
   */
	FLEvent clone() => new FLEvent();

	String toString() {
		StringBuffer buffer = new StringBuffer();

		_bubbleReferences.reversed.forEach((reference) {
			buffer.write((reference.bubbleTarget is EventTargetDelegatee ? (reference.bubbleTarget as EventTargetDelegatee).delegatorTarget : reference.bubbleTarget));
			buffer
					..write("/")
					..write(reference.bubblingId)
					..write("=");
		});

		buffer
				..write(target)
				..write("->")
				..write(_type);
		return buffer.toString();
	}
}

/**
 * An event that is identified by its [type]
 * and an additional [discriminator].
 *
 * This kind of event allows to further discriminate
 * the type of events to listen to.
 *
 * A discriminated event is identified
 * by a postifix ([DISCRIMINATOR_POSTFIX])
 * in its type. For example: [: propertyChanged. :].
 */
class DiscriminatedEvent extends FLEvent {

	/// The postfix used to identify a discriminated event type.
	static const String DISCRIMINATOR_POSTFIX = ".";

	dynamic _discriminator;

	/**
   *  Returns the key that together
   *  with the [type] indentifies the event.
   */
	dynamic get discriminator => _discriminator;

	bool _contains(BubbleTargetReference reference) {
		return super._contains(reference) || (_discriminator == reference.bubblingId && identical(_target, reference.bubbleTarget));
	}


	FLEvent clone() => new DiscriminatedEvent();

	String toString() => super.toString() + discriminator.toString();
}
