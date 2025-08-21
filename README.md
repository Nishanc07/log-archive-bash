## Resource Usage Alert Script for Azure VM
a simple monitoring script using bash to track CPU, Memory, and Disk usage on an Azure VM (with PostgreSQL/MySQL running). If usage exceeds a defined threshold (default: 80%), the script triggers an alert via Email 

All resource checks are logged in resource_usage.log.
### Features
- Monitors:
  - CPU usage (%)
  - Memory usage (%)
  - Disk usage (%)
- Sends alerts when thresholds are exceeded via an Email alert
- Logs all checks into resource_usage.log

- Runs automatically every 5 minutes via cron
