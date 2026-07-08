import sqlite3
import bcrypt

def seed_auth():
    conn = sqlite3.connect('../data/sqlite/falconview.db')
    cursor = conn.cursor()

    # Create default roles
    roles = [
        (1, 'Admin'),
        (2, 'User')
    ]
    cursor.executemany('''
        INSERT OR IGNORE INTO roles (id, name) VALUES (?, ?)
    ''', roles)

    # Check if admin already exists
    cursor.execute("SELECT id FROM users WHERE email = 'admin@falconview.com'")
    admin_exists = cursor.fetchone()

    if not admin_exists:
        password = "AdminPassword123"
        hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        
        # Insert admin user
        cursor.execute('''
            INSERT INTO users (first_name, last_name, email, password_hash, role_id, status, is_verified, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, datetime('now'), datetime('now'))
        ''', ('FalconView', 'Admin', 'admin@falconview.com', hashed, 1, 'active', 1))

    conn.commit()
    conn.close()
    print("Seeded roles and default admin successfully.")

if __name__ == "__main__":
    seed_auth()
