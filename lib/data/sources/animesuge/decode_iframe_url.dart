// I really wish I knew what was going on
String decodeIFrameUrl(String code) {
  var one = code.substring(0, 9);
  var two = code.substring(9);

  var encoded = 0;
  var count = 0;
  var start = '';

  for (var character in two.split('')) {
    encoded <<= 6;

    var index =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
            .indexOf(character.toString());
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

  var arr = <int, int>{};
  var i = 0;
  var byteSize = 256;
  var result = '';

  for (var c = 0; c < byteSize; c++) {
    arr[c] = c;
  }

  var x = 0;
  for (var c = 0; c < byteSize; c++) {
    x = (x + arr[c]! + one[c % one.length].runes.first) % byteSize;
    i = arr[c]!;
    arr[c] = arr[x]!;
    arr[x] = i;
  }

  x = 0;
  var d = 0;

  for (var s = 0; s < start.length; s++) {
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
