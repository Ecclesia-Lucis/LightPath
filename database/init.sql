-- LightPath Database Initialization Script
-- This script sets up the basic database structure for development

-- Enable pgvector extension for semantic memory (vector database)
-- Note: Requires postgres image with pgvector (e.g., ankane/pgvector)
-- For now, we'll add this later when needed
-- CREATE EXTENSION IF NOT EXISTS vector;

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create database user if not exists (for production)
-- This is handled by docker-compose for development

-- Set timezone
SET timezone = 'UTC';

-- Create initial schema version tracking table
CREATE TABLE IF NOT EXISTS schema_versions (
    version INTEGER PRIMARY KEY,
    description TEXT NOT NULL,
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Insert initial version
INSERT INTO schema_versions (version, description) VALUES (1, 'Initial database setup');

-- Note: Full schema will be created by migration scripts
-- This init script only sets up extensions and basic configuration
