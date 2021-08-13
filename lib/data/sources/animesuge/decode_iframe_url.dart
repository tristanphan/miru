// I really wish I knew what was going on
String decodeIFrameUrl(String code) {
  String one = code.substring(0, 9);
  String two = code.substring(9);

  int encoded = 0;
  int count = 0;
  String start = '';

  for (String character in two.split('')) {
    encoded <<= 6;

    int index =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            .indexOf(
      character.toString(),
    );
    if (index != -1) {
      encoded |= index;
    }

    count++;

    if (count == 4) {
      start += String.fromCharCode((16711680 & encoded) >> 16);
      start += String.fromCharCode((65280 & encoded) >> 8);
      start += String.fromCharCode(255 & encoded);

      encoded = 0;
      count = 0;
    }
  }

  if (count == 2) {
    encoded >>= 4;
    start += String.fromCharCode(encoded);
  } else if (count == 3) {
    start += String.fromCharCode((65280 & encoded) >> 8);
    start += String.fromCharCode(255 & encoded);
  }

  try {
    start = Uri.decodeFull(start);
  } catch (e) {}

  Map<int, int> arr = {};
  int i = 0;
  int byteSize = 256;
  String result = '';

  for (int c = 0; c < byteSize; c++) {
    arr[c] = c;
  }

  int x = 0;
  for (int c = 0; c < byteSize; c++) {
    x = (x + arr[c]! + one[c % one.length].runes.first) % byteSize;
    i = arr[c]!;
    arr[c] = arr[x]!;
    arr[x] = i;
  }

  x = 0;
  int d = 0;

  for (int s = 0; s < start.length; s++) {
    d = (d + 1) % byteSize;
    x = (x + arr[d]!) % byteSize;

    i = arr[d]!;
    arr[d] = arr[x]!;
    arr[x] = i;

    result += String.fromCharCode(
        (start[s]).runes.first ^ arr[(arr[d]! + arr[x]!) % byteSize]!);
  }

  return result;
}
