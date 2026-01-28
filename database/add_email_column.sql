-- ================================================
-- MIGRATION: Add email column to users table
-- ================================================
-- Run this in your Supabase SQL Editor to fix login
-- ================================================

-- Step 1: Add email column to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS email TEXT;

-- Step 2: Populate existing users with their emails from auth.users
UPDATE public.users
SET email = auth.users.email
FROM auth.users
WHERE public.users.id = auth.users.id
AND public.users.email IS NULL;

-- Step 3: Update the handle_new_user trigger to include email
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    INSERT INTO public.users (
        id,
        email,
        codename,
        country,
        phone,
        city,
        postal_code,
        reason,
        created_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'codename', 'Agent-' || substring(NEW.id::text, 1, 8)),
        NEW.raw_user_meta_data->>'country',
        NEW.raw_user_meta_data->>'phone',
        NEW.raw_user_meta_data->>'city',
        NEW.raw_user_meta_data->>'postal_code',
        NEW.raw_user_meta_data->>'reason',
        NOW()
    );
    RETURN NEW;
END;
$$;

COMMENT ON COLUMN public.users.email IS 'User email address (copied from auth.users for easier queries)';
