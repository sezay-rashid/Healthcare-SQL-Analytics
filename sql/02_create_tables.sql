

USE [Healthcare SQL Analytics];
GO

-- Table: Departments
CREATE TABLE Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentCode VARCHAR(10) NOT NULL UNIQUE,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- Table: Consultants

CREATE TABLE Consultants
(
    ConsultantID INT IDENTITY(1,1) PRIMARY KEY,
    ConsultantCode VARCHAR(10) NOT NULL UNIQUE,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NULL,
    PhoneNumber VARCHAR(20) NULL,
    DepartmentID INT NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Consultants_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);
GO

-- =========================================
-- Table: Patients
-- =========================================

CREATE TABLE Patients
(
    PatientID INT IDENTITY(1,1) PRIMARY KEY,

    NHSNumber VARCHAR(10) NOT NULL UNIQUE,

    FirstName VARCHAR(50) NOT NULL,

    LastName VARCHAR(50) NOT NULL,

    DateOfBirth DATE NOT NULL,

    Gender VARCHAR(20) NOT NULL,

    Postcode VARCHAR(10) NULL,

    RegistrationDate DATE NOT NULL,

    IsActive BIT NOT NULL DEFAULT 1
);
GO

-- =========================================
-- Table: Appointments
-- =========================================

CREATE TABLE Appointments
(
    AppointmentID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    ConsultantID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    AppointmentType VARCHAR(30) NOT NULL,
    AppointmentStatus VARCHAR(30) NOT NULL,
    DurationMinutes INT NOT NULL,

    CONSTRAINT FK_Appointments_Patients
        FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID),

    CONSTRAINT FK_Appointments_Consultants
        FOREIGN KEY (ConsultantID)
        REFERENCES Consultants(ConsultantID)
);
GO

-- =========================================
-- Table: Referrals
-- =========================================

CREATE TABLE Referrals
(
    ReferralID INT IDENTITY(1,1) PRIMARY KEY,
    PatientID INT NOT NULL,
    DepartmentID INT NOT NULL,
    ReferralDate DATE NOT NULL,
    ReferralSource VARCHAR(50) NOT NULL,
    ReferralPriority VARCHAR(30) NOT NULL,
    ReferralStatus VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Referrals_Patients
        FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID),

    CONSTRAINT FK_Referrals_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);
GO

-- =========================================
-- Table: WaitingList
-- =========================================

CREATE TABLE WaitingList
(
    WaitingListID INT IDENTITY(1,1) PRIMARY KEY,
    ReferralID INT NOT NULL,
    PatientID INT NOT NULL,
    DepartmentID INT NOT NULL,
    DateAdded DATE NOT NULL,
    TargetTreatmentDate DATE NOT NULL,
    CurrentStatus VARCHAR(30) NOT NULL,
    WeeksWaiting INT NOT NULL,

    CONSTRAINT FK_WaitingList_Referrals
        FOREIGN KEY (ReferralID)
        REFERENCES Referrals(ReferralID),

    CONSTRAINT FK_WaitingList_Patients
        FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID),

    CONSTRAINT FK_WaitingList_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);
GO

-- =========================================
-- Table: AppointmentOutcomes
-- =========================================

USE [Healthcare SQL Analytics];
GO

CREATE TABLE AppointmentOutcomes
(
    OutcomeID INT IDENTITY(1,1) PRIMARY KEY,

    AppointmentID INT NOT NULL,
    PatientID INT NOT NULL,
    ConsultantID INT NOT NULL,

    Diagnosis VARCHAR(100) NOT NULL,
    ProcedurePerformed VARCHAR(100) NULL,
    Treatment VARCHAR(100) NOT NULL,

    OutcomeStatus VARCHAR(50) NOT NULL,
    FollowUpRequired BIT NOT NULL,

    OutcomeDate DATE NOT NULL,

    Notes VARCHAR(255) NULL,

    CONSTRAINT FK_AppointmentOutcomes_Appointments
        FOREIGN KEY (AppointmentID)
        REFERENCES Appointments(AppointmentID),

    CONSTRAINT FK_AppointmentOutcomes_Patients
        FOREIGN KEY (PatientID)
        REFERENCES Patients(PatientID),

    CONSTRAINT FK_AppointmentOutcomes_Consultants
        FOREIGN KEY (ConsultantID)
        REFERENCES Consultants(ConsultantID)
);
GO