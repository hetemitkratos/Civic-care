-- Civic Reporter Database Setup for Supabase

-- Create reports table
CREATE TABLE IF NOT EXISTS reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('pothole', 'streetLight', 'garbage', 'graffiti', 'brokenSidewalk', 'other')),
  importance TEXT NOT NULL DEFAULT 'medium' CHECK (importance IN ('low', 'medium', 'high', 'critical')),
  status TEXT NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted', 'inProgress', 'resolved', 'rejected')),
  location JSONB NOT NULL,
  image_urls TEXT[] DEFAULT '{}',
  upvotes INTEGER DEFAULT 0,
  upvoted_by TEXT[] DEFAULT '{}',
  admin_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_category ON reports(category);
CREATE INDEX IF NOT EXISTS idx_reports_importance ON reports(importance);
CREATE INDEX IF NOT EXISTS idx_reports_upvotes ON reports(upvotes DESC);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

-- Create policies for reports table
-- Users can view all reports
CREATE POLICY "Anyone can view reports" ON reports
  FOR SELECT USING (true);

-- Users can insert their own reports
CREATE POLICY "Users can insert their own reports" ON reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own reports
CREATE POLICY "Users can update their own reports" ON reports
  FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own reports
CREATE POLICY "Users can delete their own reports" ON reports
  FOR DELETE USING (auth.uid() = user_id);

-- Create a function to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_reports_updated_at
  BEFORE UPDATE ON reports
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create storage bucket for images
-- Note: This needs to be run in the Supabase dashboard Storage section or via the dashboard
-- 1. Go to Storage in your Supabase dashboard
-- 2. Create a new bucket called 'images'
-- 3. Make it public
-- 4. Then run the policies below in the SQL editor

-- Create storage policies for images bucket
-- Run these in the Supabase SQL editor after creating the bucket

-- Enable RLS on storage.objects (if not already enabled)
-- ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Policy to allow anyone to view images (since bucket is public)
-- CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'images');

-- Policy to allow authenticated users to upload images
-- CREATE POLICY "Authenticated users can upload images" ON storage.objects 
--   FOR INSERT WITH CHECK (bucket_id = 'images' AND auth.role() = 'authenticated');

-- Policy to allow users to update their own images
-- CREATE POLICY "Users can update own images" ON storage.objects 
--   FOR UPDATE USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Policy to allow users to delete their own images  
-- CREATE POLICY "Users can delete own images" ON storage.objects 
--   FOR DELETE USING (bucket_id = 'images' AND auth.uid()::text = (storage.foldername(name))[1]);

-- Alternative simpler policies (use these if the above don't work):
-- CREATE POLICY "Allow authenticated uploads" ON storage.objects 
--   FOR INSERT WITH CHECK (bucket_id = 'images');

-- CREATE POLICY "Allow public access" ON storage.objects 
--   FOR SELECT USING (bucket_id = 'images');