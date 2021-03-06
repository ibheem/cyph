import {config} from '../config';
import {potassiumUtil} from '../crypto/potassium/potassium-util';
import {random} from './random';


/** Random ID meant optimized for readability by humans. Uses Config.readableIDCharacters. */
export const readableID	= (length: number = 0) : string => {
	let id	= '';
	for (let i = 0 ; i < length ; ++i) {
		id += config.readableIDCharacters[random(config.readableIDCharacters.length)];
	}
	return id;
};

/** Creates a hex string containing the current timestamp and 16 random bytes. */
export const uuid	= () : string => {
	const bytes	= potassiumUtil.concatMemory(
		true,
		/* tslint:disable-next-line:ban */
		new Uint32Array([Date.now()]),
		potassiumUtil.randomBytes(16)
	);
	const hex	= potassiumUtil.toHex(bytes);
	potassiumUtil.clearMemory(bytes);
	return hex;
};
