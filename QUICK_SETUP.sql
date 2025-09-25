-- QUICK SETUP GUIDE --
-- Copy and paste this in your Supabase SQL Editor (supabase.com)

-- Step 1: Create the signaling table
CREATE TABLE IF NOT EXISTS signaling (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_code VARCHAR(8) UNIQUE NOT NULL,
    files JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Step 2: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_signaling_room_code ON signaling(room_code);
CREATE INDEX IF NOT EXISTS idx_signaling_expires_at ON signaling(expires_at);

-- Step 3: Enable Row Level Security
ALTER TABLE signaling ENABLE ROW LEVEL SECURITY;

-- Step 4: Allow public access (since this is a public sharing app)
CREATE POLICY "Allow public access" ON signaling FOR ALL USING (true);

-- Step 5: Create the storage bucket
INSERT INTO storage.buckets (id, name, public) VALUES ('shared-files', 'shared-files', true)
ON CONFLICT (id) DO NOTHING;

-- Step 6: Set up storage policies
CREATE POLICY "Allow public uploads" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'shared-files');
CREATE POLICY "Allow public downloads" ON storage.objects FOR SELECT USING (bucket_id = 'shared-files');
CREATE POLICY "Allow public deletes" ON storage.objects FOR DELETE USING (bucket_id = 'shared-files');

-- IMPORTANT: Your app is already configured with these credentials:
-- URL: https://fmjncwprwibklcafgxps.supabase.co
-- ANON KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZtam5jd3Byd2lia2xjYWZneHBzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ3Njg0NTEsImV4cCI6MjA1MDM0NDQ1MX0.L3K_4FoJjh-4MRqk2rGkjNjzN5bkuJM8fgBqRl7qZ7Y

-- Run this SQL and your app will be ready to use!