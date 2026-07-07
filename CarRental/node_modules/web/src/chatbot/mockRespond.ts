// ─────────────────────────────────────────────────────────────────
// mockRespond — VANTA Chatbot Response Engine
// Keyword-matching rule-based system using FAQ data.
//
// Integration point:
// TODO: Replace the body of `mockRespond()` with a real API call:
//   const res = await fetch('/api/chat', {
//     method: 'POST',
//     body: JSON.stringify({ message: userMessage, history }),
//   });
//   const { reply } = await res.json();
//   return reply;
// ─────────────────────────────────────────────────────────────────
import { FAQ_DATA } from '../data/faq';

// Keyword → category/response mapping
const KEYWORD_RULES: { keywords: string[]; response: string }[] = [
  {
    keywords: ['price', 'cost', 'how much', 'rate', 'aed', 'fee', 'expensive', 'cheap'],
    response: `Great question about pricing! Our fleet starts from **AED 1,000/day** for the BMW M8 Gran Coupe up to **AED 2,500/day** for the Rolls-Royce Spectre. Vantage members save 20%, Apex members save 30%. Weekly and monthly rates have further discounts (15% and 25% off respectively). Want me to help you find vehicles in a specific budget?`,
  },
  {
    keywords: ['insurance', 'cover', 'accident', 'excess', 'damage', 'claim'],
    response: `Every SAFRA rental includes comprehensive insurance: third-party liability, collision damage waiver (CDW), and theft protection. The standard excess is AED 3,000. You can reduce this to zero by adding Super Coverage at checkout (AED 120–280/day), or it's automatically included with Apex membership. Need more detail on any specific scenario?`,
  },
  {
    keywords: ['deliver', 'delivery', 'location', 'airport', 'hotel', 'address', 'bring', 'drop off', 'pickup'],
    response: `We deliver to any address across all seven Emirates — hotels, residences, offices, and all major airports. Vantage members get free delivery within Dubai. Apex members enjoy complimentary anywhere-in-UAE delivery, any time of day. We recommend booking at least 6 hours ahead for airport deliveries. Where would you like your vehicle delivered?`,
  },
  {
    keywords: ['cancel', 'cancellation', 'refund', 'modify', 'change booking'],
    response: `Modifications are free up to 48 hours before pick-up. Cancellations more than 48 hours in advance are fully refunded. Late cancellations (within 48 hours) incur a 1-day rental fee. Apex members enjoy penalty-free cancellation at any time. Is there something about your current or planned booking I can help with?`,
  },
  {
    keywords: ['membership', 'tier', 'vantage', 'apex', 'scout', 'join', 'subscribe', 'benefits'],
    response: `We have three membership tiers:\n\n🔹 **Scout** — Free. Access to the full fleet, basic support, 10% weekly discount.\n🔸 **Vantage** — AED 299/month. Same-day confirmation, 20% discount, free Dubai delivery, 24/7 support.\n⭐ **Apex** — AED 799/month. Instant booking, 30% discount, UAE-wide delivery, zero excess, VIP events, personal account manager.\n\nWhich tier interests you?`,
  },
  {
    keywords: ['electric', 'ev', 'charge', 'range', 'battery', 'plug'],
    response: `Our electric fleet is growing fast — currently 40% of vehicles are electric or hybrid. Top picks: **Rolls-Royce Spectre** (530 km range, AED 2,500/day) and **Audi RS e-tron GT** (472 km range, AED 1,100/day). All EVs arrive fully charged. Apex and Vantage members also get a complimentary UAE charging network access card. Want to see our full EV lineup?`,
  },
  {
    keywords: ['document', 'licence', 'license', 'passport', 'id', 'requirement', 'need'],
    response: `You'll need: a **valid UAE driving licence** (or international licence with notarised Arabic translation), a **passport copy**, and a **credit card** for the security deposit. GCC nationals may use their national ID. All verification is done digitally through the SAFRA app — no paperwork at handoff. Any questions about specific document requirements?`,
  },
  {
    keywords: ['hello', 'hi', 'hey', 'good morning', 'good evening', 'greet'],
    response: `Hello! Welcome to SAFRA. I'm your AI concierge — ask me anything about our fleet, pricing, insurance, delivery, or membership tiers. How can I help you today?`,
  },
  {
    keywords: ['book', 'reserve', 'booking', 'reservation', 'how to book'],
    response: `Booking with SAFRA takes under 90 seconds:\n1. **Search** — browse and filter our fleet\n2. **Select** — choose your vehicle\n3. **Confirm** — digital ID + instant insurance\n4. **Drive** — we deliver to you\n\nScout bookings confirm within 2 hours, Vantage same-day, Apex instantly. Ready to browse the fleet? Use the explorer on this page, or I can help you find the right vehicle based on your needs.`,
  },
  {
    keywords: ['thank', 'thanks', 'perfect', 'great', 'awesome', 'helpful'],
    response: `You're very welcome! Is there anything else I can help you with — specific vehicles, pricing for particular dates, or questions about membership? I'm here whenever you need me. 🔑`,
  },
];

// Fallback responses when no keyword matches
const FALLBACK_RESPONSES = [
  `I'd love to help you with that. Could you give me a bit more detail? For example — are you asking about a specific vehicle, a booking question, or something about our services?`,
  `That's a great question. Our human concierge team is available 24/7 if I can't fully answer it here — they can be reached directly through the app. Want me to cover anything about our fleet, pricing, insurance, or delivery while you're here?`,
  `I'm not sure I caught all the details there. I can help with questions about pricing, insurance, delivery, vehicle specs, membership, or the booking process. Which area interests you?`,
];

let fallbackIndex = 0;

export function mockRespond(userMessage: string): Promise<string> {
  // TODO: Replace this entire function body with a real API call to /api/chat
  return new Promise((resolve) => {
    const lower = userMessage.toLowerCase();

    // Check keyword rules
    for (const rule of KEYWORD_RULES) {
      if (rule.keywords.some((kw) => lower.includes(kw))) {
        // Simulate network latency (1.2–2.2s)
        const delay = 1200 + Math.random() * 1000;
        return setTimeout(() => resolve(rule.response), delay);
      }
    }

    // Try FAQ data keyword match
    const faqMatch = FAQ_DATA.find(
      (f) =>
        f.question.toLowerCase().split(' ').some((w: string) => w.length > 4 && lower.includes(w)) ||
        lower.includes(f.category)
    );
    if (faqMatch) {
      return setTimeout(() => resolve(faqMatch.answer), 1400 + Math.random() * 800);
    }

    // Fallback
    const fallback = FALLBACK_RESPONSES[fallbackIndex % FALLBACK_RESPONSES.length];
    fallbackIndex++;
    setTimeout(() => resolve(fallback), 1200);
  });
}
