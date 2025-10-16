# 🚀 Bank Assessment Indicators Update - Deployment Guide

## 📋 **Overview**

This guide covers the safe deployment of new bank assessment indicators while preserving all existing data.

### **What We're Doing:**
- ✅ Adding new bank assessment indicators (v2025)
- ✅ Preserving existing indicators (v2024) as inactive
- ✅ Maintaining all existing assessment data
- ✅ Using updated uniqueness constraint to allow same numbers with different versions

### **Current Data Status:**
- **38 bank assessments** exist
- **4,180 assessment results** exist
- **110 current indicators** exist
- **All data will be preserved**

## 🚀 **Deployment Steps**

### **Phase 1: Deploy Code**
```bash
# Deploy the new code
cap production deploy:code

# Verify deployment
cap production deploy:check
```

### **Phase 2: Run Database Migration**
```bash
# Run the migration to add version/active fields and update uniqueness constraint
cap production deploy:migrate

# Verify migration
cap production deploy:migrate:status
```

### **Phase 3: Update Bank Assessment Indicators**
```bash
# SSH into production server
cap production deploy:ssh

# Navigate to current release
cd /var/www/laws_and_pathways/current

# Create backup of current data
RAILS_ENV=production bundle exec rails bank_assessment_data:backup

# Preview changes (optional)
RAILS_ENV=production bundle exec rails bank_assessment_indicators:preview

# Run safe update
RAILS_ENV=production bundle exec rails bank_assessment_indicators:safe_update

# Verify the update
RAILS_ENV=production bundle exec rails bank_assessment_indicators:count
```

### **Phase 4: Verify Deployment**
```bash
# Check application health
cap production deploy:check

# Test admin interface
# Visit: https://your-domain.com/admin/bank_assessment_indicators

# Test bank assessment view
# Visit: https://your-domain.com/tpi/banks/[bank-slug]

# Check for orphaned results
RAILS_ENV=production bundle exec rails bank_assessment_indicators:count
```

## 🔒 **Rollback Process**

### **Quick Rollback (if needed):**
```bash
# SSH into production
cap production deploy:ssh
cd /var/www/laws_and_pathways/current

# Reset to original indicators
RAILS_ENV=production bundle exec rails bank_assessment_indicators:reset_to_original

# Verify rollback
RAILS_ENV=production bundle exec rails bank_assessment_indicators:count
```

### **Full Restore from Backup:**
```bash
# List available backups
RAILS_ENV=production bundle exec rails bank_assessment_data:list_backups

# Restore from backup
RAILS_ENV=production bundle exec rails bank_assessment_data:restore[TIMESTAMP]
```

## 📊 **What Happens After Safe Update**

### **Database State:**
- **Old indicators**: Marked as inactive (v2024, active: false)
- **New indicators**: Active (v2025, active: true)
- **Existing results**: All preserved and accessible
- **Numbering**: Same numbers can exist in both versions

### **Application Behavior:**
- **Admin interface**: Shows only active indicators by default
- **Public pages**: Display only current indicators
- **CSV exports**: Use only active indicators
- **All existing functionality**: Continues to work

## ✅ **Deployment Checklist**

- [ ] Code deployed to production
- [ ] Database migration run (version/active fields + uniqueness constraint)
- [ ] Backup created before update
- [ ] Safe update completed successfully
- [ ] Admin interface verified
- [ ] Public views tested
- [ ] No orphaned results found
- [ ] Rollback plan tested

## 🆘 **If Something Goes Wrong**

1. **Use quick rollback**: `rails bank_assessment_indicators:reset_to_original`
2. **Restore from backup**: Use the backup created before update
3. **Check logs**: Look for any error messages
4. **Verify data**: Use `rails bank_assessment_indicators:count`

## 📚 **Key Files**

- **Migration**: `db/migrate/20250825065000_add_version_to_bank_assessment_indicators.rb`
- **Rake Tasks**: `lib/tasks/update_bank_assessment_indicators.rake`
- **Backup Tasks**: `lib/tasks/backup_bank_assessment_data.rake`
- **New Indicators**: `db/seeds/tpi/bank_assessment_indicators_new.csv`

## 🎯 **Success Criteria**

- ✅ New indicators (v2025) are active and visible
- ✅ Old indicators (v2024) are inactive but preserved
- ✅ All existing assessment data remains accessible
- ✅ Admin interface shows only active indicators by default
- ✅ Public bank pages display only current indicators
- ✅ No data loss or orphaned results
- ✅ Easy rollback capability maintained
