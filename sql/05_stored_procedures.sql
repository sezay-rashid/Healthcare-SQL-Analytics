/*
=========================================================
Project : Healthcare SQL Analytics
File    : 05_stored_procedures.sql
Author  : Sezay Rashid
Purpose : Creates reusable stored procedures for
          healthcare reporting and analysis.
=========================================================
*/

USE [Healthcare SQL Analytics];
GO

-- =====================================================
-- Stored Procedure: Get Appointments by Department
--
-- Purpose:
-- Returns all appointments for a selected department,
-- including patient, consultant and clinical outcome.
--
-- Example:
-- EXEC usp_GetAppointmentsByDepartment 'Dermatology';
-- =====================================================

CREATE OR ALTER PROCEDURE usp_GetAppointmentsByDepartment
    @DepartmentName VARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        AppointmentID,
        PatientID,
        PatientName,
        DepartmentName,

        ConsultantID,
        ConsultantName,

        AppointmentDate,
        AppointmentTime,

        AppointmentType,
        AppointmentStatus,

        Diagnosis,
        Treatment,
        OutcomeStatus

    FROM vw_AppointmentSummary

    WHERE DepartmentName = @DepartmentName

    ORDER BY
        AppointmentDate,
        AppointmentTime;

END;
GO


-- =====================================================
-- Stored Procedure: Get Patient History
--
-- Purpose:
-- Returns the complete appointment history for a
-- selected patient, including diagnosis,
-- treatment and clinical outcome.
--
-- Example:
-- EXEC usp_GetPatientHistory 1;
-- =====================================================

CREATE OR ALTER PROCEDURE usp_GetPatientHistory

    @PatientID INT

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        AppointmentID,
        PatientID,
        NHSNumber,
        PatientName,

        AppointmentDate,
        AppointmentTime,

        AppointmentType,
        AppointmentStatus,

        ConsultantID,
        ConsultantName,

        DepartmentName,

        Diagnosis,
        ProcedurePerformed,
        Treatment,

        OutcomeStatus,
        FollowUpRequired

    FROM vw_PatientJourney

    WHERE PatientID = @PatientID

    ORDER BY

        AppointmentDate,
        AppointmentTime;

END;
GO


-- =====================================================
-- Stored Procedure: Get Waiting List by Department
--
-- Purpose:
-- Returns all patients currently on the waiting list
-- for a selected department ordered by the
-- longest waiting time.
--
-- Example:
-- EXEC usp_GetWaitingListByDepartment 'Dermatology';
-- =====================================================

CREATE OR ALTER PROCEDURE usp_GetWaitingListByDepartment

    @DepartmentName VARCHAR(100)

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        WaitingListID,
        ReferralID,

        PatientID,
        PatientName,

        DepartmentName,

        DateAdded,
        TargetTreatmentDate,

        CurrentStatus,

        WeeksWaiting,

        RTTStatus

    FROM vw_WaitingListSummary

    WHERE DepartmentName = @DepartmentName

    ORDER BY

        WeeksWaiting DESC,
        DateAdded;

END;
GO


-- =====================================================
-- Stored Procedure: Get Consultant Schedule
--
-- Purpose:
-- Returns the complete appointment schedule for a
-- selected consultant including appointment details,
-- diagnosis and treatment.
--
-- Example:
-- EXEC usp_GetConsultantSchedule 1;
-- =====================================================

CREATE OR ALTER PROCEDURE usp_GetConsultantSchedule

    @ConsultantID INT

AS
BEGIN

    SET NOCOUNT ON;

    SELECT

        AppointmentID,

        AppointmentDate,
        AppointmentTime,

        PatientID,
        PatientName,

        AppointmentType,
        AppointmentStatus,

        Diagnosis,
        Treatment

    FROM vw_AppointmentSummary

    WHERE ConsultantID = @ConsultantID

    ORDER BY

        AppointmentDate,
        AppointmentTime;

END;
GO