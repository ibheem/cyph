import {Users} from '../../session/enums';


/**
 * Represents cyphertext chat UI component.
 */
export interface ICyphertext {
	/** Cyphertext message list. */
	messages: {author: Users; text: string;}[];

	/**
	 * Hides cyphertext UI.
	 */
	hide () : void;

	/**
	 * Logs new cyphertext message.
	 * @param text
	 * @param author
	 */
	log (text: string, author: Users) : void;

	/**
	 * Shows cyphertext UI.
	 */
	show () : void;
}
