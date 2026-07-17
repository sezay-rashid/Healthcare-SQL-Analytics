/*
===============================================================================
Waiting List Analysis 1: Average Waiting Time by Department

Purpose:
Calculates the average, shortest, and longest waiting time between the
referral date and appointment date for each department.

The department is identified through the consultant assigned to the
appointment.
===============================================================================
*/

SELECT
    d.DepartmentName,
    COUNT(*) AS TotalReferralAppointmentMatches,

    CAST(
        AVG(
            CAST(
                DATEDIFF(DAY, r.ReferralDate, a.AppointmentDate)
                AS DECIMAL(10, 2)
            )
        )
        AS DECIMAL(10, 2)
    ) AS AverageWaitingDays,

    MIN(
        DATEDIFF(DAY, r.ReferralDate, a.AppointmentDate)
    ) AS MinimumWaitingDays,

    MAX(
        DATEDIFF(DAY, r.ReferralDate, a.AppointmentDate)
    ) AS MaximumWaitingDays

FROM Referrals AS r

INNER JOIN Appointments AS a
    ON r.PatientID = a.PatientID

INNER JOIN Consultants AS c
    ON a.ConsultantID = c.ConsultantID

INNER JOIN Departments AS d
    ON c.DepartmentID = d.DepartmentID

WHERE a.AppointmentDate >= r.ReferralDate

GROUP BY
    d.DepartmentName

ORDER BY
    AverageWaitingDays DESC;
GO

/*
===============================================================================
Waiting List Analysis 2: Waiting-Time Distribution

Purpose:
Groups referrals into waiting-time bands based on the number of days between
the referral date and the patient's first subsequent appointment.

This shows how many patients were seen quickly and how many experienced
longer delays.
===============================================================================
*/

WITH ReferralWaitingTimes AS
(
    SELECT
        r.ReferralID,
        r.PatientID,
        r.ReferralDate,
        next_appointment.AppointmentDate,
        DATEDIFF(
            DAY,
            r.ReferralDate,
            next_appointment.AppointmentDate
        ) AS WaitingDays
    FROM Referrals AS r

    CROSS APPLY
    (
        SELECT TOP (1)
            a.AppointmentDate
        FROM Appointments AS a
        WHERE a.PatientID = r.PatientID
          AND a.AppointmentDate >= r.ReferralDate
        ORDER BY
            a.AppointmentDate
    ) AS next_appointment
)

SELECT
    CASE
        WHEN WaitingDays <= 14 THEN '0–14 Days'
        WHEN WaitingDays <= 28 THEN '15–28 Days'
        WHEN WaitingDays <= 56 THEN '29–56 Days'
        WHEN WaitingDays <= 126 THEN '57–126 Days'
        ELSE 'Over 126 Days'
    END AS WaitingTimeBand,

    COUNT(*) AS TotalReferrals,

    CAST(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER ()
        AS DECIMAL(5, 2)
    ) AS PercentageOfReferrals

FROM ReferralWaitingTimes

GROUP BY
    CASE
        WHEN WaitingDays <= 14 THEN '0–14 Days'
        WHEN WaitingDays <= 28 THEN '15–28 Days'
        WHEN WaitingDays <= 56 THEN '29–56 Days'
        WHEN WaitingDays <= 126 THEN '57–126 Days'
        ELSE 'Over 126 Days'
    END

ORDER BY
    MIN(WaitingDays);
GO

/*
===============================================================================
Waiting List Analysis 3: Referral Waiting-Time Status

Purpose:
Analyses the waiting time between each referral and the patient's first
subsequent appointment.

The query classifies each referral as either:
- Within the 18-week target
- Target breached

This provides a complete waiting-time report even when no referrals exceed
the 126-day threshold.
===============================================================================
*/

WITH ReferralWaitingTimes AS
(
    SELECT
        r.ReferralID,
        r.PatientID,
        r.ReferralDate,
        next_appointment.AppointmentDate,
        next_appointment.ConsultantID,

        DATEDIFF
        (
            DAY,
            r.ReferralDate,
            next_appointment.AppointmentDate
        ) AS WaitingDays

    FROM Referrals AS r

    CROSS APPLY
    (
        SELECT TOP (1)
            a.AppointmentDate,
            a.ConsultantID

        FROM Appointments AS a

        WHERE a.PatientID = r.PatientID
          AND a.AppointmentDate >= r.ReferralDate

        ORDER BY
            a.AppointmentDate
    ) AS next_appointment
)

SELECT
    rwt.ReferralID,
    rwt.PatientID,
    rwt.ReferralDate,
    rwt.AppointmentDate,
    d.DepartmentName,
    rwt.WaitingDays,

    CASE
        WHEN rwt.WaitingDays > 126
            THEN 'Target Breached'
        ELSE 'Within Target'
    END AS WaitingStatus,

    CASE
        WHEN rwt.WaitingDays > 126
            THEN rwt.WaitingDays - 126
        ELSE 0
    END AS DaysOverTarget

FROM ReferralWaitingTimes AS rwt

INNER JOIN Consultants AS c
    ON rwt.ConsultantID = c.ConsultantID

INNER JOIN Departments AS d
    ON c.DepartmentID = d.DepartmentID

ORDER BY
    rwt.WaitingDays DESC,
    rwt.ReferralDate;
GO

/*
===============================================================================
Waiting List Analysis 5: Monthly Scheduled Appointment Load

Purpose:
Summarises the number of scheduled appointments by month and department.

This helps identify periods of higher future demand and departments with
greater scheduled workload, supporting capacity and workforce planning.
===============================================================================
*/

SELECT
    YEAR(a.AppointmentDate) AS AppointmentYear,
    MONTH(a.AppointmentDate) AS AppointmentMonth,
    DATENAME(MONTH, a.AppointmentDate) AS MonthName,
    d.DepartmentName,
    COUNT(a.AppointmentID) AS TotalScheduledAppointments

FROM Appointments AS a

INNER JOIN Consultants AS c
    ON a.ConsultantID = c.ConsultantID

INNER JOIN Departments AS d
    ON c.DepartmentID = d.DepartmentID

GROUP BY
    YEAR(a.AppointmentDate),
    MONTH(a.AppointmentDate),
    DATENAME(MONTH, a.AppointmentDate),
    d.DepartmentName

ORDER BY
    AppointmentYear,
    AppointmentMonth,
    TotalScheduledAppointments DESC;
GO

/*
===============================================================================
Waiting List Analysis 6: Department Appointment Demand Ranking

Purpose:
Calculates the total number of scheduled appointments for each department
and ranks departments from highest to lowest demand.

This helps identify which departments carry the greatest appointment workload
and may require additional staffing or clinical capacity.
===============================================================================
*/

WITH DepartmentAppointmentTotals AS
(
    SELECT
        d.DepartmentName,
        COUNT(a.AppointmentID) AS TotalScheduledAppointments

    FROM Appointments AS a

    INNER JOIN Consultants AS c
        ON a.ConsultantID = c.ConsultantID

    INNER JOIN Departments AS d
        ON c.DepartmentID = d.DepartmentID

    GROUP BY
        d.DepartmentName
)

SELECT
    DENSE_RANK() OVER
    (
        ORDER BY TotalScheduledAppointments DESC
    ) AS DemandRank,

    DepartmentName,
    TotalScheduledAppointments,

    CAST
    (
        TotalScheduledAppointments * 100.0
        / SUM(TotalScheduledAppointments) OVER ()
        AS DECIMAL(5, 2)
    ) AS PercentageOfTotalAppointments

FROM DepartmentAppointmentTotals

ORDER BY
    DemandRank,
    DepartmentName;
GO