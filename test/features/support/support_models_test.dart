import 'package:flutter_test/flutter_test.dart';
import 'package:ground_guard_app/features/support/data/models/help_content_model.dart';
import 'package:ground_guard_app/features/support/data/models/support_message_model.dart';

void main() {
  group('SupportMessageModel', () {
    test('parses a user message and converts the time to local', () {
      final m = SupportMessageModel.fromJson({
        'uuid': 'm1',
        'sender': 'USER',
        'body': 'Meu sensor não conecta',
        'created_at': '2026-11-04T23:10:00Z',
      });
      expect(m.uuid, 'm1');
      expect(m.isFromUser, isTrue);
      expect(m.body, 'Meu sensor não conecta');
      expect(m.createdAt.isUtc, isFalse);
      expect(m.createdAt.toUtc(), DateTime.utc(2026, 11, 4, 23, 10));
      expect(m.pending, isFalse);
      expect(m.failed, isFalse);
    });

    test('support replies are not from the user', () {
      final m = SupportMessageModel.fromJson({'sender': 'SUPPORT'});
      expect(m.isFromUser, isFalse);
      expect(m.body, '');
    });

    test('a bad timestamp falls back to now instead of crashing', () {
      final before = DateTime.now();
      final m = SupportMessageModel.fromJson({'created_at': 'garbage'});
      expect(m.createdAt.isBefore(before), isFalse);
    });

    test('copyWith toggles delivery flags only', () {
      final m = SupportMessageModel.fromJson({
        'uuid': 'm1',
        'sender': 'USER',
        'body': 'oi',
      });
      final failed = m.copyWith(failed: true);
      expect(failed.failed, isTrue);
      expect(failed.pending, isFalse);
      expect(failed.uuid, 'm1');
      expect(failed.body, 'oi');
      expect(failed.copyWith(pending: true, failed: false).pending, isTrue);
    });
  });

  group('HelpContentModel', () {
    test('parses an article', () {
      final h = HelpContentModel.fromJson({
        'uuid': 'h1',
        'title': 'Wi-Fi compatível',
        'category': 'IOT',
        'content': 'Use 2,4 GHz',
        'order_number': 2,
      });
      expect(h.uuid, 'h1');
      expect(h.title, 'Wi-Fi compatível');
      expect(h.category, 'IOT');
      expect(h.content, 'Use 2,4 GHz');
      expect(h.orderNumber, 2);
    });

    test('missing fields fall back to empty values', () {
      final h = HelpContentModel.fromJson({});
      expect(h.title, '');
      expect(h.orderNumber, 0);
    });
  });
}
