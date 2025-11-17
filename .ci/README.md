# CI Configuration

This directory contains configuration files for Continuous Integration (CI) workflows.

## Files

### `.ci.env`

Environment variables for CI smoke tests. Contains **test-only values**, NOT production secrets.

**⚠️ Important:**
- This file is committed to the repository
- Contains only test/dummy values
- Never put real production secrets here

### `.ci.env.example`

Template file showing all required environment variables for CI tests.

## Usage

The `.ci.env` file is automatically loaded by CI workflows during smoke E2E tests. It provides all necessary environment variables for:

- Database connection
- Backend authentication
- AI service configuration
- Storage settings
- CORS configuration

## Security Note

All values in `.ci.env` are for **testing purposes only** and should never be used in production. They are safe to commit because:

1. They are clearly marked as test values
2. They use obvious dummy credentials
3. They are only used in isolated CI environments
4. They have no access to production systems

## Modifying Values

If you need to update test configuration:

1. Edit `.ci.env` with new test values
2. Update `.ci.env.example` to match
3. Commit both files
4. CI workflows will use the new values automatically

## Local Development

For local development, use `backend/.env` instead, which is gitignored and can contain your personal development configuration.
