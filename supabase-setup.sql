-- Supabase Database Setup Script
-- Run this in your Supabase SQL Editor

-- Create users table
CREATE TABLE IF NOT EXISTS users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  signup_ip VARCHAR(45),
  signup_country VARCHAR(100),
  signup_city VARCHAR(100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create sign_in_attempts table
CREATE TABLE IF NOT EXISTS sign_in_attempts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  ip_address VARCHAR(45),
  country VARCHAR(100),
  city VARCHAR(100),
  user_agent TEXT,
  success BOOLEAN NOT NULL,
  failure_reason VARCHAR(255),
  attempted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_sign_in_attempts_user_id ON sign_in_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_sign_in_attempts_attempted_at ON sign_in_attempts(attempted_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sign_in_attempts ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
-- Users can read their own data
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Allow insert for signup (handled by backend)
CREATE POLICY "Allow user creation"
  ON users FOR INSERT
  WITH CHECK (true);

-- Create policies for sign_in_attempts table
-- Users can view their own sign-in attempts
CREATE POLICY "Users can view own sign-in attempts"
  ON sign_in_attempts FOR SELECT
  USING (auth.uid() = user_id);

-- Allow insert for sign-in tracking (handled by backend)
CREATE POLICY "Allow sign-in attempt logging"
  ON sign_in_attempts FOR INSERT
  WITH CHECK (true);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update updated_at
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create password_reset_tokens table
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  token VARCHAR(255) UNIQUE NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  used BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for password reset tokens
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token ON password_reset_tokens(token);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_email ON password_reset_tokens(email);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_expires_at ON password_reset_tokens(expires_at);

-- Enable Row Level Security for password_reset_tokens
ALTER TABLE password_reset_tokens ENABLE ROW LEVEL SECURITY;

-- Allow anyone to create password reset tokens (handled by backend)
CREATE POLICY "Allow password reset token creation"
  ON password_reset_tokens FOR INSERT
  WITH CHECK (true);

-- Allow reading tokens for verification (handled by backend)
CREATE POLICY "Allow password reset token verification"
  ON password_reset_tokens FOR SELECT
  USING (true);

-- Allow updating tokens when used
CREATE POLICY "Allow password reset token update"
  ON password_reset_tokens FOR UPDATE
  USING (true);
