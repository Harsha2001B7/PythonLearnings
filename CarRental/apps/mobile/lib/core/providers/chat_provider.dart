import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/fleet_repository.dart';
import '../models/faq.dart';

class ChatMessageModel {
  final String id;
  final String role; // 'user' or 'assistant'
  final String text;
  final int timestamp;

  ChatMessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
  });
}

class ChatState {
  final bool isOpen;
  final List<ChatMessageModel> messages;
  final bool isTyping;

  ChatState({
    required this.isOpen,
    required this.messages,
    required this.isTyping,
  });

  ChatState copyWith({
    bool? isOpen,
    List<ChatMessageModel>? messages,
    bool? isTyping,
  }) {
    return ChatState(
      isOpen: isOpen ?? this.isOpen,
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier()
      : super(ChatState(
          isOpen: false,
          messages: [],
          isTyping: false,
        ));

  final List<Map<String, dynamic>> keywordRules = [
    {
      'keywords': ['price', 'cost', 'how much', 'rate', 'aed', 'fee', 'expensive', 'cheap'],
      'response': 'Great question about pricing! Our fleet starts from **AED 1,000/day** for the BMW M8 Gran Coupe up to **AED 2,500/day** for the Rolls-Royce Spectre. Vantage members save 20%, Apex members save 30%. Weekly and monthly rates have further discounts (15% and 25% off respectively). Want me to help you find vehicles in a specific budget?',
    },
    {
      'keywords': ['insurance', 'cover', 'accident', 'excess', 'damage', 'claim'],
      'response': 'Every SAFRA rental includes comprehensive insurance: third-party liability, collision damage waiver (CDW), and theft protection. The standard excess is AED 3,000. You can reduce this to zero by adding Super Coverage at checkout (AED 120–280/day), or it\'s automatically included with Apex membership. Need more detail on any specific scenario?',
    },
    {
      'keywords': ['deliver', 'delivery', 'location', 'airport', 'hotel', 'address', 'bring', 'drop off', 'pickup'],
      'response': 'We deliver to any address across all seven Emirates — hotels, residences, offices, and all major airports. Vantage members get free delivery within Dubai. Apex members enjoy complimentary anywhere-in-UAE delivery, any time of day. We recommend booking at least 6 hours ahead for airport deliveries. Where would you like your vehicle delivered?',
    },
    {
      'keywords': ['cancel', 'cancellation', 'refund', 'modify', 'change booking'],
      'response': 'Modifications are free up to 48 hours before pick-up. Cancellations more than 48 hours in advance are fully refunded. Late cancellations (within 48 hours) incur a 1-day rental fee. Apex members enjoy penalty-free cancellation at any time. Is there something about your current or planned booking I can help with?',
    },
    {
      'keywords': ['membership', 'tier', 'vantage', 'apex', 'scout', 'join', 'subscribe', 'benefits'],
      'response': 'We have three membership tiers:\n\n🔹 **Scout** — Free. Access to the full fleet, basic support, 10% weekly discount.\n🔸 **Vantage** — AED 299/month. Same-day confirmation, 20% discount, free Dubai delivery, 24/7 support.\n⭐ **Apex** — AED 799/month. Instant booking, 30% discount, UAE-wide delivery, zero excess, VIP events, personal account manager.\n\nWhich tier interests you?',
    },
    {
      'keywords': ['electric', 'ev', 'charge', 'range', 'battery', 'plug'],
      'response': 'Our electric fleet is growing fast — currently 40% of vehicles are electric or hybrid. Top picks: **Rolls-Royce Spectre** (530 km range, AED 2,500/day) and **Audi RS e-tron GT** (472 km range, AED 1,100/day). All EVs arrive fully charged. Apex and Vantage members also get a complimentary UAE charging network access card. Want to see our full EV lineup?',
    },
    {
      'keywords': ['document', 'licence', 'license', 'passport', 'id', 'requirement', 'need'],
      'response': 'You\'ll need: a **valid UAE driving licence** (or international licence with notarised Arabic translation), a **passport copy**, and a **credit card** for the security deposit. GCC nationals may use their national ID. All verification is done digitally through the SAFRA app — no paperwork at handoff. Any questions about specific document requirements?',
    },
    {
      'keywords': ['hello', 'hi', 'hey', 'good morning', 'good evening', 'greet'],
      'response': 'Hello! Welcome to SAFRA. I\'m your AI concierge — ask me anything about our fleet, pricing, insurance, delivery, or membership tiers. How can I help you today?',
    },
    {
      'keywords': ['book', 'reserve', 'booking', 'reservation', 'how to book'],
      'response': 'Booking with SAFRA takes under 90 seconds:\n1. **Search** — browse and filter our fleet\n2. **Select** — choose your vehicle\n3. **Confirm** — digital ID + instant insurance\n4. **Drive** — we deliver to you\n\nScout bookings confirm within 2 hours, Vantage same-day, Apex instantly. Ready to browse the fleet? Use the explorer on this page, or I can help you find the right vehicle based on your needs.',
    },
    {
      'keywords': ['thank', 'thanks', 'perfect', 'great', 'awesome', 'helpful'],
      'response': 'You\'re very welcome! Is there anything else I can help you with — specific vehicles, pricing for particular dates, or questions about membership? I\'m here whenever you need me. 🔑',
    },
  ];

  final List<String> fallbackResponses = [
    'I\'d love to help you with that. Could you give me a bit more detail? For example — are you asking about a specific vehicle, a booking question, or something about our services?',
    'That\'s a great question. Our human concierge team is available 24/7 if I can\'t fully answer it here — they can be reached directly through the app. Want me to cover anything about our fleet, pricing, insurance, or delivery while you\'re here?',
    'I\'m not sure I caught all the details there. I can help with questions about pricing, insurance, delivery, vehicle specs, membership, or the booking process. Which area interests you?',
  ];

  int fallbackIndex = 0;

  void setOpen(bool open) {
    state = state.copyWith(isOpen: open);
    if (open && state.messages.isEmpty) {
      // Add first welcome message with slight delay
      Future.delayed(const Duration(milliseconds: 400), () {
        addMessage(
          role: 'assistant',
          text: 'Hello! I\'m SAFRA\'s AI concierge 👋\n\nAsk me anything — fleet availability, pricing, insurance, delivery options, or membership tiers. I\'m here to help.',
        );
      });
    }
  }

  void addMessage({required String role, required String text}) {
    final msg = ChatMessageModel(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}-${Random().nextDouble()}',
      role: role,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  void setTyping(bool typing) {
    state = state.copyWith(isTyping: typing);
  }

  void clearHistory() {
    state = state.copyWith(messages: []);
  }

  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || state.isTyping) return;

    // User message
    addMessage(role: 'user', text: trimmedText);
    setTyping(true);

    // AI Concierge Response simulation
    final lower = trimmedText.toLowerCase();
    String reply = '';

    // Check keyword rules
    bool matched = false;
    for (final rule in keywordRules) {
      final List<String> keywords = rule['keywords'];
      if (keywords.any((kw) => lower.contains(kw))) {
        reply = rule['response'];
        matched = true;
        break;
      }
    }

    if (!matched) {
      // Try matching FAQ questions/answers
      final faqMatch = FleetRepository.faqData.firstWhere(
        (f) =>
            f.question.toLowerCase().split(' ').any((w) => w.length > 4 && lower.contains(w)) ||
            lower.contains(f.category),
        orElse: () => const FAQItem(id: -1, question: '', answer: '', category: ''),
      );

      if (faqMatch.id != -1) {
        reply = faqMatch.answer;
      } else {
        // Fallback
        reply = fallbackResponses[fallbackIndex % fallbackResponses.length];
        fallbackIndex++;
      }
    }

    // Simulate network delay (1.2 to 2.2 seconds)
    final delayMs = 1200 + Random().nextInt(1000);
    await Future.delayed(Duration(milliseconds: delayMs));

    setTyping(false);
    addMessage(role: 'assistant', text: reply);
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
