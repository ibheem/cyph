import {Subject} from 'rxjs/Subject';
import {ISessionMessage} from '../cyph/proto';


/**
 * Bridge between the demo service and chat UI.
 */
export class ChatData {
	/** Gives command to start. */
	public resolveStart: () => void;

	/** Awaits command to start. */
	public readonly start: Promise<void>;

	constructor (
		/** Indicates whether to display the mobile chat UI. */
		public readonly isMobile: boolean,

		/** Incoming end of local channel. */
		public readonly channelIncoming: Subject<ISessionMessage> = new Subject<ISessionMessage>(),

		/** Outgoing end of local channel. */
		public readonly channelOutgoing: Subject<ISessionMessage> = new Subject<ISessionMessage>(),

		/** Stream of messages to send. */
		public readonly message: Subject<string> = new Subject<string>(),

		/** Stream of commands to scroll down. */
		public readonly scrollDown: Subject<void> = new Subject<void>(),

		/** Stream of commands to show the cyphertext UI. */
		public readonly showCyphertext: Subject<void> = new Subject<void>()
	) {
		this.start	= new Promise<void>(resolve => {
			this.resolveStart	= resolve;
		});
	}
}
