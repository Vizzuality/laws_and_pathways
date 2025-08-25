# Bank Assessment Data Backup & Recovery System

This directory contains backup and recovery tools for bank assessment indicators and their responses.

## Overview

The system provides automated backup and recovery capabilities for:
- **Bank Assessment Indicators**: The questions, areas, and structure of bank assessments
- **Bank Assessment Results**: The actual answers and scores from bank assessments

## Available Rake Tasks

### Backup Operations

```bash
# Create a backup of current data
rails bank_assessment_data:backup

# List available backups
rails bank_assessment_data:list_backups

# Show backup directory information
rails bank_assessment_data:info
```

### Recovery Operations

```bash
# Restore data from a specific backup
rails bank_assessment_data:restore[TIMESTAMP]

# Example:
rails bank_assessment_data:restore[20250825_143022]
```

### Update Operations

```bash
# Preview new indicators structure without applying changes
rails bank_assessment_indicators:preview

# Update indicators with new structure (automatically creates backup first)
rails bank_assessment_indicators:update

# Show current indicators count
rails bank_assessment_indicators:count
```

## Workflow for Updating Indicators

### 1. Preview Changes (Recommended)
```bash
rails bank_assessment_indicators:preview
```
This shows you exactly what will change without making any modifications.

### 2. Create Manual Backup (Optional)
```bash
rails bank_assessment_data:backup
```
This creates a timestamped backup of your current data.

### 3. Update Indicators
```bash
rails bank_assessment_indicators:update
```
This automatically:
- Creates a backup of current data
- Clears existing indicators
- Imports new indicators from `db/seeds/tpi/bank_assessment_indicators_new.csv`

### 4. Verify Changes
```bash
rails bank_assessment_indicators:count
```
Check that the new structure is in place.

## Recovery Process

If you need to restore from a backup:

### 1. List Available Backups
```bash
rails bank_assessment_data:list_backups
```

### 2. Restore from Backup
```bash
rails bank_assessment_data:restore[TIMESTAMP]
```

**⚠️ Warning**: This will overwrite your current data. The system will ask for confirmation.

## Backup File Structure

Each backup creates three files:
- `bank_assessment_indicators_TIMESTAMP.csv` - All indicators with metadata
- `bank_assessment_results_TIMESTAMP.csv` - All assessment results
- `backup_metadata_TIMESTAMP.json` - Summary information about the backup

## Important Notes

- **Automatic Backup**: The `update` task automatically creates a backup before making changes
- **Data Preservation**: Assessment results are backed up but will be orphaned if indicators are removed
- **ID Preservation**: The system attempts to preserve original IDs during restoration
- **Validation**: All data is validated during restoration

## Troubleshooting

### Backup Directory Not Found
```bash
rails bank_assessment_data:info
```
This will show you the backup directory location and status.

### Restore Fails
- Check that the backup files exist
- Verify the timestamp format matches exactly
- Ensure you have sufficient permissions

### Data Inconsistencies
- Always verify data after restoration
- Check that all relationships are intact
- Run `rails bank_assessment_indicators:count` to verify counts

## File Locations

- **Backup Directory**: `db/backups/bank_assessment_data/`
- **New Indicators CSV**: `db/seeds/tpi/bank_assessment_indicators_new.csv`
- **Original Indicators CSV**: `db/seeds/tpi/bank_assessment_indicators.csv`

## Safety Features

- **Confirmation Required**: Restoration requires explicit confirmation
- **Automatic Backup**: Updates always create backups first
- **Metadata Tracking**: Each backup includes comprehensive metadata
- **Error Handling**: Failed operations are logged and reported
