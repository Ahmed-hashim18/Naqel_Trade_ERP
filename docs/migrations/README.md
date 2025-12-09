# Database Migrations

Run these SQL files in order in the Supabase SQL Editor.

## Execution Order

### 1. `01_add_is_imported_to_accounts.sql`
Adds the `is_imported` field to the `accounts` table to protect imported accounts.

**When to run:** If you use the Chart of Accounts import functionality.

### 2. `02_enable_realtime.sql`
Enables real-time subscriptions for main tables.

**When to run:** If you want automatic updates in the frontend when data changes.

### 3. `03_setup_auth_rls_policies.sql`
Sets up Row Level Security (RLS) policies for authentication tables.

**When to run:** **REQUIRED** - Necessary for login to work correctly.

### 4. `04_setup_all_rls_policies.sql`
Sets up Row Level Security (RLS) policies for all application tables (accounts, customers, products, sales, purchases, etc.).

**When to run:** **REQUIRED** - Necessary for the application to work correctly. Run this after #3.

## Notes

- Run files in numerical order (01, 02, 03, 04)
- You can run each file independently if you've already applied the previous ones
- If you encounter errors, verify that the tables exist in your database
- RLS policies (#3) are critical for security and login functionality

## Verification

After running the migrations, you can verify:

```sql
-- Verify that is_imported exists
SELECT column_name FROM information_schema.columns 
WHERE table_name = 'accounts' AND column_name = 'is_imported';

-- Verify RLS policies
SELECT * FROM pg_policies 
WHERE tablename IN ('profiles', 'user_roles', 'roles');

-- Verify realtime (in Supabase Dashboard > Database > Replication)
```
