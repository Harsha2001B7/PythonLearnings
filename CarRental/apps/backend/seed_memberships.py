import sqlite3

def seed_memberships():
    conn = sqlite3.connect('../data/sqlite/falconview.db')
    cursor = conn.cursor()

    tiers = [
        (1, 'Scout', 'The perfect starting point', 0.0, None, False, None, 'Start for Free'),
        (2, 'Vantage', 'The curated driving life', 299.0, 2990.0, True, 'Most Popular', 'Join Vantage'),
        (3, 'Apex', 'No limits. No waiting.', 799.0, 7990.0, False, 'Apex Exclusive', 'Apply for Apex'),
    ]

    cursor.executemany('''
        INSERT OR IGNORE INTO membership_tiers 
        (id, name, tagline, price_per_month, price_per_year, highlighted, badge, cta_label)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', tiers)

    features = [
        (1, 1, 'Access to full fleet catalogue', True),
        (2, 1, 'Standard booking confirmation', True),
        (3, 1, '10% discount on weekly rentals', True),
        (4, 1, 'Basic roadside support', True),
        (5, 1, 'Priority fleet selection', False),
        (6, 1, 'Airport concierge delivery', False),
        (7, 1, 'Exclusive member events', False),
        (8, 1, 'Personal account manager', False),

        (9, 2, 'Access to full fleet catalogue', True),
        (10, 2, 'Same-day booking confirmation', True),
        (11, 2, '20% discount on all rentals', True),
        (12, 2, '24/7 premium roadside support', True),
        (13, 2, 'Priority fleet selection', True),
        (14, 2, 'Airport concierge delivery', True),
        (15, 2, 'Exclusive member events', False),
        (16, 2, 'Personal account manager', False),

        (17, 3, 'Unlimited fleet access — any model', True),
        (18, 3, 'Instant booking, no approval wait', True),
        (19, 3, '30% discount + loyalty credits', True),
        (20, 3, 'Dedicated concierge line — 24/7', True),
        (21, 3, 'Priority fleet selection + first access', True),
        (22, 3, 'Anywhere-in-UAE delivery, any hour', True),
        (23, 3, 'VIP member events & track days', True),
        (24, 3, 'Named personal account manager', True),
    ]

    cursor.executemany('''
        INSERT OR IGNORE INTO membership_features 
        (id, tier_id, text, included)
        VALUES (?, ?, ?, ?)
    ''', features)

    conn.commit()
    conn.close()
    print("Seeded memberships successfully.")

if __name__ == "__main__":
    seed_memberships()
