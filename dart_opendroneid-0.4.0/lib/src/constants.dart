const maxMessageSize = 25;
const maxIDByteSize = 20;
const maxStringByteSize = 23;
const maxAuthDataPages = 16;
const maxAuthPageZeroSize = 17;
const maxAuthPageNonZeroSize = 23;
const maxAuthData =
    maxAuthPageZeroSize + (maxAuthDataPages - 1) * maxAuthPageNonZeroSize;
const maxMessagesInPack = 9;
const maxMessagePackSize = maxMessageSize * maxMessagesInPack;
const latLonMultiplier = 1e-7;
const verticalSpeedMultiplier = 0.5;
const areaRadiusMultiplier = 10;
const odidEpochOffset = 1546300800;
