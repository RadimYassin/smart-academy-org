-- ============================================================================
-- Flyway Migration History Cleanup Script
-- ============================================================================
-- Purpose: Remove the orphaned V2 migration record from Flyway schema history
-- Database: course_db
-- Issue: Migration V2__Add_Quiz_Attempts.sql was renamed to V3, causing
--        Flyway validation to fail
-- ============================================================================

-- Step 1: View current migration history
SELECT 
    installed_rank,
    version,
    description,
    type,
    script,
    checksum,
    installed_on,
    success
FROM flyway_schema_history
ORDER BY installed_rank;

-- Step 2: Delete the orphaned V2 migration record
-- Uncomment the line below to execute the delete
-- DELETE FROM flyway_schema_history WHERE version = '2';

-- Step 3: Verify the deletion
-- SELECT * FROM flyway_schema_history ORDER BY installed_rank;

-- ============================================================================
-- Expected Result After Cleanup:
-- ============================================================================
-- installed_rank | version | description  | script
-- ---------------+---------+--------------+-------------------------
-- 1              | 1       | Init Schema  | V1__Init_Schema.sql
-- 2              | 3       | Add Quiz...  | V3__Add_Quiz_Attempts.sql
-- ============================================================================

-- Note: After running this script:
-- 1. Re-enable validation in application.properties:
--    spring.flyway.validate-on-migrate=true
-- 2. Restart the Course Management service
-- ============================================================================
