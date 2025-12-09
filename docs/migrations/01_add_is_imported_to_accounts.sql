-- Migration: Add is_imported field to accounts table
-- This field marks accounts that were imported via CSV and cannot be deleted

ALTER TABLE accounts 
ADD COLUMN IF NOT EXISTS is_imported BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_accounts_is_imported ON accounts(is_imported);

COMMENT ON COLUMN accounts.is_imported IS 'Marks accounts imported via CSV. These accounts cannot be deleted.';

