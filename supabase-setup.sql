-- Supabase setup for ShareMe Online
-- Run this in your Supabase SQL Editor

-- Create the signaling table for room management
CREATE TABLE IF NOT EXISTS signaling (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_code VARCHAR(8) UNIQUE NOT NULL,
    files JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_signaling_room_code ON signaling(room_code);
CREATE INDEX IF NOT EXISTS idx_signaling_expires_at ON signaling(expires_at);

-- Enable Row Level Security
ALTER TABLE signaling ENABLE ROW LEVEL SECURITY;

-- Allow public access for anonymous users (since this is a public file sharing app)
CREATE POLICY "Allow public access" ON signaling FOR ALL USING (true);

-- Create storage bucket for shared files
INSERT INTO storage.buckets (id, name, public) VALUES ('shared-files', 'shared-files', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies
CREATE POLICY "Allow public uploads" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'shared-files');
CREATE POLICY "Allow public downloads" ON storage.objects FOR SELECT USING (bucket_id = 'shared-files');
CREATE POLICY "Allow public deletes" ON storage.objects FOR DELETE USING (bucket_id = 'shared-files');

-- Function to clean up expired files and rooms
CREATE OR REPLACE FUNCTION cleanup_expired_files()
RETURNS void AS $$
DECLARE
    expired_room RECORD;
    file_info RECORD;
BEGIN
    -- Get all expired rooms
    FOR expired_room IN 
        SELECT room_code, files 
        FROM signaling 
        WHERE expires_at < NOW()
    LOOP
        -- Delete files from storage for each expired room
        IF expired_room.files IS NOT NULL AND jsonb_array_length(expired_room.files) > 0 THEN
            FOR file_info IN 
                SELECT value->>'path' as file_path
                FROM jsonb_array_elements(expired_room.files)
            LOOP
                -- Delete file from storage
                DELETE FROM storage.objects 
                WHERE bucket_id = 'shared-files' 
                AND name = file_info.file_path;
            END LOOP;
        END IF;
        
        -- Delete the room record
        DELETE FROM signaling WHERE room_code = expired_room.room_code;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to run cleanup every hour
-- (This requires the pg_cron extension to be enabled in your Supabase project)
-- You can also call this function manually or set up a webhook to trigger it

-- Optional: Create a trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_signaling_updated_at 
    BEFORE UPDATE ON signaling 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Enable realtime for the signaling table (for future enhancements)
DROP PUBLICATION IF EXISTS supabase_realtime;
CREATE PUBLICATION supabase_realtime FOR TABLE signaling;