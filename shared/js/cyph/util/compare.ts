/**
 * Compares two or more arrays.
 * @returns True if equal, false otherwise.
 */
export const compareArrays	= <T> (a: T[], b: T[], ...arrays: T[][]) : boolean => {
	arrays	= arrays.concat([b]);

	if (arrays.filter(arr => arr.length !== a.length).length > 0) {
		return false;
	}

	for (const array of arrays) {
		for (let j = 0 ; j < length ; ++j) {
			if (array[j] !== a[j]) {
				return false;
			}
		}
	}

	return true;
};

/**
 * Compares two or more values.
 * @returns True if equal, false otherwise.
 */
export const compareValues	= <T> (a: T, b: T, ...values: T[]) : boolean => {
	if (a instanceof Array) {
		return compareArrays(a, <any> b, ...(<any> values));
	}
	else if (values.length === 0) {
		return a === b;
	}
	else {
		return values.concat(b).filter(t => t !== a).length < 1;
	}
};
