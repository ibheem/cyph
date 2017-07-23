import {Injectable} from '@angular/core';
import {Subject} from 'rxjs';
import {PairwiseSession} from '../../crypto/castle/pairwise-session';
import {ICastle} from '../../crypto/icastle';
import {LockFunction} from '../../lock-function-type';
import {util} from '../../util';
import {SessionService} from '../session.service';
import {PotassiumService} from './potassium.service';


/**
 * @see ICastle
 */
@Injectable()
export class CastleService implements ICastle {
	/** @ignore */
	protected readonly pairwiseSession: Subject<PairwiseSession>	=
		new Subject<PairwiseSession>()
	;

	/** @ignore */
	protected readonly pairwiseSessionLock: LockFunction			= util.lockFunction();

	/** @ignore */
	protected async getPairwiseSession () : Promise<PairwiseSession> {
		return this.pairwiseSessionLock(async () => this.pairwiseSession.take(1).toPromise());
	}

	/** Initializes service. */
	public async init (
		_POTASSIUM_SERVICE: PotassiumService,
		_SESSION_SERVICE: SessionService
	) : Promise<void> {
		throw new Error('Must provide an implementation of CastleService.init.');
	}

	/** @inheritDoc */
	public async receive (cyphertext: Uint8Array) : Promise<void> {
		return (await this.getPairwiseSession()).receive(cyphertext);
	}

	/** @inheritDoc */
	public async send (plaintext: string|ArrayBufferView, timestamp?: number) : Promise<void> {
		if (timestamp === undefined) {
			timestamp	= await util.timestamp();
		}

		return (await this.getPairwiseSession()).send(plaintext, timestamp);
	}

	constructor () {}
}
