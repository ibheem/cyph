import {Component, OnInit} from '@angular/core';
import {ActivatedRoute, Router} from '@angular/router';
import {Observable} from 'rxjs';
import {AccountFileRecord, IAccountFileRecord} from '../../proto';
import {AccountFilesService} from '../services/account-files.service';
import {AccountService} from '../services/account.service';
import {AccountAuthService} from '../services/crypto/account-auth.service';


/**
 * Angular component for an individual note.
 */
@Component({
	selector: 'cyph-account-note-edit',
	styleUrls: ['../../../css/components/account-note.scss'],
	templateUrl: '../../../templates/account-note.html'
})
export class AccountNoteEditComponent implements OnInit {
	/** Current note. */
	public note?: {
		data: Promise<string>;
		downloadProgress: Observable<number>;
		metadata: Promise<IAccountFileRecord>;
	};

	/** @inheritDoc */
	public ngOnInit () : void {
		this.activatedRouteService.params.subscribe(async o => {
			try {
				const id: string|undefined	= o.id;

				if (!id) {
					throw new Error('Invalid note ID.');
				}

				await this.accountAuthService.ready;

				const downloadTask	= this.accountFilesService.downloadNote(id);

				this.note	= {
					data: downloadTask.result,
					downloadProgress: downloadTask.progress,
					metadata: this.accountFilesService.getFile(
						id,
						AccountFileRecord.RecordTypes.Note
					)
				};
			}
			catch (_) {
				this.routerService.navigate(['404']);
			}
		});
	}

	constructor (
		/** @ignore */
		private readonly activatedRouteService: ActivatedRoute,

		/** @ignore */
		private readonly routerService: Router,

		/** @ignore */
		private readonly accountAuthService: AccountAuthService,

		/** @see AccountService */
		public readonly accountService: AccountService,

		/** @see AccountFilesService */
		public readonly accountFilesService: AccountFilesService
	) {}
}
