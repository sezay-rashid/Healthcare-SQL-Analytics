/*
===============================================================================
File: 04_views.sql
Project: HealthSQL Insights
Database: Healthcare SQL Analytics

Purpose:
Creates reusable SQL views that combine and summarise healthcare data for
analysis, reporting, stored procedures and Power BI dashboards.

Views included:
1. vw_AppointmentSummary
2. vw_ConsultantWorkload
3. vw_PatientJourney
4. vw_WaitingListSummary
5. vw_MonthlyAppointmentTrend
===============================================================================
*/

USE [Healthcare SQL Analytics];
GO


/*
===============================================================================
View 1: vw_AppointmentSummary

Purpose:
Combines appointment, patient, consultant and department information into
one reporting dataset.

This view supports:
- Appointment activity analysis
- Department comparisons
- Consultant reporting
- Appointment status analysis
- Power BI visualisations
===============================================================================
*/

CREATE OR ALTER VIEW dbo.vw_AppointmentSummary
AS

SELECT
    a.AppointmentID,
    a.PatientID,

    CONCAT
    (
        p.FirstName,
        ' ',
        p.LastName
    ) AS PatientName,

    a.ConsultantID,

    CONCAT
    (
        c.FirstName,
        ' ',
        c.LastName
    ) AS ConsultantName,

    c.Specialty,
    d.DepartmentID,
    d.DepartmentName,

    a.AppointmentDate,
    a.AppointmentTime,
    a.AppointmentType,
    a.AppointmentStatus,
    a.RoomNumber

FROM dbo.Appointments AS a

INNER JOIN dbo.Patients AS p
    ON a.PatientID = p.PatientID

INNER JOIN dbo.Consultants AS c
    ON a.ConsultantID = c.ConsultantID

INNER JOIN dbo.Departments AS d
    ON c.DepartmentID = d.DepartmentID;
GO


/*
===============================================================================
View 2: vw_ConsultantWorkload

Purpose:
Summarises appointment workload for each consultant.

The view calculates:
- Total appointments
- Completed appointments
- Cancelled appointments
- No-show appointments

This supports consultant workload monitoring, workforce planning and
departmental capacity analysis.
===============================================================================
*/

CREATE OR ALTER VIEW dbo.vw_ConsultantWorkload
AS

SELECT
    c.ConsultantID,

    CONCAT
    (
        c.FirstName,
        ' ',
        c.LastName
    ) AS ConsultantName,

    d.DepartmentName,
    c.Specialty,

    COUNT(a.AppointmentID) AS TotalAppointments,

    SUM
    (
        CASE
            WHEN a.AppointmentStatus = 'Completed'
                THEN 1
            ELSE 0
        END
    ) AS CompletedAppointments,

    SUM
    (
        CASE
            WHEN a.AppointmentStatus = 'Cancelled'
                THEN 1
            ELSE 0
        END
    ) AS CancelledAppointments,

    SUM
    (
        CASE
            WHEN a.AppointmentStatus IN
                 (
                     'No Show',
                     'Did Not Attend',
                     'DNA'
                 )
                THEN 1
            ELSE 0
        END
    ) AS NoShowAppointments

FROM dbo.Consultants AS c

INNER JOIN dbo.Departments AS d
    ON c.DepartmentID = d.DepartmentID

LEFT JOIN dbo.Appointments AS a
    ON c.ConsultantID = a.ConsultantID

GROUP BY
    c.ConsultantID,
    c.FirstName,
    c.LastName,
    d.DepartmentName,
    c.Specialty;
GO


/*
===============================================================================
View 3: vw_PatientJourney

Purpose:
Combines referral, waiting-list, appointment and outcome information to show
the patient's journey through the healthcare service.

This view supports:
- Referral tracking
- Waiting-list monitoring
- Appointment analysis
- Clinical outcome reporting
- Follow-up analysis

LEFT JOINs are used because some patients may not yet have progressed through
every stage of the pathway.
===============================================================================
*/

CREATE OR ALTER VIEW dbo.vw_PatientJourney
AS

SELECT
    p.PatientID,

    CONCAT
    (
        p.FirstName,
        ' ',
        p.LastName
    ) AS PatientName,

    p.NHSNumber,
    p.DateOfBirth,
    p.Gender,

    r.ReferralID,
    r.ReferralDate,
    r.ReferralSource,
    r.ReferralReason,
    r.Priority AS ReferralPriority,
    r.ReferralStatus,

    d.DepartmentID,
    d.DepartmentName,

    wl.WaitingListID,
    wl.DateAdded,
    wl.PriorityLevel,
    wl.EstimatedWaitWeeks,
    wl.TargetTreatmentDate,
    wl.WaitingStatus,

    a.AppointmentID,
    a.AppointmentDate,
    a.AppointmentTime,
    a.AppointmentType,
    a.AppointmentStatus,

    CONCAT
    (
        c.FirstName,
        ' ',
        c.LastName
    ) AS ConsultantName,

    ao.OutcomeID,
    ao.OutcomeStatus,
    ao.Diagnosis,
    ao.TreatmentProvided,
    ao.FollowUpRequired,
    ao.FollowUpDate

FROM dbo.Patients AS p

LEFT JOIN dbo.Referrals AS r
    ON p.PatientID = r.PatientID

LEFT JOIN dbo.Departments AS d
    ON r.DepartmentID = d.DepartmentID

LEFT JOIN dbo.WaitingList AS wl
    ON r.ReferralID = wl.ReferralID

LEFT JOIN dbo.Appointments AS a
    ON p.PatientID = a.PatientID

LEFT JOIN dbo.Consultants AS c
    ON a.ConsultantID = c.ConsultantID

LEFT JOIN dbo.AppointmentOutcomes AS ao
    ON a.AppointmentID = ao.AppointmentID;
GO


/*
===============================================================================
View 4: vw_WaitingListSummary

Purpose:
Provides a detailed waiting-list reporting dataset containing patient,
department, priority and target-treatment information.

The view also calculates:
- Days currently on the waiting list
- Whether the target treatment date is overdue, due soon or within target

This supports waiting-list monitoring and Power BI reporting.
===============================================================================
*/

CREATE OR ALTER VIEW dbo.vw_WaitingListSummary
AS

SELECT
    wl.WaitingListID,
    wl.PatientID,

    CONCAT
    (
        p.FirstName,
        ' ',
        p.LastName
    ) AS PatientName,

    wl.ReferralID,
    wl.DepartmentID,
    d.DepartmentName,

    wl.DateAdded,
    wl.PriorityLevel,
    wl.EstimatedWaitWeeks,
    wl.TargetTreatmentDate,
    wl.WaitingStatus,

    DATEDIFF
    (
        DAY,
        wl.DateAdded,
        CAST(GETDATE() AS DATE)
    ) AS DaysOnWaitingList,

    CASE
        WHEN wl.WaitingStatus IN
             (
                 'Completed',
                 'Removed',
                 'Treated'
             )
            THEN 'Closed'

        WHEN wl.TargetTreatmentDate < CAST(GETDATE() AS DATE)
            THEN 'Overdue'

        WHEN wl.TargetTreatmentDate <=
             DATEADD
             (
                 DAY,
                 14,
                 CAST(GETDATE() AS DATE)
             )
            THEN 'Due Within 14 Days'

        ELSE 'Within Target'
    END AS TargetDateStatus,

    wl.Notes

FROM dbo.WaitingList AS wl

INNER JOIN dbo.Patients AS p
    ON wl.PatientID = p.PatientID

INNER JOIN dbo.Departments AS d
    ON wl.DepartmentID = d.DepartmentID;
GO


/*
===============================================================================
View 5: vw_MonthlyAppointmentTrend

Purpose:
Provides a monthly summary of appointment activity for reporting and
Power BI dashboards.

The view groups appointments by year and month, making it easy to:
- Analyse appointment trends over time
- Identify seasonal patterns
- Monitor healthcare service demand

Months containing fewer than 50 appointments are excluded because these may
represent incomplete reporting periods and could distort trend analysis.

Used in:
- Power BI Monthly Appointment Trend chart
- Executive Dashboard
===============================================================================
*/

CREATE OR ALTER VIEW dbo.vw_MonthlyAppointmentTrend
AS

SELECT
    YEAR(a.AppointmentDate) AS AppointmentYear,
    MONTH(a.AppointmentDate) AS AppointmentMonth,
    DATENAME
    (
        MONTH,
        a.AppointmentDate
    ) AS MonthName,

    DATEFROMPARTS
    (
        YEAR(a.AppointmentDate),
        MONTH(a.AppointmentDate),
        1
    ) AS MonthStartDate,

    COUNT(a.AppointmentID) AS TotalAppointments

FROM dbo.Appointments AS a

GROUP BY
    YEAR(a.AppointmentDate),
    MONTH(a.AppointmentDate),
    DATENAME
    (
        MONTH,
        a.AppointmentDate
    )

HAVING COUNT(a.AppointmentID) >= 50;
GO


/*
===============================================================================
View Validation Tests

Purpose:
Confirms that all reporting views execute successfully and return data.

These SELECT statements do not create additional database objects.
===============================================================================
*/

SELECT TOP (20) *
FROM dbo.vw_AppointmentSummary
ORDER BY AppointmentDate, AppointmentTime;
GO

SELECT *
FROM dbo.vw_ConsultantWorkload
ORDER BY TotalAppointments DESC, ConsultantName;
GO

SELECT TOP (20) *
FROM dbo.vw_PatientJourney
ORDER BY PatientID, ReferralDate, AppointmentDate;
GO

SELECT TOP (20) *
FROM dbo.vw_WaitingListSummary
ORDER BY DaysOnWaitingList DESC;
GO

SELECT *
FROM dbo.vw_MonthlyAppointmentTrend
ORDER BY MonthStartDate;
GO