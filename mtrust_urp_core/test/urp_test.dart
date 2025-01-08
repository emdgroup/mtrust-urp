// ignore_for_file: lines_longer_than_80_chars
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mtrust_urp_core/mtrust_urp_core.dart';
import 'package:mtrust_urp_types/sec.pb.dart';

void main() {
  group(
    'Testing correct generation of byte array for core commands', 
    () {
      final cmdWrapper = CmdWrapper();

      UrpMessage getUrpMessage(UrpCoreCommand cmd) {
        return UrpMessage(
          header: UrpMessageHeader(
            seqNr: 1,
            target: UrpDeviceIdentifier(
              deviceClass: UrpDeviceClass.urpReader,
              deviceType: UrpDeviceType.urpSec,
            ),
            origin: UrpDeviceIdentifier(
              deviceClass: UrpDeviceClass.urpHost,
              deviceType: UrpDeviceType.urpMobile,
            ),
          ),
          request: UrpRequest(
            payload: UrpSecCommandWrapper(
              coreCommand: cmd,
            ).writeToBuffer(),
          ),
        );
      }

      Uint8List int16ToBytes(int value) {
        if (value < -32768 || value > 32767) {
          throw ArgumentError('Value must be between -32768 and 32767.');
        }

        final bytes = Uint8List(2);

        // Store the two bytes in little-endian order
        bytes[0] = (value >> 8) & 0xFF; // Upper byte
        bytes[1] = value & 0xFF; // Lower byte

        return bytes;
      }

      test('Ping command', () {
        final message = getUrpMessage(cmdWrapper.ping());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 00';
        expect(hexString, equals(expected));
      });

      test('Get info command', () {
        final message = getUrpMessage(cmdWrapper.info());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 01';
        expect(hexString, equals(expected));
      });

      test('Get power command', () {
        final message = getUrpMessage(cmdWrapper.getPower());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 02';
        expect(hexString, equals(expected));
      });

      test('Set name command', () {
        final message = getUrpMessage(cmdWrapper.setName(null));
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 03';
        expect(hexString, equals(expected));
      });

      test('Get name command', () {
        final message = getUrpMessage(cmdWrapper.getName());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 04';
        expect(hexString, equals(expected));
      });

      test('Pair command', () {
        final message = getUrpMessage(cmdWrapper.pair());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 05';
        expect(hexString, equals(expected));
      });

      test('Unpair command', () {
        final message = getUrpMessage(cmdWrapper.unpair());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 06';
        expect(hexString, equals(expected));
      });

      test('Start AP command', () {
        final message = getUrpMessage(cmdWrapper.startAP("Test", "Test"));
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 26 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 14 0a 12 0a 10 08 07 1a 0c 0a 04 54 65 73 74 12 04 54 65 73 74'; //TODO:
        expect(hexString, equals(expected));
      });

      test('Stop AP command', () {
        final message = getUrpMessage(cmdWrapper.stopAP());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 08';
        expect(hexString, equals(expected));
      });

      test('Connect AP command', () {
        final message = getUrpMessage(cmdWrapper.connectAP("Test", "Test"));
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 26 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 14 0a 12 0a 10 08 09 1a 0c 0a 04 54 65 73 74 12 04 54 65 73 74';
        expect(hexString, equals(expected));
      });

      test('Disconnect AP command', () {
        final message = getUrpMessage(cmdWrapper.disconnectAP());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 0a';
        expect(hexString, equals(expected));
      });

      test('Start DFU command', () {
        final message = getUrpMessage(cmdWrapper.startDFU());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 0b';
        expect(hexString, equals(expected));
      });

      test('Stop DFU command', () {
        final message = getUrpMessage(cmdWrapper.stopDFU());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 0c';
        expect(hexString, equals(expected));
      });

      test('Sleep command', () {
        final message = getUrpMessage(cmdWrapper.sleep());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 0d';
        expect(hexString, equals(expected));
      });

      test('Off command', () {
        final message = getUrpMessage(cmdWrapper.off());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 0e';
        expect(hexString, equals(expected));
      });

      test('Reboot command', () {
        final message = getUrpMessage(cmdWrapper.reboot());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 0f';
        expect(hexString, equals(expected));
      });

      test('Stay awake command', () {
        final message = getUrpMessage(cmdWrapper.stayAwake());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 10';
        expect(hexString, equals(expected));
      });

      test('Get public key command', () {
        final message = getUrpMessage(cmdWrapper.getPublicKey());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 11';
        expect(hexString, equals(expected));
      });

      test('Get device id command', () {
        final message = getUrpMessage(cmdWrapper.getDeviceId());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 12';
        expect(hexString, equals(expected));
      });

      test('Identify command', () {
        final message = getUrpMessage(cmdWrapper.identify());
        final bytes = message.writeToBuffer();
        final length = int16ToBytes(bytes.length);
        final messageBytes = length + bytes;
        final hexString = messageBytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
        const expected = '00 18 0a 0e 08 01 22 04 08 02 10 04 2a 04 08 00 10 01 12 06 0a 04 0a 02 08 13';
        expect(hexString, equals(expected));
      });
    },
  );
}
