# SQL Database Administration Scripts

This repository contains SQL scripts used for managing and administering database servers. These scripts cover a wide range of tasks essential for maintaining database performance, security, and organization. Below is an overview of the key features:

- **Auditing Tables, Databases, and Servers**:
    - Scripts designed to monitor and log changes, ensuring data integrity and helping with compliance by tracking modifications and access patterns.
        - *spGenerateAuditTrgsTblsNew.sql - This stored procedure creates table triggers for INSERT, DELETE, and UPDATE operations. It first checks if any audit triggers already exist. If none are found, the procedure generates and creates the necessary triggers.*
- **Database Maintenance**:
    - Includes scripts for tasks like backup, restoration, indexing, and optimizing the performance of databases.
- **Security Management**:
    - SQL scripts that help manage user permissions, roles, and access controls to enhance database security.
- **Performance Monitoring**:
    - Scripts for querying server health, monitoring system resource usage, and diagnosing performance bottlenecks.
- **Error and Log Analysis**:
    - Tools for reviewing logs and identifying potential errors or warnings from database servers.

