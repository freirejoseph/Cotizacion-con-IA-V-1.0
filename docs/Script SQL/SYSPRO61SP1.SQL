--! SYSPRO 6.1 SP1 Upgrade Script   @(#) Version 6.1 SP1

--! This script will upgrade your SYSPRO tables from a 6.1
--! specification to the SYSPRO 6.1 SP1 specification.
--! It must be run once on each SYSPRO company database.

--! Script last updated 15th April 2012

-- This is to be applied to SYSPRO 6.1 format databases only.

-------------------------------------------------------------------------
--  Add new 'AdmVersion' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AdmVersion') = 0
BEGIN
    CREATE TABLE AdmVersion(
       VersionKey         char(30)   NOT NULL,
       SysproVersion      char(3)    NOT NULL,
       SysproIssue        char(3)    NOT NULL,
       DateApplied        datetime   NOT NULL,
       SourceComment      char(30)   NOT NULL
    )
    PRINT 'New table AdmVersion added'
END
GO

--  Add new record to indicate SYSPRO61SP1.SQL script run
SET NOCOUNT ON
IF (SELECT COUNT(*) FROM AdmVersion WHERE VersionKey = 'Current') <> 0
BEGIN
    DELETE AdmVersion WHERE VersionKey = 'Current'
END
GO

INSERT AdmVersion
  (VersionKey, SysproVersion, SysproIssue, DateApplied, SourceComment)
 VALUES
  ('Current' , '6.1'        , '001'      , GETDATE()  , 'SYSPRO61SP1.SQL')

--  Add new version log
INSERT AdmVersion
  (VersionKey, SysproVersion, SysproIssue, DateApplied, SourceComment)
 VALUES
  (GETDATE() , '6.1'        , '001'      , GETDATE()  , 'SYSPRO61SP1.SQL')
GO
SET NOCOUNT OFF

-------------------------------------------------------------------------
--   Tax rate columns change in size

-- Column AdmTax..CurTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AdmTax' AND COLUMN_NAME = 'CurTaxRate') <> 5
BEGIN
    ALTER TABLE AdmTax ALTER COLUMN CurTaxRate decimal(5,3) NULL
    PRINT 'Column AdmTax..CurTaxRate changed to decimal(5,3)'
END
GO

-- Column AdmTax..PrvTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AdmTax' AND COLUMN_NAME = 'PrvTaxRate') <> 5
BEGIN
    ALTER TABLE AdmTax ALTER COLUMN PrvTaxRate decimal(5,3) NULL
    PRINT 'Column AdmTax..PrvTaxRate changed to decimal(5,3)'
END
GO

-- Column AdmTaxHistory..PrvTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AdmTaxHistory' AND COLUMN_NAME = 'PrvTaxRate') <> 5
BEGIN
    ALTER TABLE AdmTaxHistory ALTER COLUMN PrvTaxRate decimal(5,3) NULL
    PRINT 'Column AdmTaxHistory..PrvTaxRate changed to decimal(5,3)'
END
GO

-- Column AdmWithholdingTax..CurTaxRate changed frm decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AdmWithholdingTax' AND COLUMN_NAME = 'CurTaxRate') <> 5
BEGIN
    ALTER TABLE AdmWithholdingTax ALTER COLUMN CurTaxRate decimal(5,3) NULL
    PRINT 'Column AdmWithholdingTax..CurTaxRate changed to decimal(5,3)'
END
GO

-- Column ApInvoice..WithTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ApInvoice' AND COLUMN_NAME = 'WithTaxRate') <> 5
BEGIN
    ALTER TABLE ApInvoice ALTER COLUMN WithTaxRate decimal(5,3) NULL
    PRINT 'Column ApInvoice..WithTaxRate changed to decimal(5,3)'
END
GO

-- Column ApPayRunDet..WithTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ApPayRunDet' AND COLUMN_NAME = 'WithTaxRate') <> 5
BEGIN
    ALTER TABLE ApPayRunDet ALTER COLUMN WithTaxRate decimal(5,3) NULL
    PRINT 'Column ApPayRunDet..WithTaxRate changed to decimal(5,3)'
END
GO

-- Column ApWithholdTax..WithTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ApWithholdTax' AND COLUMN_NAME = 'WithTaxRate') <> 5
BEGIN
    ALTER TABLE ApWithholdTax ALTER COLUMN WithTaxRate decimal(5,3) NULL
    PRINT 'Column ApWithholdTax..WithTaxRate changed to decimal(5,3)'
END
GO

-- Column ArPermReprint..TaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ArPermReprint' AND COLUMN_NAME = 'TaxRate') <> 5
BEGIN
    ALTER TABLE ArPermReprint ALTER COLUMN TaxRate decimal(5,3) NULL
    PRINT 'Column ArPermReprint..TaxRate changed to decimal(5,3)'
END
GO

-- Column ArPermReprint..FstTaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ArPermReprint' AND COLUMN_NAME = 'FstTaxRate') <> 5
BEGIN
    ALTER TABLE ArPermReprint ALTER COLUMN FstTaxRate decimal(5,3) NULL
    PRINT 'Column ArPermReprint..FstTaxRate changed to decimal(5,3)'
END
GO

-- Column ArTrnGst..GstRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ArTrnGst' AND COLUMN_NAME = 'GstRate') <> 5
BEGIN
    ALTER TABLE ArTrnGst ALTER COLUMN GstRate decimal(5,3) NULL
    PRINT 'Column ArTrnGst..GstRate changed to decimal(5,3)'
END
GO

-- Column IntEdiInvDet..TaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'IntEdiInvDet' AND COLUMN_NAME = 'TaxRate') <> 5
BEGIN
    ALTER TABLE IntEdiInvDet ALTER COLUMN TaxRate decimal(5,3) NULL
    PRINT 'Column IntEdiInvDet..TaxRate changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateA changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateA') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateA decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateA changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateB changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateB') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateB decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateB changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateC changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateC') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateC decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateC changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateD changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateD') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateD decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateD changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateE changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateE') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateE decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateE changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateF changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateF') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateF decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateF changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateG changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateG') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateG decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateG changed to decimal(5,3)'
END
GO

-- Column SalGstCanSum..CurGstRateH changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanSum' AND COLUMN_NAME = 'CurGstRateH') <> 5
BEGIN
    ALTER TABLE SalGstCanSum ALTER COLUMN CurGstRateH decimal(5,3) NULL
    PRINT 'Column SalGstCanSum..CurGstRateH changed to decimal(5,3)'
END
GO

-- Column SalGstCanDet..TaxRate changed from decimal(4,2) to decimal(5,3)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'SalGstCanDet' AND COLUMN_NAME = 'TaxRate') <> 5
BEGIN
    ALTER TABLE SalGstCanDet ALTER COLUMN TaxRate decimal(5,3) NULL
    PRINT 'Column SalGstCanDet..TaxRate changed to decimal(5,3)'
END
GO

-- New column for table AdmTax
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AdmTax' AND COLUMN_NAME = 'TaxRateDecimals') = 0
BEGIN
  ALTER TABLE AdmTax ADD TaxRateDecimals decimal(1,0) NULL
  PRINT 'New column AdmTax.TaxRateDecimals'
END
GO


-------------------------------------------------------------------------

PRINT ' '
PRINT ' '
PRINT 'If no error messages were displayed above here then'
PRINT 'your database is now ready for SYSPRO 6.1 SP1'

--  End of script SYSPRO61SP1.SQL
