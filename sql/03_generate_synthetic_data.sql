/*
=========================================================
Project : Healthcare SQL Analytics
File    : 03_import_data.sql
Author  : Sezay Rashid
Purpose : Inserts sample NHS-style data into the database.
Note    : Run this script after 01_create_database.sql
          and 02_create_tables.sql.
=========================================================
*/

USE [Healthcare SQL Analytics];
GO

-- =========================================
-- Insert Departments
-- =========================================

IF NOT EXISTS (SELECT 1 FROM Departments)
BEGIN
    INSERT INTO Departments (DepartmentCode, DepartmentName, Location)
    VALUES
    ('DERM', 'Dermatology', 'Main Hospital'),
    ('CARD', 'Cardiology', 'Main Hospital'),
    ('ORTH', 'Orthopaedics', 'West Wing'),
    ('RAD', 'Radiology', 'Imaging Centre'),
    ('ENT', 'Ear, Nose & Throat', 'Building B'),
    ('A&E', 'Emergency Department', 'Emergency Block'),
    ('ONC', 'Oncology', 'Cancer Centre'),
    ('PAED', 'Paediatrics', 'Children''s Hospital'),
    ('NEUR', 'Neurology', 'Building C');

    PRINT 'Departments inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Departments already exist. Insert skipped.';
END;
GO

-- =========================================
-- Insert Consultants
-- =========================================

IF NOT EXISTS (SELECT 1 FROM Consultants)
BEGIN
    INSERT INTO Consultants
    (
        ConsultantCode,
        FirstName,
        LastName,
        Email,
        PhoneNumber,
        DepartmentID
    )
    VALUES
    ('CONS001', 'Sarah',     'Ahmed',    's.ahmed@hospital.nhs.uk',    '0161 555 1001', 1),
    ('CONS002', 'David',     'Patel',    'd.patel@hospital.nhs.uk',    '0161 555 1002', 2),
    ('CONS003', 'James',     'Wilson',   'j.wilson@hospital.nhs.uk',   '0161 555 1003', 3),
    ('CONS004', 'Emily',     'Taylor',   'e.taylor@hospital.nhs.uk',   '0161 555 1004', 4),
    ('CONS005', 'Michael',   'Brown',    'm.brown@hospital.nhs.uk',    '0161 555 1005', 5),
    ('CONS006', 'Olivia',    'Smith',    'o.smith@hospital.nhs.uk',    '0161 555 1006', 6),
    ('CONS007', 'Daniel',    'Johnson',  'd.johnson@hospital.nhs.uk',  '0161 555 1007', 7),
    ('CONS008', 'Sophie',    'Evans',    's.evans@hospital.nhs.uk',    '0161 555 1008', 8),
    ('CONS009', 'Thomas',    'Roberts',  't.roberts@hospital.nhs.uk',  '0161 555 1009', 9),
    ('CONS010', 'Aisha',     'Khan',     'a.khan@hospital.nhs.uk',     '0161 555 1010', 1),
    ('CONS011', 'Rebecca',   'Hughes',   'r.hughes@hospital.nhs.uk',   '0161 555 1011', 2),
    ('CONS012', 'Mohammed',  'Ali',      'm.ali@hospital.nhs.uk',      '0161 555 1012', 3),
    ('CONS013', 'Charlotte', 'Walker',   'c.walker@hospital.nhs.uk',   '0161 555 1013', 4),
    ('CONS014', 'George',    'Hall',     'g.hall@hospital.nhs.uk',     '0161 555 1014', 5),
    ('CONS015', 'Maya',      'Green',    'm.green@hospital.nhs.uk',    '0161 555 1015', 6),
    ('CONS016', 'Henry',     'Baker',    'h.baker@hospital.nhs.uk',    '0161 555 1016', 7),
    ('CONS017', 'Fatima',    'Hussain',  'f.hussain@hospital.nhs.uk',  '0161 555 1017', 8),
    ('CONS018', 'Jack',      'Morris',   'j.morris@hospital.nhs.uk',   '0161 555 1018', 9),
    ('CONS019', 'Priya',     'Shah',     'p.shah@hospital.nhs.uk',     '0161 555 1019', 1),
    ('CONS020', 'William',   'Cooper',   'w.cooper@hospital.nhs.uk',   '0161 555 1020', 3);

    PRINT 'Consultants inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Consultants already exist. Insert skipped.';
END;
GO

-- =========================================
-- Generate 380 Synthetic Patients
-- =========================================

IF NOT EXISTS (SELECT 1 FROM Patients)
BEGIN
    DECLARE @Counter INT = 1;

    DECLARE @FirstNames TABLE
    (
        ID INT IDENTITY(1,1),
        FirstName VARCHAR(50)
    );

    DECLARE @LastNames TABLE
    (
        ID INT IDENTITY(1,1),
        LastName VARCHAR(50)
    );

    INSERT INTO @FirstNames (FirstName)
    VALUES
    ('James'), ('Emily'), ('Oliver'), ('Sophia'), ('Daniel'),
    ('Grace'), ('Noah'), ('Amelia'), ('Harry'), ('Isla'),
    ('Muhammad'), ('Aisha'), ('Mia'), ('George'), ('Lily'),
    ('Ethan'), ('Fatima'), ('Jack'), ('Priya'), ('Thomas');

    INSERT INTO @LastNames (LastName)
    VALUES
    ('Smith'), ('Brown'), ('Jones'), ('Taylor'), ('Wilson'),
    ('Evans'), ('Johnson'), ('Roberts'), ('Patel'), ('Khan'),
    ('Ali'), ('Walker'), ('Hall'), ('Green'), ('Baker'),
    ('Hussain'), ('Shah'), ('Morris'), ('Cooper'), ('Hughes');

    WHILE @Counter <= 380
    BEGIN
        INSERT INTO Patients
        (
            NHSNumber,
            FirstName,
            LastName,
            DateOfBirth,
            Gender,
            Postcode,
            RegistrationDate
        )
        VALUES
        (
            RIGHT('0000000000' + CAST(9000000000 + @Counter AS VARCHAR(10)), 10),
            (SELECT FirstName FROM @FirstNames WHERE ID = ((@Counter - 1) % 20) + 1),
            (SELECT LastName FROM @LastNames WHERE ID = ((@Counter - 1) % 20) + 1),
            DATEADD(DAY, -(@Counter * 47), '2010-01-01'),
            CASE WHEN @Counter % 2 = 0 THEN 'Female' ELSE 'Male' END,
            CONCAT('M', ((@Counter - 1) % 9) + 1, ' ', ((@Counter - 1) % 9) + 1, 'AB'),
            DATEADD(DAY, @Counter % 365, '2024-01-01')
        );

        SET @Counter = @Counter + 1;
    END;

    PRINT '380 synthetic patient records inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Patients already exist. Insert skipped.';
END;
GO

-- =========================================
-- Generate 1,500 Synthetic Appointments
-- Date range: 01 August 2026 to 01 August 2027
-- =========================================

IF NOT EXISTS (SELECT 1 FROM Appointments)
BEGIN
    DECLARE @AppointmentCounter INT = 1;

    WHILE @AppointmentCounter <= 1500
    BEGIN
        INSERT INTO Appointments
        (
            PatientID,
            ConsultantID,
            AppointmentDate,
            AppointmentTime,
            AppointmentType,
            AppointmentStatus,
            DurationMinutes
        )
        VALUES
        (
            ((@AppointmentCounter - 1) % 380) + 1,
            ((@AppointmentCounter - 1) % 20) + 1,
            DATEADD(DAY, (@AppointmentCounter - 1) % 366, '2026-08-01'),
            CAST(DATEADD(MINUTE, ((@AppointmentCounter - 1) % 16) * 30, CAST('08:00:00' AS TIME)) AS TIME),
            CASE
                WHEN @AppointmentCounter % 100 <= 40 THEN 'Follow-up'
                WHEN @AppointmentCounter % 100 <= 65 THEN 'Review'
                WHEN @AppointmentCounter % 100 <= 85 THEN 'New Patient'
                WHEN @AppointmentCounter % 100 <= 95 THEN 'Procedure'
                ELSE 'Urgent'
            END,
            CASE
                WHEN @AppointmentCounter % 100 <= 70 THEN 'Completed'
                WHEN @AppointmentCounter % 100 <= 85 THEN 'Scheduled'
                WHEN @AppointmentCounter % 100 <= 95 THEN 'Cancelled'
                ELSE 'DNA'
            END,
            CASE
                WHEN @AppointmentCounter % 100 <= 40 THEN 30
                WHEN @AppointmentCounter % 100 <= 65 THEN 20
                WHEN @AppointmentCounter % 100 <= 85 THEN 30
                WHEN @AppointmentCounter % 100 <= 95 THEN 60
                ELSE 45
            END
        );

        SET @AppointmentCounter = @AppointmentCounter + 1;
    END;

    PRINT '1,500 synthetic appointment records inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Appointments already exist. Insert skipped.';
END;
GO

-- =========================================
-- Final Row Count Check
-- =========================================

SELECT 'Departments' AS TableName, COUNT(*) AS TotalRows FROM Departments
UNION ALL
SELECT 'Consultants', COUNT(*) FROM Consultants
UNION ALL
SELECT 'Patients', COUNT(*) FROM Patients
UNION ALL
SELECT 'Appointments', COUNT(*) FROM Appointments;
GO

-- =========================================
-- Generate 500 Synthetic Referrals
-- Date range: 01 August 2026 to 01 August 2027
-- =========================================

IF NOT EXISTS (SELECT 1 FROM Referrals)
BEGIN
    DECLARE @ReferralCounter INT = 1;

    WHILE @ReferralCounter <= 500
    BEGIN
        INSERT INTO Referrals
        (
            PatientID,
            DepartmentID,
            ReferralDate,
            ReferralSource,
            ReferralPriority,
            ReferralStatus
        )
        VALUES
        (
            ((@ReferralCounter - 1) % 380) + 1,
            ((@ReferralCounter - 1) % 9) + 1,
            DATEADD(DAY, (@ReferralCounter - 1) % 366, '2026-08-01'),

            CASE
                WHEN @ReferralCounter % 100 <= 50 THEN 'GP'
                WHEN @ReferralCounter % 100 <= 70 THEN 'Emergency Department'
                WHEN @ReferralCounter % 100 <= 85 THEN 'Consultant'
                WHEN @ReferralCounter % 100 <= 95 THEN 'Community Clinic'
                ELSE 'Self Referral'
            END,

            CASE
                WHEN @ReferralCounter % 100 <= 75 THEN 'Routine'
                WHEN @ReferralCounter % 100 <= 92 THEN 'Urgent'
                ELSE 'Two Week Wait'
            END,

            CASE
                WHEN @ReferralCounter % 100 <= 65 THEN 'Completed'
                WHEN @ReferralCounter % 100 <= 85 THEN 'Waiting'
                WHEN @ReferralCounter % 100 <= 95 THEN 'Accepted'
                ELSE 'Rejected'
            END
        );

        SET @ReferralCounter = @ReferralCounter + 1;
    END;

    PRINT '500 synthetic referral records inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Referrals already exist. Insert skipped.';
END;
GO

-- =========================================
-- Generate 600 Synthetic Waiting List Records
-- =========================================

USE [Healthcare SQL Analytics];
GO

DECLARE @WaitingCounter INT = 1;

WHILE @WaitingCounter <= 600
BEGIN
    INSERT INTO WaitingList
    (
        ReferralID,
        PatientID,
        DepartmentID,
        DateAdded,
        TargetTreatmentDate,
        CurrentStatus,
        WeeksWaiting
    )
    VALUES
    (
        ((@WaitingCounter - 1) % 500) + 1,
        ((@WaitingCounter - 1) % 380) + 1,
        ((@WaitingCounter - 1) % 9) + 1,
        DATEADD(DAY, (@WaitingCounter - 1) % 366, '2026-08-01'),
        DATEADD(WEEK, 18, DATEADD(DAY, (@WaitingCounter - 1) % 366, '2026-08-01')),
        CASE
            WHEN @WaitingCounter % 100 <= 55 THEN 'Waiting'
            WHEN @WaitingCounter % 100 <= 80 THEN 'Booked'
            WHEN @WaitingCounter % 100 <= 95 THEN 'Completed'
            ELSE 'Cancelled'
        END,
        (@WaitingCounter % 30) + 1
    );

    SET @WaitingCounter = @WaitingCounter + 1;
END;
GO

SELECT COUNT(*) AS TotalWaitingList
FROM WaitingList;
GO

-- =========================================
-- Generate 1,000 Synthetic Appointment Outcomes
-- =========================================

IF NOT EXISTS (SELECT 1 FROM AppointmentOutcomes)
BEGIN
    ;WITH FirstThousandAppointments AS
    (
        SELECT TOP (1000)
            ROW_NUMBER() OVER (ORDER BY AppointmentID) AS RowNum,
            AppointmentID,
            PatientID,
            ConsultantID,
            AppointmentDate
        FROM Appointments
        ORDER BY AppointmentID
    )
    INSERT INTO AppointmentOutcomes
    (
        AppointmentID,
        PatientID,
        ConsultantID,
        Diagnosis,
        ProcedurePerformed,
        Treatment,
        OutcomeStatus,
        FollowUpRequired,
        OutcomeDate,
        Notes
    )
    SELECT
        AppointmentID,
        PatientID,
        ConsultantID,

        CASE
            WHEN RowNum % 10 = 0 THEN 'Basal Cell Carcinoma'
            WHEN RowNum % 10 = 1 THEN 'Eczema'
            WHEN RowNum % 10 = 2 THEN 'Psoriasis'
            WHEN RowNum % 10 = 3 THEN 'Acne'
            WHEN RowNum % 10 = 4 THEN 'Mole Assessment'
            WHEN RowNum % 10 = 5 THEN 'Seborrhoeic Keratosis'
            WHEN RowNum % 10 = 6 THEN 'Rosacea'
            WHEN RowNum % 10 = 7 THEN 'Actinic Keratosis'
            WHEN RowNum % 10 = 8 THEN 'Melanoma Suspected'
            ELSE 'Dermatitis'
        END AS Diagnosis,

        CASE
            WHEN RowNum % 5 = 0 THEN 'Skin Biopsy'
            WHEN RowNum % 5 = 1 THEN 'Cryotherapy'
            WHEN RowNum % 5 = 2 THEN 'Excision'
            ELSE NULL
        END AS ProcedurePerformed,

        CASE
            WHEN RowNum % 6 = 0 THEN 'Medication'
            WHEN RowNum % 6 = 1 THEN 'Surgical Treatment'
            WHEN RowNum % 6 = 2 THEN 'Observation'
            WHEN RowNum % 6 = 3 THEN 'Lifestyle Advice'
            WHEN RowNum % 6 = 4 THEN 'Phototherapy'
            ELSE 'Referral to Specialist'
        END AS Treatment,

        CASE
            WHEN RowNum % 4 = 0 THEN 'Discharged'
            WHEN RowNum % 4 = 1 THEN 'Follow-up Required'
            WHEN RowNum % 4 = 2 THEN 'Awaiting Results'
            ELSE 'Referred Onward'
        END AS OutcomeStatus,

        CASE
            WHEN RowNum % 4 = 1 THEN 1
            ELSE 0
        END AS FollowUpRequired,

        AppointmentDate AS OutcomeDate,

        'Synthetic appointment outcome record.' AS Notes
    FROM FirstThousandAppointments;

    PRINT '1,000 synthetic appointment outcome records inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Appointment outcomes already exist. Insert skipped.';
END;
GO