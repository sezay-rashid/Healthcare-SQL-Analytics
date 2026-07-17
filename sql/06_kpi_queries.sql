/*
=========================================================
Project : Healthcare SQL Analytics
File    : 06_kpi_queries.sql
Author  : Sezay Rashid
Purpose : Contains healthcare KPI queries for management
          reporting and operational analysis.
=========================================================
*/

USE [Healthcare SQL Analytics];
GO

-- =====================================================
-- KPI 1: Overall Database Activity
--
-- Purpose:
-- Provides a high-level overview of record volumes
-- across the main healthcare database tables.
-- =====================================================

SELECT 'Departments' AS KPI, COUNT(*) AS Total
FROM Departments

UNION ALL

SELECT 'Consultants', COUNT(*)
FROM Consultants

UNION ALL

SELECT 'Patients', COUNT(*)
FROM Patients

UNION ALL

SELECT 'Appointments', COUNT(*)
FROM Appointments

UNION ALL

SELECT 'Referrals', COUNT(*)
FROM Referrals

UNION ALL

SELECT 'Waiting List', COUNT(*)
FROM WaitingList

UNION ALL

SELECT 'Appointment Outcomes', COUNT(*)
FROM AppointmentOutcomes;
GO


-- =====================================================
-- KPI 2: Appointments by Department
--
-- Purpose:
-- Shows the total number of appointments handled by
-- each department, ordered from highest to lowest.
-- =====================================================

SELECT
    DepartmentName,
    COUNT(*) AS TotalAppointments
FROM vw_AppointmentSummary
GROUP BY DepartmentName
ORDER BY TotalAppointments DESC;
GO

-- =====================================================
-- KPI 3: Appointments by Consultant
--
-- Purpose:
-- Displays the total number of appointments managed
-- by each consultant together with their department.
-- =====================================================

SELECT

    ConsultantName,

    DepartmentName,

    COUNT(*) AS TotalAppointments

FROM vw_AppointmentSummary

GROUP BY

    ConsultantName,
    DepartmentName

ORDER BY

    TotalAppointments DESC,
    ConsultantName;
GO

-- =====================================================
-- KPI 4: Appointment Status Breakdown
--
-- Purpose:
-- Shows the number and percentage of appointments
-- by status, including completed, scheduled,
-- cancelled and DNA appointments.
-- =====================================================

SELECT
    AppointmentStatus,
    COUNT(*) AS TotalAppointments,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS PercentageOfAppointments
FROM Appointments
GROUP BY AppointmentStatus
ORDER BY TotalAppointments DESC;
GO

-- =====================================================
-- KPI 5: Top 5 Busiest Consultants
--
-- Purpose:
-- Identifies the five consultants with the highest
-- appointment workload and displays their patient,
-- completion and DNA activity.
-- =====================================================

SELECT TOP (5)
    ConsultantName,
    DepartmentName,
    TotalAppointments,
    UniquePatients,
    CompletedAppointments,
    DNACount
FROM vw_ConsultantWorkload
ORDER BY
    TotalAppointments DESC,
    CompletedAppointments DESC,
    ConsultantName;
GO

-- =====================================================
-- KPI 6: Patients by Gender
--
-- Purpose:
-- Displays the number and percentage of registered
-- patients by gender.
-- =====================================================

SELECT
    Gender,
    COUNT(*) AS TotalPatients,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM Patients
GROUP BY Gender
ORDER BY TotalPatients DESC;
GO

USE [Healthcare SQL Analytics];
GO

SELECT
    CAST(
        AVG(
            DATEDIFF(DAY, DateOfBirth, '2026-08-01') / 365.25
        )
        AS DECIMAL(5,2)
    ) AS AveragePatientAge
FROM Patients;
GO


-- =====================================================
-- KPI 8: Appointment Type Distribution
--
-- Purpose:
-- Displays the number and percentage of appointments
-- by appointment type, helping to understand the
-- demand for different clinic services.
-- =====================================================

SELECT
    AppointmentType,
    COUNT(*) AS TotalAppointments,
    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5,2)
    ) AS Percentage
FROM Appointments
GROUP BY AppointmentType
ORDER BY TotalAppointments DESC;
GO

-- =====================================================
-- KPI 9: Department Performance Summary
--
-- Purpose:
-- Summarises appointment activity, completed visits,
-- DNA volumes and completion rates by department.
-- =====================================================

SELECT
    DepartmentName,
    COUNT(*) AS TotalAppointments,

    SUM(
        CASE
            WHEN AppointmentStatus = 'Completed' THEN 1
            ELSE 0
        END
    ) AS CompletedAppointments,

    SUM(
        CASE
            WHEN AppointmentStatus = 'DNA' THEN 1
            ELSE 0
        END
    ) AS DNAs,

    CAST(
        SUM(
            CASE
                WHEN AppointmentStatus = 'Completed' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS CompletionRatePercentage

FROM vw_AppointmentSummary

GROUP BY DepartmentName

ORDER BY TotalAppointments DESC;
GO

-- =====================================================
-- KPI 10: Monthly Appointment Trends
--
-- Purpose:
-- Shows the number of appointments recorded each month,
-- allowing changes in service demand to be monitored
-- across the reporting period.
-- =====================================================

SELECT
    YEAR(AppointmentDate) AS AppointmentYear,
    MONTH(AppointmentDate) AS AppointmentMonth,
    DATENAME(MONTH, AppointmentDate) AS MonthName,
    COUNT(*) AS TotalAppointments
FROM Appointments
GROUP BY
    YEAR(AppointmentDate),
    MONTH(AppointmentDate),
    DATENAME(MONTH, AppointmentDate)
ORDER BY
    AppointmentYear,
    AppointmentMonth;
GO