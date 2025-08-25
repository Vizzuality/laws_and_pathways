# 🚀 Bank Assessment Indicators Update - Deployment Guide

## 📋 **Pre-Deployment Checklist**

### **1. Code Changes to Deploy**
- ✅ New CSV file: `db/seeds/tpi/bank_assessment_indicators_new.csv`
- ✅ Backup & recovery rake tasks
- ✅ Updated bank assessment indicators structure
- ✅ CP Matrix 2030 alignment columns (from previous work)

### **2. Database Changes**
- ✅ CP assessment 2030 alignment columns (already migrated)
- ✅ CP matrix 2030 alignment column (already migrated)
- 🔄 Bank assessment indicators will be updated via rake task

### **3. Files to Include in Deployment**
```
app/
├── lib/tasks/
│   ├── backup_bank_assessment_data.rake
│   └── update_bank_assessment_indicators.rake
├── models/
│   ├── cp/assessment.rb (schema updated)
│   ├── cp/matrix.rb (schema updated)
│   └── bank.rb (delegations updated)
├── admin/
│   ├── cp_assessments.rb (admin interface updated)
│   └── banks.rb (admin interface updated)
├── views/admin/cp_assessments/
│   └── _form.html.erb (form updated)
└── services/
    ├── csv_import/bank_cp_assessments2030.rb (new)
    └── csv_export/user/bank_cp_assessments.rb (updated)

db/
├── seeds/tpi/
│   └── bank_assessment_indicators_new.csv (new)
└── backups/ (will be created during deployment)

spec/
├── factories/
│   ├── cp_assessment.rb (updated)
│   └── cp_matrices.rb (updated)
```

## 🚀 **Capistrano Deployment Steps**

### **Phase 1: Deploy Code (Zero Downtime)**
```bash
# Deploy the new code without running migrations
cap production deploy:code

# Verify code is deployed
cap production deploy:check
```

### **Phase 2: Run Database Migrations**
```bash
# Run any pending migrations
cap production deploy:migrate

# Verify migrations
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

# Preview changes (optional but recommended)
RAILS_ENV=production bundle exec rails bank_assessment_indicators:preview

# Update indicators with new structure
RAILS_ENV=production bundle exec rails bank_assessment_indicators:update

# Verify the update
RAILS_ENV=production bundle exec rails bank_assessment_indicators:count
```

### **Phase 4: Verify Deployment**
```bash
# Check application health
cap production deploy:check

# Verify admin interface loads
# Visit: https://your-domain.com/admin/bank_assessment_indicators

# Test a bank assessment view
# Visit: https://your-domain.com/tpi/banks/[bank-slug]
```

## 🔧 **Additional Changes to Consider**

### **1. Update Test Data**
The new indicators will need updated test data. Consider:
- Updating `spec/factories/bank_assessment_indicators.rb`
- Updating test fixtures
- Updating integration tests

### **2. Update CSV Import/Export Services**
If you have existing bank assessment data, you might need to:
- Update CSV templates for data import
- Update export formats
- Handle data migration for existing assessments

### **3. Update Documentation**
- Update admin user guides
- Update API documentation if applicable
- Update user-facing documentation

## 🚨 **Rollback Plan**

### **If Something Goes Wrong:**
```bash
# SSH into production
cap production deploy:ssh
cd /var/www/laws_and_pathways/current

# List available backups
RAILS_ENV=production bundle exec rails bank_assessment_data:list_backups

# Restore from backup
RAILS_ENV=production bundle exec rails bank_assessment_data:restore[TIMESTAMP]

# Verify restoration
RAILS_ENV=production bundle exec rails bank_assessment_indicators:count
```

### **If Code Rollback is Needed:**
```bash
# Rollback to previous release
cap production deploy:rollback

# SSH and restore indicators
cap production deploy:ssh
cd /var/www/laws_and_pathways/current
RAILS_ENV=production bundle exec rails bank_assessment_data:restore[TIMESTAMP]
```

## 📊 **Monitoring & Verification**

### **Post-Deployment Checks:**
1. **Admin Interface**: Verify new indicators appear correctly
2. **Bank Views**: Check that bank assessment pages load
3. **Data Integrity**: Verify no orphaned assessment results
4. **Performance**: Monitor for any performance impacts
5. **Error Logs**: Check application logs for errors

### **Key URLs to Test:**
- `/admin/bank_assessment_indicators` - Admin interface
- `/admin/banks/[id]` - Bank admin page
- `/tpi/banks/[slug]` - Public bank page
- `/tpi/banks/[slug]/assessments` - Bank assessments

## 🔒 **Security Considerations**

- **Backup Access**: Ensure backup files are not publicly accessible
- **Admin Permissions**: Verify admin users can manage new indicators
- **Data Validation**: Ensure new indicators follow validation rules
- **Audit Trail**: Consider logging indicator changes

## 📝 **Deployment Checklist**

- [ ] Code deployed to production
- [ ] Database migrations run
- [ ] Backup created before update
- [ ] Indicators updated successfully
- [ ] Admin interface verified
- [ ] Public views tested
- [ ] Performance monitored
- [ ] Error logs checked
- [ ] Rollback plan tested
- [ ] Documentation updated

## 🆘 **Emergency Contacts**

- **Database Admin**: [Contact Info]
- **DevOps Team**: [Contact Info]
- **Application Support**: [Contact Info]

## 📚 **Additional Resources**

- [Backup & Recovery README](db/backups/README.md)
- [Bank Assessment Indicators Admin](app/admin/bank_assessment_indicators.rb)
- [Update Rake Tasks](lib/tasks/update_bank_assessment_indicators.rake)
- [Backup Rake Tasks](lib/tasks/backup_bank_assessment_data.rake)
