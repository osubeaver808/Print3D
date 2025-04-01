pinLength = 6;
transitionLength = 1.5;
labelLength = 13;

pinWidth = 0.8;
labelWidth = 5;

linear_extrude(pinWidth)
polygon([
	[0, -pinWidth / 2],
	[pinLength, -pinWidth / 2],
	[pinLength + transitionLength, -labelWidth / 2],
	[pinLength + transitionLength + labelLength, -labelWidth / 2],
	[pinLength + transitionLength + labelLength, labelWidth / 2],
	[pinLength + transitionLength, labelWidth / 2],
	[pinLength, pinWidth / 2],
	[0, pinWidth / 2]
]);
