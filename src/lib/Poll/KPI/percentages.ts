/** Round a complete probability distribution to tenths of a percent totaling 100. */
export function kpiPercentages(values: (string | null)[]): (number | null)[] {
	const probabilities = values.map((value) =>
		value === null ? null : Number(value)
	);
	const total = probabilities.reduce<number>(
		(sum, value) => sum + (value ?? 0),
		0
	);
	// Only reconcile rounding for complete distributions, allowing database decimal precision.
	if (
		probabilities.some(
			(value) => value === null || !Number.isFinite(value) || value < 0
		) ||
		Math.abs(total - 1) > values.length * 0.0000001
	) {
		return probabilities.map((value) =>
			value === null ? null : Math.round(value * 1000) / 10
		);
	}

	const exact = probabilities.map((value) => (value! / total) * 1000);
	const tenths = exact.map(Math.floor);
	const remainder = 1000 - tenths.reduce((sum, value) => sum + value, 0);
	const order = exact
		.map((value, index) => ({ index, fraction: value - tenths[index] }))
		.sort((a, b) => b.fraction - a.fraction || a.index - b.index);
	for (let i = 0; i < remainder; i++) {
		tenths[order[i].index]++;
	}
	return tenths.map((value) => value / 10);
}
