--! SYSPRO 6.1 Upgrade Script                      @(#) Version 6.1.000

--! This script will upgrade your SYSPRO 6.0 tables from Issue 010 SP2
--! specification to SYSPRO 6.1.
--! It must be run once on each SYSPRO company database.

--! Script last updated 4th September 2009

-- This is to be applied to SYSPRO 6.0 Issue 010 SP2 format databases only.

-- 6.1.000  Initial script developed for internal use at SYSPRO (cut-off3)

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

--  Add new record to indicate SYSPRO61.SQL script run
SET NOCOUNT ON
IF (SELECT COUNT(*) FROM AdmVersion WHERE VersionKey = 'Current') <> 0
BEGIN
    DELETE AdmVersion WHERE VersionKey = 'Current'
END
GO

INSERT AdmVersion
  (VersionKey, SysproVersion, SysproIssue, DateApplied, SourceComment)
 VALUES
  ('Current' , '6.1'        , '001'      , GETDATE()  , 'SYSPRO61.SQL')

--  Add new version log
INSERT AdmVersion
  (VersionKey, SysproVersion, SysproIssue, DateApplied, SourceComment)
 VALUES
  (GETDATE() , '6.1'        , '001'      , GETDATE()  , 'SYSPRO61.SQL')
GO
SET NOCOUNT OFF


-------------------------------------------------------------------------
-- New tables

--  Add new 'AdmAnalyticsCtl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AdmAnalyticsCtl') = 0
BEGIN
    CREATE TABLE AdmAnalyticsCtl(
     FilterSite               DECIMAL(15,0)       NOT NULL,
     FilterTable              CHAR(30)            NOT NULL,
     FilterValue              CHAR(20)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AdmAnalyticsCtlKey PRIMARY KEY CLUSTERED
         (
          FilterSite,
          FilterTable
         )
    )
    PRINT 'New table AdmAnalyticsCtl'
END
GO

--  Add new 'AdmTaxReturn' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AdmTaxReturn') = 0
BEGIN
    CREATE TABLE AdmTaxReturn(
     Company                  CHAR(2)             NOT NULL,
     Source                   CHAR(2)             NOT NULL,
     JnlYear                  DECIMAL(4,0)        NOT NULL,
     JnlMonth                 DECIMAL(2,0)        NOT NULL,
     Journal                  DECIMAL(5,0)        NOT NULL,
     Entry                    DECIMAL(4,0)        NOT NULL,
     TaxCode                  CHAR(1)             NOT NULL,
     InputOutPut              CHAR(1)             NOT NULL,
     Vendor                   CHAR(7)             NULL,
     Status                   DECIMAL(1,0)        NULL,
     Invoice                  CHAR(20)            NULL,
     Reference                CHAR(30)            NULL,
     InvoiceDate              DATETIME            NULL,
     InvoiceValue             DECIMAL(14,2)       NULL,
     InvoiceDisc              DECIMAL(14,2)       NULL,
     TaxValue                 DECIMAL(14,2)       NULL,
     Nationality              CHAR(3)             NULL,
     EcAcquisition            CHAR(1)             NULL,
     PurchaseType             CHAR(1)             NULL,
     ExemptValue              DECIMAL(14,2)       NULL,
     TaxRetSubmitted          CHAR(1)             NULL,
     SubmittedDate            DATETIME            NULL,
     YearRetSubmitted         DECIMAL(4,0)        NULL,
     MthRetSubmitted          DECIMAL(2,0)        NULL,
     VatPeriod                DECIMAL(2,0)        NULL,
     VatYear                  DECIMAL(4,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AdmTaxReturnKey PRIMARY KEY CLUSTERED
         (
          Company,
          Source,
          JnlYear,
          JnlMonth,
          Journal,
          Entry,
          TaxCode,
          InputOutPut
         )
    )
    PRINT 'New table AdmTaxReturn'
END
GO

--  Add new 'ApPayRunChkDet' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ApPayRunChkDet') = 0
BEGIN
    CREATE TABLE ApPayRunChkDet(
     PaymentNumber            CHAR(7)             NOT NULL,
     ChRegister               DECIMAL(3,0)        NOT NULL,
     Supplier                 CHAR(7)             NOT NULL,
     Cheque                   CHAR(6)             NULL,
     ChequeDate               DATETIME            NULL,
     Bank                     CHAR(2)             NULL,
     LastChequeVal            DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ApPayRunChkDetKey PRIMARY KEY CLUSTERED
         (
          PaymentNumber,
          ChRegister,
          Supplier
         )
    )
    PRINT 'New table ApPayRunChkDet'
END
GO

--  Add new 'ApInvoiceRegPo' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ApInvoiceRegPo') = 0
BEGIN
    CREATE TABLE ApInvoiceRegPo(
     Supplier                 CHAR(7)             NOT NULL,
     Invoice                  CHAR(20)            NOT NULL,
     PurchaseOrder            CHAR(6)             NOT NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ApInvoiceRegPoKey PRIMARY KEY CLUSTERED
         (
          Supplier,
          Invoice,
          PurchaseOrder
         )
    )
    CREATE UNIQUE INDEX ApInvoiceRegPoIdxPo ON ApInvoiceRegPo(
     PurchaseOrder,
     Supplier,
     Invoice
     )
    PRINT 'New table ApInvoiceRegPo'
END
GO

--  Add new 'ArInvoiceReference' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ArInvoiceReference') = 0
BEGIN
    CREATE TABLE ArInvoiceReference(
     Invoice                  CHAR(6)             NOT NULL,
     DocumentType             CHAR(1)             NOT NULL,
     Customer                 CHAR(7)             NULL,
     InvoiceDate              DATETIME            NULL,
     SalesOrder               CHAR(6)             NULL,
     DispatchNote             CHAR(15)            NULL,
     AllocatedByProgram       CHAR(6)             NULL,
     AllocatedDate            DATETIME            NULL,
     AllocatedTime            DECIMAL(8,0)        NULL,
     AllocatedByOper          CHAR(6)             NULL,
     CreatedByProgram         CHAR(6)             NULL,
     CreatedDate              DATETIME            NULL,
     CreatedTime              DECIMAL(8,0)        NULL,
     CreatedByOper            CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ArInvoiceReferenceKey PRIMARY KEY CLUSTERED
         (
          Invoice,
          DocumentType
         )
    )
    PRINT 'New table ArInvoiceReference'
END
GO

--  Add new 'ArTrnTaxUkVat' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ArTrnTaxUkVat') = 0
BEGIN
    CREATE TABLE ArTrnTaxUkVat(
     TrnYear                  DECIMAL(4,0)        NOT NULL,
     TrnMonth                 DECIMAL(2,0)        NOT NULL,
     Register                 DECIMAL(5,0)        NOT NULL,
     Invoice                  CHAR(6)             NOT NULL,
     SummaryLine              DECIMAL(5,0)        NOT NULL,
     InterfaceFlag            CHAR(1)             NULL,
     TaxCode1                 CHAR(1)             NULL,
     TaxCode2                 CHAR(1)             NULL,
     TaxCode3                 CHAR(1)             NULL,
     TaxCode4                 CHAR(1)             NULL,
     TaxCode5                 CHAR(1)             NULL,
     TaxableValue1            DECIMAL(14,2)       NULL,
     TaxableValue2            DECIMAL(14,2)       NULL,
     TaxableValue3            DECIMAL(14,2)       NULL,
     TaxableValue4            DECIMAL(14,2)       NULL,
     TaxableValue5            DECIMAL(14,2)       NULL,
     TaxValue1                DECIMAL(14,2)       NULL,
     TaxValue2                DECIMAL(14,2)       NULL,
     TaxValue3                DECIMAL(14,2)       NULL,
     TaxValue4                DECIMAL(14,2)       NULL,
     TaxValue5                DECIMAL(14,2)       NULL,
     NonTaxValue1             DECIMAL(14,2)       NULL,
     NonTaxValue2             DECIMAL(14,2)       NULL,
     NonTaxValue3             DECIMAL(14,2)       NULL,
     NonTaxValue4             DECIMAL(14,2)       NULL,
     NonTaxValue5             DECIMAL(14,2)       NULL,
     BlankTaxableVal          DECIMAL(14,2)       NULL,
     UkCurrency               CHAR(3)             NULL,
     UkRate                   DECIMAL(12,6)       NULL,
     UkMulDiv                 CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ArTrnTaxUkVatKey PRIMARY KEY CLUSTERED
         (
          TrnYear,
          TrnMonth,
          Register,
          Invoice,
          SummaryLine
         )
    )
    PRINT 'New table ArTrnTaxUkVat'
END
GO

--  Add new 'AssetControlAlt' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetControlAlt') = 0
BEGIN
    CREATE TABLE AssetControlAlt(
     CtlFlag                  CHAR(3)             NOT NULL,
     AltCode                  DECIMAL(2,0)        NOT NULL,
     DepnValueYtd             DECIMAL(14,2)       NULL,
     DepnRevalYtd             DECIMAL(14,2)       NULL,
     DepnIciYtd               DECIMAL(14,2)       NULL,
     DepnIcoYtd               DECIMAL(14,2)       NULL,
     DepnAddsYtd              DECIMAL(14,2)       NULL,
     DepnDispsYtd             DECIMAL(14,2)       NULL,
     DepnCountYtd             DECIMAL(14,2)       NULL,
     DepnSplitYtd             DECIMAL(14,2)       NULL,
     RevalYtd                 DECIMAL(14,2)       NULL,
     IciYtd                   DECIMAL(14,2)       NULL,
     IcoYtd                   DECIMAL(14,2)       NULL,
     AdditionsYtd             DECIMAL(14,2)       NULL,
     DisposalsYtd             DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     CountYtd                 DECIMAL(14,2)       NULL,
     SplitYtd                 DECIMAL(14,2)       NULL,
     ChangeYtd                DECIMAL(14,2)       NULL,
     OpenValue                DECIMAL(14,2)       NULL,
     OpenDepnValue            DECIMAL(14,2)       NULL,
     OpenDepnRevalValue       DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetControlAltKey PRIMARY KEY CLUSTERED
         (
          CtlFlag,
          AltCode
         )
    )
    PRINT 'New table AssetControlAlt'
END
GO

--  Add new 'AssetControlBv' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetControlBv') = 0
BEGIN
    CREATE TABLE AssetControlBv(
     CtlFlag                  CHAR(3)             NOT NULL,
     DepnValueYtd             DECIMAL(14,2)       NULL,
     DepnRevalYtd             DECIMAL(14,2)       NULL,
     DepnIciYtd               DECIMAL(14,2)       NULL,
     DepnIcoYtd               DECIMAL(14,2)       NULL,
     DepnAddsYtd              DECIMAL(14,2)       NULL,
     DepnDispsYtd             DECIMAL(14,2)       NULL,
     DepnCountYtd             DECIMAL(14,2)       NULL,
     DepnSplitYtd             DECIMAL(14,2)       NULL,
     RevalYtd                 DECIMAL(14,2)       NULL,
     IciYtd                   DECIMAL(14,2)       NULL,
     IcoYtd                   DECIMAL(14,2)       NULL,
     AdditionsYtd             DECIMAL(14,2)       NULL,
     DisposalsYtd             DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     CountYtd                 DECIMAL(14,2)       NULL,
     SplitYtd                 DECIMAL(14,2)       NULL,
     ChangeYtd                DECIMAL(14,2)       NULL,
     OpenValue                DECIMAL(14,2)       NULL,
     OpenDepnValue            DECIMAL(14,2)       NULL,
     OpenDepnRevalValue       DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetControlBvKey PRIMARY KEY CLUSTERED
         (
          CtlFlag
         )
    )
    PRINT 'New table AssetControlBv'
END
GO

--  Add new 'AssetControlTax' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetControlTax') = 0
BEGIN
    CREATE TABLE AssetControlTax(
     CtlFlag                  CHAR(3)             NOT NULL,
     DepnValueYtd             DECIMAL(14,2)       NULL,
     DepnRevalYtd             DECIMAL(14,2)       NULL,
     DepnIciYtd               DECIMAL(14,2)       NULL,
     DepnIcoYtd               DECIMAL(14,2)       NULL,
     DepnAddsYtd              DECIMAL(14,2)       NULL,
     DepnDispsYtd             DECIMAL(14,2)       NULL,
     DepnCountYtd             DECIMAL(14,2)       NULL,
     DepnSplitYtd             DECIMAL(14,2)       NULL,
     RevalYtd                 DECIMAL(14,2)       NULL,
     IciYtd                   DECIMAL(14,2)       NULL,
     IcoYtd                   DECIMAL(14,2)       NULL,
     AdditionsYtd             DECIMAL(14,2)       NULL,
     DisposalsYtd             DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     CountYtd                 DECIMAL(14,2)       NULL,
     SplitYtd                 DECIMAL(14,2)       NULL,
     ChangeYtd                DECIMAL(14,2)       NULL,
     OpenValue                DECIMAL(14,2)       NULL,
     OpenDepnValue            DECIMAL(14,2)       NULL,
     OpenDepnRevalValue       DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetControlTaxKey PRIMARY KEY CLUSTERED
         (
          CtlFlag
         )
    )
    PRINT 'New table AssetControlTax'
END
GO

--  Add new 'AssetDepnAlt' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetDepnAlt') = 0
BEGIN
    CREATE TABLE AssetDepnAlt(
     Asset                    CHAR(15)            NOT NULL,
     AltCode                  DECIMAL(2,0)        NOT NULL,
     AssetCost                DECIMAL(14,2)       NULL,
     CurrentValue             DECIMAL(14,2)       NULL,
     AccumDepn                DECIMAL(14,2)       NULL,
     DepnPrevYr               DECIMAL(14,2)       NULL,
     DepnThisYear             DECIMAL(14,2)       NULL,
     DepnThisPeriod           DECIMAL(14,2)       NULL,
     ResidualValue            DECIMAL(14,2)       NULL,
     BookValDep               CHAR(2)             NULL,
     Suspend                  CHAR(1)             NULL,
     StartDep                 DATETIME            NULL,
     DepnStartPeriod          DECIMAL(2,0)        NULL,
     DepnStartYear            DECIMAL(4,0)        NULL,
     ThruputEul               DECIMAL(14,2)       NULL,
     StatGlCode               CHAR(15)            NULL,
     NumberOfPeriods          DECIMAL(4,0)        NULL,
     NumberOfYears            DECIMAL(4,0)        NULL,
     RevalReserveToDate       DECIMAL(14,2)       NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     RemainingPeriods         DECIMAL(4,0)        NULL,
     TotalPeriodsTd           DECIMAL(4,0)        NULL,
     VaryingAnniversary       CHAR(1)             NULL,
     RevalReason              CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetDepnAltKey PRIMARY KEY CLUSTERED
         (
          Asset,
          AltCode
         )
    )
    PRINT 'New table AssetDepnAlt'
END
GO

--  Add new 'AssetDepnBv' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetDepnBv') = 0
BEGIN
    CREATE TABLE AssetDepnBv(
     Asset                    CHAR(15)            NOT NULL,
     AssetCost                DECIMAL(14,2)       NULL,
     CurrentValue             DECIMAL(14,2)       NULL,
     AccumDepn                DECIMAL(14,2)       NULL,
     DepnPrevYr               DECIMAL(14,2)       NULL,
     DepnThisYear             DECIMAL(14,2)       NULL,
     DepnThisPeriod           DECIMAL(14,2)       NULL,
     ResidualValue            DECIMAL(14,2)       NULL,
     BookValDep               CHAR(2)             NULL,
     Suspend                  CHAR(1)             NULL,
     StartDepDate             DATETIME            NULL,
     DepnStartPeriod          DECIMAL(2,0)        NULL,
     DepnStartYear            DECIMAL(4,0)        NULL,
     ThruputEul               DECIMAL(14,2)       NULL,
     StatGlCode               CHAR(15)            NULL,
     NumberOfPeriods          DECIMAL(4,0)        NULL,
     NumberOfYears            DECIMAL(4,0)        NULL,
     RevalReserveToDate       DECIMAL(14,2)       NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     RemainingPeriods         DECIMAL(4,0)        NULL,
     TotalPeriodsTd           DECIMAL(4,0)        NULL,
     VaryingAnniversary       CHAR(1)             NULL,
     RevalReason              CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetDepnBvKey PRIMARY KEY CLUSTERED
         (
          Asset
         )
    )
    PRINT 'New table AssetDepnBv'
END
GO

--  Add new 'AssetDeprVarAnnual' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetDeprVarAnnual') = 0
BEGIN
    CREATE TABLE AssetDeprVarAnnual(
     DepreciationCode         CHAR(2)             NOT NULL,
     DepreciationYear         DECIMAL(2,0)        NOT NULL,
     DepnPct                  DECIMAL(7,4)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetDeprVarAnnualKey PRIMARY KEY CLUSTERED
         (
          DepreciationCode,
          DepreciationYear
         )
    )
    PRINT 'New table AssetDeprVarAnnual'
END
GO

--  Add new 'AssetDeprVarPeriod' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetDeprVarPeriod') = 0
BEGIN
    CREATE TABLE AssetDeprVarPeriod(
     DepreciationCode         CHAR(2)             NOT NULL,
     DepreciationYear         DECIMAL(2,0)        NOT NULL,
     Period                   DECIMAL(2,0)        NOT NULL,
     DepnPct                  DECIMAL(7,4)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetDeprVarPeriodKey PRIMARY KEY CLUSTERED
         (
          DepreciationCode,
          DepreciationYear,
          Period
         )
    )
    PRINT 'New table AssetDeprVarPeriod'
END
GO

--  Add new 'AssetDepnTax' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetDepnTax') = 0
BEGIN
    CREATE TABLE AssetDepnTax(
     Asset                    CHAR(15)            NOT NULL,
     AssetCost                DECIMAL(14,2)       NULL,
     CurrentValue             DECIMAL(14,2)       NULL,
     AccumDepn                DECIMAL(14,2)       NULL,
     DepnPrevYr               DECIMAL(14,2)       NULL,
     DepnThisYear             DECIMAL(14,2)       NULL,
     DepnThisPeriod           DECIMAL(14,2)       NULL,
     ResidualValue            DECIMAL(14,2)       NULL,
     BookValDep               CHAR(2)             NULL,
     Suspend                  CHAR(1)             NULL,
     StartDepDate             DATETIME            NULL,
     DepnStartPeriod          DECIMAL(2,0)        NULL,
     DepnStartYear            DECIMAL(4,0)        NULL,
     ThruputEul               DECIMAL(14,2)       NULL,
     StatGlCode               CHAR(15)            NULL,
     NumberOfPeriods          DECIMAL(4,0)        NULL,
     NumberOfYears            DECIMAL(4,0)        NULL,
     RevalReserveToDate       DECIMAL(14,2)       NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     RemainingPeriods         DECIMAL(4,0)        NULL,
     TotalPeriodsTd           DECIMAL(4,0)        NULL,
     VaryingAnniversary       CHAR(1)             NULL,
     RevalReason              CHAR(6)             NULL,
     CapitalGainsTaxVal       DECIMAL(14,2)       NULL,
     InvestAllowPct           DECIMAL(6,3)        NULL,
     InitialAllowPct          DECIMAL(6,3)        NULL,
     InitialAllowVal          DECIMAL(14,2)       NULL,
     InvestAllowVal           DECIMAL(14,2)       NULL,
     AllowTakenFlag           CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetDepnTaxKey PRIMARY KEY CLUSTERED
         (
          Asset
         )
    )
    PRINT 'New table AssetDepnTax'
END
GO

--  Add new 'AssetEntriesAlt' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetEntriesAlt') = 0
BEGIN
    CREATE TABLE AssetEntriesAlt(
     Asset                    CHAR(15)            NOT NULL,
     AltCode                  DECIMAL(2,0)        NOT NULL,
     EntryYear                DECIMAL(4,0)        NOT NULL,
     EntryMonth               DECIMAL(2,0)        NOT NULL,
     SystemDate               DATETIME            NOT NULL,
     SystemTime               DECIMAL(8,0)        NOT NULL,
     EntryType                CHAR(3)             NULL,
     EntryDate                DATETIME            NULL,
     EntryAmount              DECIMAL(14,2)       NULL,
     AssetCost                DECIMAL(14,2)       NULL,
     AssetCurrentValue        DECIMAL(14,2)       NULL,
     EntryQty                 DECIMAL(17,5)       NULL,
     AssetQty                 DECIMAL(17,5)       NULL,
     DepnYtd                  DECIMAL(14,2)       NULL,
     DepnPrevYear             DECIMAL(14,2)       NULL,
     AccumDepn                DECIMAL(14,2)       NULL,
     ResidualValue            DECIMAL(14,2)       NULL,
     DepnCode                 CHAR(2)             NULL,
     DepnRate                 DECIMAL(7,4)        NULL,
     DepnStartDate            DATETIME            NULL,
     ThruputEul               DECIMAL(14,2)       NULL,
     RevalReserveToDate       DECIMAL(14,2)       NULL,
     StatGlCode               CHAR(15)            NULL,
     NumberOfPeriods          DECIMAL(4,0)        NULL,
     NumberOfYears            DECIMAL(4,0)        NULL,
     TotalPeriodsTd           DECIMAL(4,0)        NULL,
     MinBookValue             DECIMAL(14,2)       NULL,
     Suspend                  CHAR(1)             NULL,
     Reason                   CHAR(6)             NULL,
     AssetStatus              CHAR(6)             NULL,
     Branch                   CHAR(6)             NULL,
     Location                 CHAR(10)            NULL,
     AssetGroupCode           CHAR(4)             NULL,
     AssetCostCenter          CHAR(6)             NULL,
     CompanyBefore            CHAR(1)             NULL,
     CompanyAfter             CHAR(1)             NULL,
     BranchAfter              CHAR(6)             NULL,
     GroupAfter               CHAR(4)             NULL,
     CostCenterAfter          CHAR(6)             NULL,
     GlCode                   CHAR(15)            NULL,
     Operator                 CHAR(6)             NULL,
     CapexCode                CHAR(15)            NULL,
     CapexLine                DECIMAL(5,0)        NULL,
     EntryReference           CHAR(30)            NULL,
     Narration                CHAR(60)            NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetEntriesAltKey PRIMARY KEY CLUSTERED
         (
          Asset,
          AltCode,
          EntryYear,
          EntryMonth,
          SystemDate,
          SystemTime
         )
    )
    CREATE UNIQUE INDEX AssetEntriesAltIdxEntTyp ON AssetEntriesAlt(
     Asset,
     AltCode,
     EntryType,
     EntryYear,
     EntryMonth,
     SystemDate,
     SystemTime
     )
    PRINT 'New table AssetEntriesAlt'
END
GO

--  Add new 'AssetEntriesBv' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetEntriesBv') = 0
BEGIN
    CREATE TABLE AssetEntriesBv(
     Asset                    CHAR(15)            NOT NULL,
     EntryYear                DECIMAL(4,0)        NOT NULL,
     EntryMonth               DECIMAL(2,0)        NOT NULL,
     SystemDate               DATETIME            NOT NULL,
     SystemTime               DECIMAL(8,0)        NOT NULL,
     EntryType                CHAR(3)             NULL,
     EntryDate                DATETIME            NULL,
     EntryAmount              DECIMAL(14,2)       NULL,
     AssetCost                DECIMAL(14,2)       NULL,
     AssetCurrentValue        DECIMAL(14,2)       NULL,
     EntryQty                 DECIMAL(17,5)       NULL,
     AssetQty                 DECIMAL(17,5)       NULL,
     DepnYtd                  DECIMAL(14,2)       NULL,
     DepnPrevYear             DECIMAL(14,2)       NULL,
     AccumDepn                DECIMAL(14,2)       NULL,
     ResidualValue            DECIMAL(14,2)       NULL,
     DepnCode                 CHAR(2)             NULL,
     DepnRate                 DECIMAL(7,4)        NULL,
     DepnStartDate            DATETIME            NULL,
     ThruputEul               DECIMAL(14,2)       NULL,
     RevalReserveToDate       DECIMAL(14,2)       NULL,
     StatGlCode               CHAR(15)            NULL,
     NumberOfPeriods          DECIMAL(4,0)        NULL,
     NumberOfYears            DECIMAL(4,0)        NULL,
     TotalPeriodsTd           DECIMAL(4,0)        NULL,
     MinBookValue             DECIMAL(14,2)       NULL,
     Suspend                  CHAR(1)             NULL,
     Reason                   CHAR(6)             NULL,
     AssetStatus              CHAR(6)             NULL,
     Branch                   CHAR(6)             NULL,
     Location                 CHAR(10)            NULL,
     AssetGroupCode           CHAR(4)             NULL,
     AssetCostCenter          CHAR(6)             NULL,
     CompanyBefore            CHAR(1)             NULL,
     CompanyAfter             CHAR(1)             NULL,
     BranchAfter              CHAR(6)             NULL,
     GroupAfter               CHAR(4)             NULL,
     CostCenterAfter          CHAR(6)             NULL,
     GlCode                   CHAR(15)            NULL,
     Operator                 CHAR(6)             NULL,
     CapexCode                CHAR(15)            NULL,
     CapexLine                DECIMAL(5,0)        NULL,
     EntryReference           CHAR(30)            NULL,
     Narration                CHAR(60)            NULL,
     AssetDistReg             DECIMAL(7,0)        NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetEntriesBvKey PRIMARY KEY CLUSTERED
         (
          Asset,
          EntryYear,
          EntryMonth,
          SystemDate,
          SystemTime
         )
    )
    CREATE UNIQUE INDEX AssetEntriesBvIdxEntTyp ON AssetEntriesBv(
     Asset,
     EntryType,
     EntryYear,
     EntryMonth,
     SystemDate,
     SystemTime
     )
    PRINT 'New table AssetEntriesBv'
END
GO

--  Add new 'AssetEntriesTax' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetEntriesTax') = 0
BEGIN
    CREATE TABLE AssetEntriesTax(
     Asset                    CHAR(15)            NOT NULL,
     EntryYear                DECIMAL(4,0)        NOT NULL,
     EntryMonth               DECIMAL(2,0)        NOT NULL,
     SystemDate               DATETIME            NOT NULL,
     SystemTime               DECIMAL(8,0)        NOT NULL,
     EntryType                CHAR(3)             NULL,
     EntryDate                DATETIME            NULL,
     EntryAmount              DECIMAL(14,2)       NULL,
     AssetCost                DECIMAL(14,2)       NULL,
     AssetCurrentValue        DECIMAL(14,2)       NULL,
     EntryQty                 DECIMAL(17,5)       NULL,
     AssetQty                 DECIMAL(17,5)       NULL,
     DepnYtd                  DECIMAL(14,2)       NULL,
     DepnPrevYear             DECIMAL(14,2)       NULL,
     AccumDepn                DECIMAL(14,2)       NULL,
     ResidualValue            DECIMAL(14,2)       NULL,
     DepnCode                 CHAR(2)             NULL,
     DepnRate                 DECIMAL(7,4)        NULL,
     DepnStartDate            DATETIME            NULL,
     ThruputEul               DECIMAL(14,2)       NULL,
     RevalReserveToDate       DECIMAL(14,2)       NULL,
     StatGlCode               CHAR(15)            NULL,
     NumberOfPeriods          DECIMAL(4,0)        NULL,
     NumberOfYears            DECIMAL(4,0)        NULL,
     TotalPeriodsTd           DECIMAL(4,0)        NULL,
     MinBookValue             DECIMAL(14,2)       NULL,
     Suspend                  CHAR(1)             NULL,
     Reason                   CHAR(6)             NULL,
     AssetStatus              CHAR(6)             NULL,
     Branch                   CHAR(6)             NULL,
     Location                 CHAR(10)            NULL,
     AssetGroupCode           CHAR(4)             NULL,
     AssetCostCenter          CHAR(6)             NULL,
     CompanyBefore            CHAR(1)             NULL,
     CompanyAfter             CHAR(1)             NULL,
     BranchAfter              CHAR(6)             NULL,
     GroupAfter               CHAR(4)             NULL,
     CostCenterAfter          CHAR(6)             NULL,
     GlCode                   CHAR(15)            NULL,
     Operator                 CHAR(6)             NULL,
     CapexCode                CHAR(15)            NULL,
     CapexLine                DECIMAL(5,0)        NULL,
     EntryReference           CHAR(30)            NULL,
     Narration                CHAR(60)            NULL,
     AssetDistReg             DECIMAL(7,0)        NULL,
     SoldValue                DECIMAL(14,2)       NULL,
     DisposalCost             DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetEntriesTaxKey PRIMARY KEY CLUSTERED
         (
          Asset,
          EntryYear,
          EntryMonth,
          SystemDate,
          SystemTime
         )
    )
    CREATE UNIQUE INDEX AssetEntriesTaxIdxEntTyp ON AssetEntriesTax(
     Asset,
     EntryType,
     EntryYear,
     EntryMonth,
     SystemDate,
     SystemTime
     )
    PRINT 'New table AssetEntriesTax'
END
GO

--  Add new 'AssetHistoryAlt' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetHistoryAlt') = 0
BEGIN
    CREATE TABLE AssetHistoryAlt(
     Asset                    CHAR(15)            NOT NULL,
     AltCode                  DECIMAL(2,0)        NOT NULL,
     DepreciationYear         DECIMAL(4,0)        NOT NULL,
     DepnValue1               DECIMAL(14,2)       NULL,
     DepnValue2               DECIMAL(14,2)       NULL,
     DepnValue3               DECIMAL(14,2)       NULL,
     DepnValue4               DECIMAL(14,2)       NULL,
     DepnValue5               DECIMAL(14,2)       NULL,
     DepnValue6               DECIMAL(14,2)       NULL,
     DepnValue7               DECIMAL(14,2)       NULL,
     DepnValue8               DECIMAL(14,2)       NULL,
     DepnValue9               DECIMAL(14,2)       NULL,
     DepnValue10              DECIMAL(14,2)       NULL,
     DepnValue11              DECIMAL(14,2)       NULL,
     DepnValue12              DECIMAL(14,2)       NULL,
     DepnValue13              DECIMAL(14,2)       NULL,
     DepnRevalValue1          DECIMAL(14,2)       NULL,
     DepnRevalValue2          DECIMAL(14,2)       NULL,
     DepnRevalValue3          DECIMAL(14,2)       NULL,
     DepnRevalValue4          DECIMAL(14,2)       NULL,
     DepnRevalValue5          DECIMAL(14,2)       NULL,
     DepnRevalValue6          DECIMAL(14,2)       NULL,
     DepnRevalValue7          DECIMAL(14,2)       NULL,
     DepnRevalValue8          DECIMAL(14,2)       NULL,
     DepnRevalValue9          DECIMAL(14,2)       NULL,
     DepnRevalValue10         DECIMAL(14,2)       NULL,
     DepnRevalValue11         DECIMAL(14,2)       NULL,
     DepnRevalValue12         DECIMAL(14,2)       NULL,
     DepnRevalValue13         DECIMAL(14,2)       NULL,
     DepnAdditions1           DECIMAL(14,2)       NULL,
     DepnAdditions2           DECIMAL(14,2)       NULL,
     DepnAdditions3           DECIMAL(14,2)       NULL,
     DepnAdditions4           DECIMAL(14,2)       NULL,
     DepnAdditions5           DECIMAL(14,2)       NULL,
     DepnAdditions6           DECIMAL(14,2)       NULL,
     DepnAdditions7           DECIMAL(14,2)       NULL,
     DepnAdditions8           DECIMAL(14,2)       NULL,
     DepnAdditions9           DECIMAL(14,2)       NULL,
     DepnAdditions10          DECIMAL(14,2)       NULL,
     DepnAdditions11          DECIMAL(14,2)       NULL,
     DepnAdditions12          DECIMAL(14,2)       NULL,
     DepnAdditions13          DECIMAL(14,2)       NULL,
     DepnDisposals1           DECIMAL(14,2)       NULL,
     DepnDisposals2           DECIMAL(14,2)       NULL,
     DepnDisposals3           DECIMAL(14,2)       NULL,
     DepnDisposals4           DECIMAL(14,2)       NULL,
     DepnDisposals5           DECIMAL(14,2)       NULL,
     DepnDisposals6           DECIMAL(14,2)       NULL,
     DepnDisposals7           DECIMAL(14,2)       NULL,
     DepnDisposals8           DECIMAL(14,2)       NULL,
     DepnDisposals9           DECIMAL(14,2)       NULL,
     DepnDisposals10          DECIMAL(14,2)       NULL,
     DepnDisposals11          DECIMAL(14,2)       NULL,
     DepnDisposals12          DECIMAL(14,2)       NULL,
     DepnDisposals13          DECIMAL(14,2)       NULL,
     DepnAssetCount1          DECIMAL(14,2)       NULL,
     DepnAssetCount2          DECIMAL(14,2)       NULL,
     DepnAssetCount3          DECIMAL(14,2)       NULL,
     DepnAssetCount4          DECIMAL(14,2)       NULL,
     DepnAssetCount5          DECIMAL(14,2)       NULL,
     DepnAssetCount6          DECIMAL(14,2)       NULL,
     DepnAssetCount7          DECIMAL(14,2)       NULL,
     DepnAssetCount8          DECIMAL(14,2)       NULL,
     DepnAssetCount9          DECIMAL(14,2)       NULL,
     DepnAssetCount10         DECIMAL(14,2)       NULL,
     DepnAssetCount11         DECIMAL(14,2)       NULL,
     DepnAssetCount12         DECIMAL(14,2)       NULL,
     DepnAssetCount13         DECIMAL(14,2)       NULL,
     DepnAssetSplit1          DECIMAL(14,2)       NULL,
     DepnAssetSplit2          DECIMAL(14,2)       NULL,
     DepnAssetSplit3          DECIMAL(14,2)       NULL,
     DepnAssetSplit4          DECIMAL(14,2)       NULL,
     DepnAssetSplit5          DECIMAL(14,2)       NULL,
     DepnAssetSplit6          DECIMAL(14,2)       NULL,
     DepnAssetSplit7          DECIMAL(14,2)       NULL,
     DepnAssetSplit8          DECIMAL(14,2)       NULL,
     DepnAssetSplit9          DECIMAL(14,2)       NULL,
     DepnAssetSplit10         DECIMAL(14,2)       NULL,
     DepnAssetSplit11         DECIMAL(14,2)       NULL,
     DepnAssetSplit12         DECIMAL(14,2)       NULL,
     DepnAssetSplit13         DECIMAL(14,2)       NULL,
     RevalValue1              DECIMAL(14,2)       NULL,
     RevalValue2              DECIMAL(14,2)       NULL,
     RevalValue3              DECIMAL(14,2)       NULL,
     RevalValue4              DECIMAL(14,2)       NULL,
     RevalValue5              DECIMAL(14,2)       NULL,
     RevalValue6              DECIMAL(14,2)       NULL,
     RevalValue7              DECIMAL(14,2)       NULL,
     RevalValue8              DECIMAL(14,2)       NULL,
     RevalValue9              DECIMAL(14,2)       NULL,
     RevalValue10             DECIMAL(14,2)       NULL,
     RevalValue11             DECIMAL(14,2)       NULL,
     RevalValue12             DECIMAL(14,2)       NULL,
     RevalValue13             DECIMAL(14,2)       NULL,
     InterCoIn1               DECIMAL(14,2)       NULL,
     InterCoIn2               DECIMAL(14,2)       NULL,
     InterCoIn3               DECIMAL(14,2)       NULL,
     InterCoIn4               DECIMAL(14,2)       NULL,
     InterCoIn5               DECIMAL(14,2)       NULL,
     InterCoIn6               DECIMAL(14,2)       NULL,
     InterCoIn7               DECIMAL(14,2)       NULL,
     InterCoIn8               DECIMAL(14,2)       NULL,
     InterCoIn9               DECIMAL(14,2)       NULL,
     InterCoIn10              DECIMAL(14,2)       NULL,
     InterCoIn11              DECIMAL(14,2)       NULL,
     InterCoIn12              DECIMAL(14,2)       NULL,
     InterCoIn13              DECIMAL(14,2)       NULL,
     InterCoOut1              DECIMAL(14,2)       NULL,
     InterCoOut2              DECIMAL(14,2)       NULL,
     InterCoOut3              DECIMAL(14,2)       NULL,
     InterCoOut4              DECIMAL(14,2)       NULL,
     InterCoOut5              DECIMAL(14,2)       NULL,
     InterCoOut6              DECIMAL(14,2)       NULL,
     InterCoOut7              DECIMAL(14,2)       NULL,
     InterCoOut8              DECIMAL(14,2)       NULL,
     InterCoOut9              DECIMAL(14,2)       NULL,
     InterCoOut10             DECIMAL(14,2)       NULL,
     InterCoOut11             DECIMAL(14,2)       NULL,
     InterCoOut12             DECIMAL(14,2)       NULL,
     InterCoOut13             DECIMAL(14,2)       NULL,
     Additions1               DECIMAL(14,2)       NULL,
     Additions2               DECIMAL(14,2)       NULL,
     Additions3               DECIMAL(14,2)       NULL,
     Additions4               DECIMAL(14,2)       NULL,
     Additions5               DECIMAL(14,2)       NULL,
     Additions6               DECIMAL(14,2)       NULL,
     Additions7               DECIMAL(14,2)       NULL,
     Additions8               DECIMAL(14,2)       NULL,
     Additions9               DECIMAL(14,2)       NULL,
     Additions10              DECIMAL(14,2)       NULL,
     Additions11              DECIMAL(14,2)       NULL,
     Additions12              DECIMAL(14,2)       NULL,
     Additions13              DECIMAL(14,2)       NULL,
     Disposals1               DECIMAL(14,2)       NULL,
     Disposals2               DECIMAL(14,2)       NULL,
     Disposals3               DECIMAL(14,2)       NULL,
     Disposals4               DECIMAL(14,2)       NULL,
     Disposals5               DECIMAL(14,2)       NULL,
     Disposals6               DECIMAL(14,2)       NULL,
     Disposals7               DECIMAL(14,2)       NULL,
     Disposals8               DECIMAL(14,2)       NULL,
     Disposals9               DECIMAL(14,2)       NULL,
     Disposals10              DECIMAL(14,2)       NULL,
     Disposals11              DECIMAL(14,2)       NULL,
     Disposals12              DECIMAL(14,2)       NULL,
     Disposals13              DECIMAL(14,2)       NULL,
     DisposalCost1            DECIMAL(14,2)       NULL,
     DisposalCost2            DECIMAL(14,2)       NULL,
     DisposalCost3            DECIMAL(14,2)       NULL,
     DisposalCost4            DECIMAL(14,2)       NULL,
     DisposalCost5            DECIMAL(14,2)       NULL,
     DisposalCost6            DECIMAL(14,2)       NULL,
     DisposalCost7            DECIMAL(14,2)       NULL,
     DisposalCost8            DECIMAL(14,2)       NULL,
     DisposalCost9            DECIMAL(14,2)       NULL,
     DisposalCost10           DECIMAL(14,2)       NULL,
     DisposalCost11           DECIMAL(14,2)       NULL,
     DisposalCost12           DECIMAL(14,2)       NULL,
     DisposalCost13           DECIMAL(14,2)       NULL,
     SoldValue1               DECIMAL(14,2)       NULL,
     SoldValue2               DECIMAL(14,2)       NULL,
     SoldValue3               DECIMAL(14,2)       NULL,
     SoldValue4               DECIMAL(14,2)       NULL,
     SoldValue5               DECIMAL(14,2)       NULL,
     SoldValue6               DECIMAL(14,2)       NULL,
     SoldValue7               DECIMAL(14,2)       NULL,
     SoldValue8               DECIMAL(14,2)       NULL,
     SoldValue9               DECIMAL(14,2)       NULL,
     SoldValue10              DECIMAL(14,2)       NULL,
     SoldValue11              DECIMAL(14,2)       NULL,
     SoldValue12              DECIMAL(14,2)       NULL,
     SoldValue13              DECIMAL(14,2)       NULL,
     AssetCount1              DECIMAL(14,2)       NULL,
     AssetCount2              DECIMAL(14,2)       NULL,
     AssetCount3              DECIMAL(14,2)       NULL,
     AssetCount4              DECIMAL(14,2)       NULL,
     AssetCount5              DECIMAL(14,2)       NULL,
     AssetCount6              DECIMAL(14,2)       NULL,
     AssetCount7              DECIMAL(14,2)       NULL,
     AssetCount8              DECIMAL(14,2)       NULL,
     AssetCount9              DECIMAL(14,2)       NULL,
     AssetCount10             DECIMAL(14,2)       NULL,
     AssetCount11             DECIMAL(14,2)       NULL,
     AssetCount12             DECIMAL(14,2)       NULL,
     AssetCount13             DECIMAL(14,2)       NULL,
     AssetSplit1              DECIMAL(14,2)       NULL,
     AssetSplit2              DECIMAL(14,2)       NULL,
     AssetSplit3              DECIMAL(14,2)       NULL,
     AssetSplit4              DECIMAL(14,2)       NULL,
     AssetSplit5              DECIMAL(14,2)       NULL,
     AssetSplit6              DECIMAL(14,2)       NULL,
     AssetSplit7              DECIMAL(14,2)       NULL,
     AssetSplit8              DECIMAL(14,2)       NULL,
     AssetSplit9              DECIMAL(14,2)       NULL,
     AssetSplit10             DECIMAL(14,2)       NULL,
     AssetSplit11             DECIMAL(14,2)       NULL,
     AssetSplit12             DECIMAL(14,2)       NULL,
     AssetSplit13             DECIMAL(14,2)       NULL,
     AssetChange1             DECIMAL(14,2)       NULL,
     AssetChange2             DECIMAL(14,2)       NULL,
     AssetChange3             DECIMAL(14,2)       NULL,
     AssetChange4             DECIMAL(14,2)       NULL,
     AssetChange5             DECIMAL(14,2)       NULL,
     AssetChange6             DECIMAL(14,2)       NULL,
     AssetChange7             DECIMAL(14,2)       NULL,
     AssetChange8             DECIMAL(14,2)       NULL,
     AssetChange9             DECIMAL(14,2)       NULL,
     AssetChange10            DECIMAL(14,2)       NULL,
     AssetChange11            DECIMAL(14,2)       NULL,
     AssetChange12            DECIMAL(14,2)       NULL,
     AssetChange13            DECIMAL(14,2)       NULL,
     RevalFlag1               CHAR(1)             NULL,
     RevalFlag2               CHAR(1)             NULL,
     RevalFlag3               CHAR(1)             NULL,
     RevalFlag4               CHAR(1)             NULL,
     RevalFlag5               CHAR(1)             NULL,
     RevalFlag6               CHAR(1)             NULL,
     RevalFlag7               CHAR(1)             NULL,
     RevalFlag8               CHAR(1)             NULL,
     RevalFlag9               CHAR(1)             NULL,
     RevalFlag10              CHAR(1)             NULL,
     RevalFlag11              CHAR(1)             NULL,
     RevalFlag12              CHAR(1)             NULL,
     RevalFlag13              CHAR(1)             NULL,
     OpeningValue             DECIMAL(14,2)       NULL,
     OpeningDepnValue         DECIMAL(14,2)       NULL,
     OpeningRevDepnVal        DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetHistoryAltKey PRIMARY KEY CLUSTERED
         (
          Asset,
          AltCode,
          DepreciationYear
         )
    )
    PRINT 'New table AssetHistoryAlt'
END
GO

--  Add new 'AssetHistoryBv' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetHistoryBv') = 0
BEGIN
    CREATE TABLE AssetHistoryBv(
     Asset                    CHAR(15)            NOT NULL,
     DepreciationYear         DECIMAL(4,0)        NOT NULL,
     DepnValue1               DECIMAL(14,2)       NULL,
     DepnValue2               DECIMAL(14,2)       NULL,
     DepnValue3               DECIMAL(14,2)       NULL,
     DepnValue4               DECIMAL(14,2)       NULL,
     DepnValue5               DECIMAL(14,2)       NULL,
     DepnValue6               DECIMAL(14,2)       NULL,
     DepnValue7               DECIMAL(14,2)       NULL,
     DepnValue8               DECIMAL(14,2)       NULL,
     DepnValue9               DECIMAL(14,2)       NULL,
     DepnValue10              DECIMAL(14,2)       NULL,
     DepnValue11              DECIMAL(14,2)       NULL,
     DepnValue12              DECIMAL(14,2)       NULL,
     DepnValue13              DECIMAL(14,2)       NULL,
     DepnRevalValue1          DECIMAL(14,2)       NULL,
     DepnRevalValue2          DECIMAL(14,2)       NULL,
     DepnRevalValue3          DECIMAL(14,2)       NULL,
     DepnRevalValue4          DECIMAL(14,2)       NULL,
     DepnRevalValue5          DECIMAL(14,2)       NULL,
     DepnRevalValue6          DECIMAL(14,2)       NULL,
     DepnRevalValue7          DECIMAL(14,2)       NULL,
     DepnRevalValue8          DECIMAL(14,2)       NULL,
     DepnRevalValue9          DECIMAL(14,2)       NULL,
     DepnRevalValue10         DECIMAL(14,2)       NULL,
     DepnRevalValue11         DECIMAL(14,2)       NULL,
     DepnRevalValue12         DECIMAL(14,2)       NULL,
     DepnRevalValue13         DECIMAL(14,2)       NULL,
     DepnAdditions1           DECIMAL(14,2)       NULL,
     DepnAdditions2           DECIMAL(14,2)       NULL,
     DepnAdditions3           DECIMAL(14,2)       NULL,
     DepnAdditions4           DECIMAL(14,2)       NULL,
     DepnAdditions5           DECIMAL(14,2)       NULL,
     DepnAdditions6           DECIMAL(14,2)       NULL,
     DepnAdditions7           DECIMAL(14,2)       NULL,
     DepnAdditions8           DECIMAL(14,2)       NULL,
     DepnAdditions9           DECIMAL(14,2)       NULL,
     DepnAdditions10          DECIMAL(14,2)       NULL,
     DepnAdditions11          DECIMAL(14,2)       NULL,
     DepnAdditions12          DECIMAL(14,2)       NULL,
     DepnAdditions13          DECIMAL(14,2)       NULL,
     DepnDisposals1           DECIMAL(14,2)       NULL,
     DepnDisposals2           DECIMAL(14,2)       NULL,
     DepnDisposals3           DECIMAL(14,2)       NULL,
     DepnDisposals4           DECIMAL(14,2)       NULL,
     DepnDisposals5           DECIMAL(14,2)       NULL,
     DepnDisposals6           DECIMAL(14,2)       NULL,
     DepnDisposals7           DECIMAL(14,2)       NULL,
     DepnDisposals8           DECIMAL(14,2)       NULL,
     DepnDisposals9           DECIMAL(14,2)       NULL,
     DepnDisposals10          DECIMAL(14,2)       NULL,
     DepnDisposals11          DECIMAL(14,2)       NULL,
     DepnDisposals12          DECIMAL(14,2)       NULL,
     DepnDisposals13          DECIMAL(14,2)       NULL,
     DepnAssetCount1          DECIMAL(14,2)       NULL,
     DepnAssetCount2          DECIMAL(14,2)       NULL,
     DepnAssetCount3          DECIMAL(14,2)       NULL,
     DepnAssetCount4          DECIMAL(14,2)       NULL,
     DepnAssetCount5          DECIMAL(14,2)       NULL,
     DepnAssetCount6          DECIMAL(14,2)       NULL,
     DepnAssetCount7          DECIMAL(14,2)       NULL,
     DepnAssetCount8          DECIMAL(14,2)       NULL,
     DepnAssetCount9          DECIMAL(14,2)       NULL,
     DepnAssetCount10         DECIMAL(14,2)       NULL,
     DepnAssetCount11         DECIMAL(14,2)       NULL,
     DepnAssetCount12         DECIMAL(14,2)       NULL,
     DepnAssetCount13         DECIMAL(14,2)       NULL,
     DepnAssetSplit1          DECIMAL(14,2)       NULL,
     DepnAssetSplit2          DECIMAL(14,2)       NULL,
     DepnAssetSplit3          DECIMAL(14,2)       NULL,
     DepnAssetSplit4          DECIMAL(14,2)       NULL,
     DepnAssetSplit5          DECIMAL(14,2)       NULL,
     DepnAssetSplit6          DECIMAL(14,2)       NULL,
     DepnAssetSplit7          DECIMAL(14,2)       NULL,
     DepnAssetSplit8          DECIMAL(14,2)       NULL,
     DepnAssetSplit9          DECIMAL(14,2)       NULL,
     DepnAssetSplit10         DECIMAL(14,2)       NULL,
     DepnAssetSplit11         DECIMAL(14,2)       NULL,
     DepnAssetSplit12         DECIMAL(14,2)       NULL,
     DepnAssetSplit13         DECIMAL(14,2)       NULL,
     RevalValue1              DECIMAL(14,2)       NULL,
     RevalValue2              DECIMAL(14,2)       NULL,
     RevalValue3              DECIMAL(14,2)       NULL,
     RevalValue4              DECIMAL(14,2)       NULL,
     RevalValue5              DECIMAL(14,2)       NULL,
     RevalValue6              DECIMAL(14,2)       NULL,
     RevalValue7              DECIMAL(14,2)       NULL,
     RevalValue8              DECIMAL(14,2)       NULL,
     RevalValue9              DECIMAL(14,2)       NULL,
     RevalValue10             DECIMAL(14,2)       NULL,
     RevalValue11             DECIMAL(14,2)       NULL,
     RevalValue12             DECIMAL(14,2)       NULL,
     RevalValue13             DECIMAL(14,2)       NULL,
     InterCoIn1               DECIMAL(14,2)       NULL,
     InterCoIn2               DECIMAL(14,2)       NULL,
     InterCoIn3               DECIMAL(14,2)       NULL,
     InterCoIn4               DECIMAL(14,2)       NULL,
     InterCoIn5               DECIMAL(14,2)       NULL,
     InterCoIn6               DECIMAL(14,2)       NULL,
     InterCoIn7               DECIMAL(14,2)       NULL,
     InterCoIn8               DECIMAL(14,2)       NULL,
     InterCoIn9               DECIMAL(14,2)       NULL,
     InterCoIn10              DECIMAL(14,2)       NULL,
     InterCoIn11              DECIMAL(14,2)       NULL,
     InterCoIn12              DECIMAL(14,2)       NULL,
     InterCoIn13              DECIMAL(14,2)       NULL,
     InterCoOut1              DECIMAL(14,2)       NULL,
     InterCoOut2              DECIMAL(14,2)       NULL,
     InterCoOut3              DECIMAL(14,2)       NULL,
     InterCoOut4              DECIMAL(14,2)       NULL,
     InterCoOut5              DECIMAL(14,2)       NULL,
     InterCoOut6              DECIMAL(14,2)       NULL,
     InterCoOut7              DECIMAL(14,2)       NULL,
     InterCoOut8              DECIMAL(14,2)       NULL,
     InterCoOut9              DECIMAL(14,2)       NULL,
     InterCoOut10             DECIMAL(14,2)       NULL,
     InterCoOut11             DECIMAL(14,2)       NULL,
     InterCoOut12             DECIMAL(14,2)       NULL,
     InterCoOut13             DECIMAL(14,2)       NULL,
     Additions1               DECIMAL(14,2)       NULL,
     Additions2               DECIMAL(14,2)       NULL,
     Additions3               DECIMAL(14,2)       NULL,
     Additions4               DECIMAL(14,2)       NULL,
     Additions5               DECIMAL(14,2)       NULL,
     Additions6               DECIMAL(14,2)       NULL,
     Additions7               DECIMAL(14,2)       NULL,
     Additions8               DECIMAL(14,2)       NULL,
     Additions9               DECIMAL(14,2)       NULL,
     Additions10              DECIMAL(14,2)       NULL,
     Additions11              DECIMAL(14,2)       NULL,
     Additions12              DECIMAL(14,2)       NULL,
     Additions13              DECIMAL(14,2)       NULL,
     Disposals1               DECIMAL(14,2)       NULL,
     Disposals2               DECIMAL(14,2)       NULL,
     Disposals3               DECIMAL(14,2)       NULL,
     Disposals4               DECIMAL(14,2)       NULL,
     Disposals5               DECIMAL(14,2)       NULL,
     Disposals6               DECIMAL(14,2)       NULL,
     Disposals7               DECIMAL(14,2)       NULL,
     Disposals8               DECIMAL(14,2)       NULL,
     Disposals9               DECIMAL(14,2)       NULL,
     Disposals10              DECIMAL(14,2)       NULL,
     Disposals11              DECIMAL(14,2)       NULL,
     Disposals12              DECIMAL(14,2)       NULL,
     Disposals13              DECIMAL(14,2)       NULL,
     DisposalCost1            DECIMAL(14,2)       NULL,
     DisposalCost2            DECIMAL(14,2)       NULL,
     DisposalCost3            DECIMAL(14,2)       NULL,
     DisposalCost4            DECIMAL(14,2)       NULL,
     DisposalCost5            DECIMAL(14,2)       NULL,
     DisposalCost6            DECIMAL(14,2)       NULL,
     DisposalCost7            DECIMAL(14,2)       NULL,
     DisposalCost8            DECIMAL(14,2)       NULL,
     DisposalCost9            DECIMAL(14,2)       NULL,
     DisposalCost10           DECIMAL(14,2)       NULL,
     DisposalCost11           DECIMAL(14,2)       NULL,
     DisposalCost12           DECIMAL(14,2)       NULL,
     DisposalCost13           DECIMAL(14,2)       NULL,
     SoldValue1               DECIMAL(14,2)       NULL,
     SoldValue2               DECIMAL(14,2)       NULL,
     SoldValue3               DECIMAL(14,2)       NULL,
     SoldValue4               DECIMAL(14,2)       NULL,
     SoldValue5               DECIMAL(14,2)       NULL,
     SoldValue6               DECIMAL(14,2)       NULL,
     SoldValue7               DECIMAL(14,2)       NULL,
     SoldValue8               DECIMAL(14,2)       NULL,
     SoldValue9               DECIMAL(14,2)       NULL,
     SoldValue10              DECIMAL(14,2)       NULL,
     SoldValue11              DECIMAL(14,2)       NULL,
     SoldValue12              DECIMAL(14,2)       NULL,
     SoldValue13              DECIMAL(14,2)       NULL,
     AssetCount1              DECIMAL(14,2)       NULL,
     AssetCount2              DECIMAL(14,2)       NULL,
     AssetCount3              DECIMAL(14,2)       NULL,
     AssetCount4              DECIMAL(14,2)       NULL,
     AssetCount5              DECIMAL(14,2)       NULL,
     AssetCount6              DECIMAL(14,2)       NULL,
     AssetCount7              DECIMAL(14,2)       NULL,
     AssetCount8              DECIMAL(14,2)       NULL,
     AssetCount9              DECIMAL(14,2)       NULL,
     AssetCount10             DECIMAL(14,2)       NULL,
     AssetCount11             DECIMAL(14,2)       NULL,
     AssetCount12             DECIMAL(14,2)       NULL,
     AssetCount13             DECIMAL(14,2)       NULL,
     AssetSplit1              DECIMAL(14,2)       NULL,
     AssetSplit2              DECIMAL(14,2)       NULL,
     AssetSplit3              DECIMAL(14,2)       NULL,
     AssetSplit4              DECIMAL(14,2)       NULL,
     AssetSplit5              DECIMAL(14,2)       NULL,
     AssetSplit6              DECIMAL(14,2)       NULL,
     AssetSplit7              DECIMAL(14,2)       NULL,
     AssetSplit8              DECIMAL(14,2)       NULL,
     AssetSplit9              DECIMAL(14,2)       NULL,
     AssetSplit10             DECIMAL(14,2)       NULL,
     AssetSplit11             DECIMAL(14,2)       NULL,
     AssetSplit12             DECIMAL(14,2)       NULL,
     AssetSplit13             DECIMAL(14,2)       NULL,
     AssetChange1             DECIMAL(14,2)       NULL,
     AssetChange2             DECIMAL(14,2)       NULL,
     AssetChange3             DECIMAL(14,2)       NULL,
     AssetChange4             DECIMAL(14,2)       NULL,
     AssetChange5             DECIMAL(14,2)       NULL,
     AssetChange6             DECIMAL(14,2)       NULL,
     AssetChange7             DECIMAL(14,2)       NULL,
     AssetChange8             DECIMAL(14,2)       NULL,
     AssetChange9             DECIMAL(14,2)       NULL,
     AssetChange10            DECIMAL(14,2)       NULL,
     AssetChange11            DECIMAL(14,2)       NULL,
     AssetChange12            DECIMAL(14,2)       NULL,
     AssetChange13            DECIMAL(14,2)       NULL,
     RevalFlag1               CHAR(1)             NULL,
     RevalFlag2               CHAR(1)             NULL,
     RevalFlag3               CHAR(1)             NULL,
     RevalFlag4               CHAR(1)             NULL,
     RevalFlag5               CHAR(1)             NULL,
     RevalFlag6               CHAR(1)             NULL,
     RevalFlag7               CHAR(1)             NULL,
     RevalFlag8               CHAR(1)             NULL,
     RevalFlag9               CHAR(1)             NULL,
     RevalFlag10              CHAR(1)             NULL,
     RevalFlag11              CHAR(1)             NULL,
     RevalFlag12              CHAR(1)             NULL,
     RevalFlag13              CHAR(1)             NULL,
     OpeningValue             DECIMAL(14,2)       NULL,
     OpeningDepnValue         DECIMAL(14,2)       NULL,
     OpeningRevDepnVal        DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetHistoryBvKey PRIMARY KEY CLUSTERED
         (
          Asset,
          DepreciationYear
         )
    )
    PRINT 'New table AssetHistoryBv'
END
GO

--  Add new 'AssetHistoryQty' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetHistoryQty') = 0
BEGIN
    CREATE TABLE AssetHistoryQty(
     Asset                    CHAR(15)            NOT NULL,
     DepreciationYear         DECIMAL(4,0)        NOT NULL,
     InterCoInQty1            DECIMAL(17,5)       NULL,
     InterCoInQty2            DECIMAL(17,5)       NULL,
     InterCoInQty3            DECIMAL(17,5)       NULL,
     InterCoInQty4            DECIMAL(17,5)       NULL,
     InterCoInQty5            DECIMAL(17,5)       NULL,
     InterCoInQty6            DECIMAL(17,5)       NULL,
     InterCoInQty7            DECIMAL(17,5)       NULL,
     InterCoInQty8            DECIMAL(17,5)       NULL,
     InterCoInQty9            DECIMAL(17,5)       NULL,
     InterCoInQty10           DECIMAL(17,5)       NULL,
     InterCoInQty11           DECIMAL(17,5)       NULL,
     InterCoInQty12           DECIMAL(17,5)       NULL,
     InterCoInQty13           DECIMAL(17,5)       NULL,
     InterCoOutQty1           DECIMAL(17,5)       NULL,
     InterCoOutQty2           DECIMAL(17,5)       NULL,
     InterCoOutQty3           DECIMAL(17,5)       NULL,
     InterCoOutQty4           DECIMAL(17,5)       NULL,
     InterCoOutQty5           DECIMAL(17,5)       NULL,
     InterCoOutQty6           DECIMAL(17,5)       NULL,
     InterCoOutQty7           DECIMAL(17,5)       NULL,
     InterCoOutQty8           DECIMAL(17,5)       NULL,
     InterCoOutQty9           DECIMAL(17,5)       NULL,
     InterCoOutQty10          DECIMAL(17,5)       NULL,
     InterCoOutQty11          DECIMAL(17,5)       NULL,
     InterCoOutQty12          DECIMAL(17,5)       NULL,
     InterCoOutQty13          DECIMAL(17,5)       NULL,
     AdditionsQty1            DECIMAL(17,5)       NULL,
     AdditionsQty2            DECIMAL(17,5)       NULL,
     AdditionsQty3            DECIMAL(17,5)       NULL,
     AdditionsQty4            DECIMAL(17,5)       NULL,
     AdditionsQty5            DECIMAL(17,5)       NULL,
     AdditionsQty6            DECIMAL(17,5)       NULL,
     AdditionsQty7            DECIMAL(17,5)       NULL,
     AdditionsQty8            DECIMAL(17,5)       NULL,
     AdditionsQty9            DECIMAL(17,5)       NULL,
     AdditionsQty10           DECIMAL(17,5)       NULL,
     AdditionsQty11           DECIMAL(17,5)       NULL,
     AdditionsQty12           DECIMAL(17,5)       NULL,
     AdditionsQty13           DECIMAL(17,5)       NULL,
     DisposalsQty1            DECIMAL(17,5)       NULL,
     DisposalsQty2            DECIMAL(17,5)       NULL,
     DisposalsQty3            DECIMAL(17,5)       NULL,
     DisposalsQty4            DECIMAL(17,5)       NULL,
     DisposalsQty5            DECIMAL(17,5)       NULL,
     DisposalsQty6            DECIMAL(17,5)       NULL,
     DisposalsQty7            DECIMAL(17,5)       NULL,
     DisposalsQty8            DECIMAL(17,5)       NULL,
     DisposalsQty9            DECIMAL(17,5)       NULL,
     DisposalsQty10           DECIMAL(17,5)       NULL,
     DisposalsQty11           DECIMAL(17,5)       NULL,
     DisposalsQty12           DECIMAL(17,5)       NULL,
     DisposalsQty13           DECIMAL(17,5)       NULL,
     AssetCountQty1           DECIMAL(17,5)       NULL,
     AssetCountQty2           DECIMAL(17,5)       NULL,
     AssetCountQty3           DECIMAL(17,5)       NULL,
     AssetCountQty4           DECIMAL(17,5)       NULL,
     AssetCountQty5           DECIMAL(17,5)       NULL,
     AssetCountQty6           DECIMAL(17,5)       NULL,
     AssetCountQty7           DECIMAL(17,5)       NULL,
     AssetCountQty8           DECIMAL(17,5)       NULL,
     AssetCountQty9           DECIMAL(17,5)       NULL,
     AssetCountQty10          DECIMAL(17,5)       NULL,
     AssetCountQty11          DECIMAL(17,5)       NULL,
     AssetCountQty12          DECIMAL(17,5)       NULL,
     AssetCountQty13          DECIMAL(17,5)       NULL,
     AssetSplitQty1           DECIMAL(17,5)       NULL,
     AssetSplitQty2           DECIMAL(17,5)       NULL,
     AssetSplitQty3           DECIMAL(17,5)       NULL,
     AssetSplitQty4           DECIMAL(17,5)       NULL,
     AssetSplitQty5           DECIMAL(17,5)       NULL,
     AssetSplitQty6           DECIMAL(17,5)       NULL,
     AssetSplitQty7           DECIMAL(17,5)       NULL,
     AssetSplitQty8           DECIMAL(17,5)       NULL,
     AssetSplitQty9           DECIMAL(17,5)       NULL,
     AssetSplitQty10          DECIMAL(17,5)       NULL,
     AssetSplitQty11          DECIMAL(17,5)       NULL,
     AssetSplitQty12          DECIMAL(17,5)       NULL,
     AssetSplitQty13          DECIMAL(17,5)       NULL,
     OpeningQty               DECIMAL(17,5)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetHistoryQtyKey PRIMARY KEY CLUSTERED
         (
          Asset,
          DepreciationYear
         )
    )
    PRINT 'New table AssetHistoryQty'
END
GO

--  Add new 'AssetHistoryTax' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'AssetHistoryTax') = 0
BEGIN
    CREATE TABLE AssetHistoryTax(
     Asset                    CHAR(15)            NOT NULL,
     DepreciationYear         DECIMAL(4,0)        NOT NULL,
     DepnValue1               DECIMAL(14,2)       NULL,
     DepnValue2               DECIMAL(14,2)       NULL,
     DepnValue3               DECIMAL(14,2)       NULL,
     DepnValue4               DECIMAL(14,2)       NULL,
     DepnValue5               DECIMAL(14,2)       NULL,
     DepnValue6               DECIMAL(14,2)       NULL,
     DepnValue7               DECIMAL(14,2)       NULL,
     DepnValue8               DECIMAL(14,2)       NULL,
     DepnValue9               DECIMAL(14,2)       NULL,
     DepnValue10              DECIMAL(14,2)       NULL,
     DepnValue11              DECIMAL(14,2)       NULL,
     DepnValue12              DECIMAL(14,2)       NULL,
     DepnValue13              DECIMAL(14,2)       NULL,
     DepnRevalValue1          DECIMAL(14,2)       NULL,
     DepnRevalValue2          DECIMAL(14,2)       NULL,
     DepnRevalValue3          DECIMAL(14,2)       NULL,
     DepnRevalValue4          DECIMAL(14,2)       NULL,
     DepnRevalValue5          DECIMAL(14,2)       NULL,
     DepnRevalValue6          DECIMAL(14,2)       NULL,
     DepnRevalValue7          DECIMAL(14,2)       NULL,
     DepnRevalValue8          DECIMAL(14,2)       NULL,
     DepnRevalValue9          DECIMAL(14,2)       NULL,
     DepnRevalValue10         DECIMAL(14,2)       NULL,
     DepnRevalValue11         DECIMAL(14,2)       NULL,
     DepnRevalValue12         DECIMAL(14,2)       NULL,
     DepnRevalValue13         DECIMAL(14,2)       NULL,
     DepnAdditions1           DECIMAL(14,2)       NULL,
     DepnAdditions2           DECIMAL(14,2)       NULL,
     DepnAdditions3           DECIMAL(14,2)       NULL,
     DepnAdditions4           DECIMAL(14,2)       NULL,
     DepnAdditions5           DECIMAL(14,2)       NULL,
     DepnAdditions6           DECIMAL(14,2)       NULL,
     DepnAdditions7           DECIMAL(14,2)       NULL,
     DepnAdditions8           DECIMAL(14,2)       NULL,
     DepnAdditions9           DECIMAL(14,2)       NULL,
     DepnAdditions10          DECIMAL(14,2)       NULL,
     DepnAdditions11          DECIMAL(14,2)       NULL,
     DepnAdditions12          DECIMAL(14,2)       NULL,
     DepnAdditions13          DECIMAL(14,2)       NULL,
     DepnDisposals1           DECIMAL(14,2)       NULL,
     DepnDisposals2           DECIMAL(14,2)       NULL,
     DepnDisposals3           DECIMAL(14,2)       NULL,
     DepnDisposals4           DECIMAL(14,2)       NULL,
     DepnDisposals5           DECIMAL(14,2)       NULL,
     DepnDisposals6           DECIMAL(14,2)       NULL,
     DepnDisposals7           DECIMAL(14,2)       NULL,
     DepnDisposals8           DECIMAL(14,2)       NULL,
     DepnDisposals9           DECIMAL(14,2)       NULL,
     DepnDisposals10          DECIMAL(14,2)       NULL,
     DepnDisposals11          DECIMAL(14,2)       NULL,
     DepnDisposals12          DECIMAL(14,2)       NULL,
     DepnDisposals13          DECIMAL(14,2)       NULL,
     DepnAssetCount1          DECIMAL(14,2)       NULL,
     DepnAssetCount2          DECIMAL(14,2)       NULL,
     DepnAssetCount3          DECIMAL(14,2)       NULL,
     DepnAssetCount4          DECIMAL(14,2)       NULL,
     DepnAssetCount5          DECIMAL(14,2)       NULL,
     DepnAssetCount6          DECIMAL(14,2)       NULL,
     DepnAssetCount7          DECIMAL(14,2)       NULL,
     DepnAssetCount8          DECIMAL(14,2)       NULL,
     DepnAssetCount9          DECIMAL(14,2)       NULL,
     DepnAssetCount10         DECIMAL(14,2)       NULL,
     DepnAssetCount11         DECIMAL(14,2)       NULL,
     DepnAssetCount12         DECIMAL(14,2)       NULL,
     DepnAssetCount13         DECIMAL(14,2)       NULL,
     DepnAssetSplit1          DECIMAL(14,2)       NULL,
     DepnAssetSplit2          DECIMAL(14,2)       NULL,
     DepnAssetSplit3          DECIMAL(14,2)       NULL,
     DepnAssetSplit4          DECIMAL(14,2)       NULL,
     DepnAssetSplit5          DECIMAL(14,2)       NULL,
     DepnAssetSplit6          DECIMAL(14,2)       NULL,
     DepnAssetSplit7          DECIMAL(14,2)       NULL,
     DepnAssetSplit8          DECIMAL(14,2)       NULL,
     DepnAssetSplit9          DECIMAL(14,2)       NULL,
     DepnAssetSplit10         DECIMAL(14,2)       NULL,
     DepnAssetSplit11         DECIMAL(14,2)       NULL,
     DepnAssetSplit12         DECIMAL(14,2)       NULL,
     DepnAssetSplit13         DECIMAL(14,2)       NULL,
     RevalValue1              DECIMAL(14,2)       NULL,
     RevalValue2              DECIMAL(14,2)       NULL,
     RevalValue3              DECIMAL(14,2)       NULL,
     RevalValue4              DECIMAL(14,2)       NULL,
     RevalValue5              DECIMAL(14,2)       NULL,
     RevalValue6              DECIMAL(14,2)       NULL,
     RevalValue7              DECIMAL(14,2)       NULL,
     RevalValue8              DECIMAL(14,2)       NULL,
     RevalValue9              DECIMAL(14,2)       NULL,
     RevalValue10             DECIMAL(14,2)       NULL,
     RevalValue11             DECIMAL(14,2)       NULL,
     RevalValue12             DECIMAL(14,2)       NULL,
     RevalValue13             DECIMAL(14,2)       NULL,
     InterCoIn1               DECIMAL(14,2)       NULL,
     InterCoIn2               DECIMAL(14,2)       NULL,
     InterCoIn3               DECIMAL(14,2)       NULL,
     InterCoIn4               DECIMAL(14,2)       NULL,
     InterCoIn5               DECIMAL(14,2)       NULL,
     InterCoIn6               DECIMAL(14,2)       NULL,
     InterCoIn7               DECIMAL(14,2)       NULL,
     InterCoIn8               DECIMAL(14,2)       NULL,
     InterCoIn9               DECIMAL(14,2)       NULL,
     InterCoIn10              DECIMAL(14,2)       NULL,
     InterCoIn11              DECIMAL(14,2)       NULL,
     InterCoIn12              DECIMAL(14,2)       NULL,
     InterCoIn13              DECIMAL(14,2)       NULL,
     InterCoOut1              DECIMAL(14,2)       NULL,
     InterCoOut2              DECIMAL(14,2)       NULL,
     InterCoOut3              DECIMAL(14,2)       NULL,
     InterCoOut4              DECIMAL(14,2)       NULL,
     InterCoOut5              DECIMAL(14,2)       NULL,
     InterCoOut6              DECIMAL(14,2)       NULL,
     InterCoOut7              DECIMAL(14,2)       NULL,
     InterCoOut8              DECIMAL(14,2)       NULL,
     InterCoOut9              DECIMAL(14,2)       NULL,
     InterCoOut10             DECIMAL(14,2)       NULL,
     InterCoOut11             DECIMAL(14,2)       NULL,
     InterCoOut12             DECIMAL(14,2)       NULL,
     InterCoOut13             DECIMAL(14,2)       NULL,
     Additions1               DECIMAL(14,2)       NULL,
     Additions2               DECIMAL(14,2)       NULL,
     Additions3               DECIMAL(14,2)       NULL,
     Additions4               DECIMAL(14,2)       NULL,
     Additions5               DECIMAL(14,2)       NULL,
     Additions6               DECIMAL(14,2)       NULL,
     Additions7               DECIMAL(14,2)       NULL,
     Additions8               DECIMAL(14,2)       NULL,
     Additions9               DECIMAL(14,2)       NULL,
     Additions10              DECIMAL(14,2)       NULL,
     Additions11              DECIMAL(14,2)       NULL,
     Additions12              DECIMAL(14,2)       NULL,
     Additions13              DECIMAL(14,2)       NULL,
     Disposals1               DECIMAL(14,2)       NULL,
     Disposals2               DECIMAL(14,2)       NULL,
     Disposals3               DECIMAL(14,2)       NULL,
     Disposals4               DECIMAL(14,2)       NULL,
     Disposals5               DECIMAL(14,2)       NULL,
     Disposals6               DECIMAL(14,2)       NULL,
     Disposals7               DECIMAL(14,2)       NULL,
     Disposals8               DECIMAL(14,2)       NULL,
     Disposals9               DECIMAL(14,2)       NULL,
     Disposals10              DECIMAL(14,2)       NULL,
     Disposals11              DECIMAL(14,2)       NULL,
     Disposals12              DECIMAL(14,2)       NULL,
     Disposals13              DECIMAL(14,2)       NULL,
     DisposalCost1            DECIMAL(14,2)       NULL,
     DisposalCost2            DECIMAL(14,2)       NULL,
     DisposalCost3            DECIMAL(14,2)       NULL,
     DisposalCost4            DECIMAL(14,2)       NULL,
     DisposalCost5            DECIMAL(14,2)       NULL,
     DisposalCost6            DECIMAL(14,2)       NULL,
     DisposalCost7            DECIMAL(14,2)       NULL,
     DisposalCost8            DECIMAL(14,2)       NULL,
     DisposalCost9            DECIMAL(14,2)       NULL,
     DisposalCost10           DECIMAL(14,2)       NULL,
     DisposalCost11           DECIMAL(14,2)       NULL,
     DisposalCost12           DECIMAL(14,2)       NULL,
     DisposalCost13           DECIMAL(14,2)       NULL,
     SoldValue1               DECIMAL(14,2)       NULL,
     SoldValue2               DECIMAL(14,2)       NULL,
     SoldValue3               DECIMAL(14,2)       NULL,
     SoldValue4               DECIMAL(14,2)       NULL,
     SoldValue5               DECIMAL(14,2)       NULL,
     SoldValue6               DECIMAL(14,2)       NULL,
     SoldValue7               DECIMAL(14,2)       NULL,
     SoldValue8               DECIMAL(14,2)       NULL,
     SoldValue9               DECIMAL(14,2)       NULL,
     SoldValue10              DECIMAL(14,2)       NULL,
     SoldValue11              DECIMAL(14,2)       NULL,
     SoldValue12              DECIMAL(14,2)       NULL,
     SoldValue13              DECIMAL(14,2)       NULL,
     AssetCount1              DECIMAL(14,2)       NULL,
     AssetCount2              DECIMAL(14,2)       NULL,
     AssetCount3              DECIMAL(14,2)       NULL,
     AssetCount4              DECIMAL(14,2)       NULL,
     AssetCount5              DECIMAL(14,2)       NULL,
     AssetCount6              DECIMAL(14,2)       NULL,
     AssetCount7              DECIMAL(14,2)       NULL,
     AssetCount8              DECIMAL(14,2)       NULL,
     AssetCount9              DECIMAL(14,2)       NULL,
     AssetCount10             DECIMAL(14,2)       NULL,
     AssetCount11             DECIMAL(14,2)       NULL,
     AssetCount12             DECIMAL(14,2)       NULL,
     AssetCount13             DECIMAL(14,2)       NULL,
     AssetSplit1              DECIMAL(14,2)       NULL,
     AssetSplit2              DECIMAL(14,2)       NULL,
     AssetSplit3              DECIMAL(14,2)       NULL,
     AssetSplit4              DECIMAL(14,2)       NULL,
     AssetSplit5              DECIMAL(14,2)       NULL,
     AssetSplit6              DECIMAL(14,2)       NULL,
     AssetSplit7              DECIMAL(14,2)       NULL,
     AssetSplit8              DECIMAL(14,2)       NULL,
     AssetSplit9              DECIMAL(14,2)       NULL,
     AssetSplit10             DECIMAL(14,2)       NULL,
     AssetSplit11             DECIMAL(14,2)       NULL,
     AssetSplit12             DECIMAL(14,2)       NULL,
     AssetSplit13             DECIMAL(14,2)       NULL,
     AssetChange1             DECIMAL(14,2)       NULL,
     AssetChange2             DECIMAL(14,2)       NULL,
     AssetChange3             DECIMAL(14,2)       NULL,
     AssetChange4             DECIMAL(14,2)       NULL,
     AssetChange5             DECIMAL(14,2)       NULL,
     AssetChange6             DECIMAL(14,2)       NULL,
     AssetChange7             DECIMAL(14,2)       NULL,
     AssetChange8             DECIMAL(14,2)       NULL,
     AssetChange9             DECIMAL(14,2)       NULL,
     AssetChange10            DECIMAL(14,2)       NULL,
     AssetChange11            DECIMAL(14,2)       NULL,
     AssetChange12            DECIMAL(14,2)       NULL,
     AssetChange13            DECIMAL(14,2)       NULL,
     RevalFlag1               CHAR(1)             NULL,
     RevalFlag2               CHAR(1)             NULL,
     RevalFlag3               CHAR(1)             NULL,
     RevalFlag4               CHAR(1)             NULL,
     RevalFlag5               CHAR(1)             NULL,
     RevalFlag6               CHAR(1)             NULL,
     RevalFlag7               CHAR(1)             NULL,
     RevalFlag8               CHAR(1)             NULL,
     RevalFlag9               CHAR(1)             NULL,
     RevalFlag10              CHAR(1)             NULL,
     RevalFlag11              CHAR(1)             NULL,
     RevalFlag12              CHAR(1)             NULL,
     RevalFlag13              CHAR(1)             NULL,
     OpeningValue             DECIMAL(14,2)       NULL,
     OpeningDepnValue         DECIMAL(14,2)       NULL,
     OpeningRevDepnVal        DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT AssetHistoryTaxKey PRIMARY KEY CLUSTERED
         (
          Asset,
          DepreciationYear
         )
    )
    PRINT 'New table AssetHistoryTax'
END
GO

--  Add new 'BomSchedGroupDet' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'BomSchedGroupDet') = 0
BEGIN
    CREATE TABLE BomSchedGroupDet(
     SchedulingGroup          CHAR(10)            NOT NULL,
     EntityIdentifier         CHAR(2)             NOT NULL,
     Entity                   CHAR(50)            NOT NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT BomSchedGroupDetKey PRIMARY KEY CLUSTERED
         (
          SchedulingGroup,
          EntityIdentifier,
          Entity
         )
    )
    CREATE UNIQUE INDEX BomSchedGroupDetIdxEntId ON BomSchedGroupDet(
     EntityIdentifier,
     Entity,
     SchedulingGroup
     )
    PRINT 'New table BomSchedGroupDet'
END
GO

--  Add new 'BomSchedGroup' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'BomSchedGroup') = 0
BEGIN
    CREATE TABLE BomSchedGroup(
     SchedulingGroup          CHAR(10)            NOT NULL,
     Description              CHAR(50)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT BomSchedGroupKey PRIMARY KEY CLUSTERED
         (
          SchedulingGroup
         )
    )
    PRINT 'New table BomSchedGroup'
END
GO

--  Add new 'CshFlowCollector' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CshFlowCollector') = 0
BEGIN
    CREATE TABLE CshFlowCollector(
     Model                    CHAR(10)            NOT NULL,
     Collector                DECIMAL(3,0)        NOT NULL,
     Description              CHAR(50)            NULL,
     Sequence                 DECIMAL(3,0)        NULL,
     CollectorType            CHAR(1)             NULL,
     UpdateDate               DATETIME            NULL,
     UpdateTime               DECIMAL(8,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT CshFlowCollectorKey PRIMARY KEY CLUSTERED
         (
          Model,
          Collector
         )
    )
    PRINT 'New table CshFlowCollector'
END
GO

--  Add new 'CshFlowProjDates' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CshFlowProjDates') = 0
BEGIN
    CREATE TABLE CshFlowProjDates(
     Model                    CHAR(10)            NOT NULL,
     ProjectionDate           DATETIME            NOT NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT CshFlowProjDatesKey PRIMARY KEY CLUSTERED
         (
          Model,
          ProjectionDate
         )
    )
    PRINT 'New table CshFlowProjDates'
END
GO

--  Add new 'CshFlowDetails' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CshFlowDetails') = 0
BEGIN
    CREATE TABLE CshFlowDetails(
     Model                    CHAR(10)            NOT NULL,
     InclusionType            CHAR(3)             NOT NULL,
     Line                     DECIMAL(7,0)        NOT NULL,
     Collector                DECIMAL(3,0)        NULL,
     Inclusion                DECIMAL(3,0)        NULL,
     Identifier               CHAR(45)            NULL,
     Description              CHAR(60)            NULL,
     Value1                   DECIMAL(14,2)       NULL,
     Value2                   DECIMAL(14,2)       NULL,
     Value3                   DECIMAL(14,2)       NULL,
     Value4                   DECIMAL(14,2)       NULL,
     Value5                   DECIMAL(14,2)       NULL,
     Value6                   DECIMAL(14,2)       NULL,
     Value7                   DECIMAL(14,2)       NULL,
     Value8                   DECIMAL(14,2)       NULL,
     Value9                   DECIMAL(14,2)       NULL,
     Value10                  DECIMAL(14,2)       NULL,
     Value11                  DECIMAL(14,2)       NULL,
     Value12                  DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT CshFlowDetailsKey PRIMARY KEY CLUSTERED
         (
          Model,
          InclusionType,
          Line
         )
    )
    PRINT 'New table CshFlowDetails'
END
GO

--  Add new 'CshFlowInclusion' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CshFlowInclusion') = 0
BEGIN
    CREATE TABLE CshFlowInclusion(
     Model                    CHAR(10)            NOT NULL,
     Collector                DECIMAL(3,0)        NOT NULL,
     Inclusion                DECIMAL(3,0)        NOT NULL,
     InclusionType            CHAR(3)             NULL,
     Prompt                   CHAR(20)            NULL,
     CurrencyAllSgl           CHAR(1)             NULL,
     Currency                 CHAR(3)             NULL,
     BankAllSgl               CHAR(1)             NULL,
     Bank                     CHAR(2)             NULL,
     GlCodeAllSgl             CHAR(1)             NULL,
     FromGlCode               CHAR(15)            NULL,
     ToGlCode                 CHAR(15)            NULL,
     GlGroupAllSgl            CHAR(1)             NULL,
     GlGroup                  CHAR(2)             NULL,
     GlAsset                  CHAR(1)             NULL,
     GlLiability              CHAR(1)             NULL,
     GlRevenue                CHAR(1)             NULL,
     GlExpense                CHAR(1)             NULL,
     GlCapital                CHAR(1)             NULL,
     BranchAllSgl             CHAR(1)             NULL,
     Branch                   CHAR(2)             NULL,
     AreaAllSgl               CHAR(1)             NULL,
     Area                     CHAR(2)             NULL,
     ApDiscount               CHAR(1)             NULL,
     FromPeriod               DECIMAL(2,0)        NULL,
     ToPeriod                 DECIMAL(2,0)        NULL,
     OffsetDays               DECIMAL(3,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT CshFlowInclusionKey PRIMARY KEY CLUSTERED
         (
          Model,
          Collector,
          Inclusion
         )
    )
    PRINT 'New table CshFlowInclusion'
END
GO

--  Add new 'CshFlowModel' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CshFlowModel') = 0
BEGIN
    CREATE TABLE CshFlowModel(
     Model                    CHAR(10)            NOT NULL,
     Description              CHAR(50)            NULL,
     Currency                 CHAR(3)             NULL,
     ConvertToLocal           CHAR(1)             NULL,
     CurBudget                CHAR(1)             NULL,
     CurBudgetNo              DECIMAL(3,0)        NULL,
     NextBudget               CHAR(1)             NULL,
     NextBudgetNo             DECIMAL(3,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT CshFlowModelKey PRIMARY KEY CLUSTERED
         (
          Model
         )
    )
    PRINT 'New table CshFlowModel'
END
GO

--  Add new 'CshFlowValues' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'CshFlowValues') = 0
BEGIN
    CREATE TABLE CshFlowValues(
     Model                    CHAR(10)            NOT NULL,
     Collector                DECIMAL(3,0)        NOT NULL,
     Inclusion                DECIMAL(3,0)        NOT NULL,
     Value1                   DECIMAL(14,2)       NULL,
     Value2                   DECIMAL(14,2)       NULL,
     Value3                   DECIMAL(14,2)       NULL,
     Value4                   DECIMAL(14,2)       NULL,
     Value5                   DECIMAL(14,2)       NULL,
     Value6                   DECIMAL(14,2)       NULL,
     Value7                   DECIMAL(14,2)       NULL,
     Value8                   DECIMAL(14,2)       NULL,
     Value9                   DECIMAL(14,2)       NULL,
     Value10                  DECIMAL(14,2)       NULL,
     Value11                  DECIMAL(14,2)       NULL,
     Value12                  DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT CshFlowValuesKey PRIMARY KEY CLUSTERED
         (
          Model,
          Collector,
          Inclusion
         )
    )
    PRINT 'New table CshFlowValues'
END
GO

--  Add new 'GenJnlTempSplit' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'GenJnlTempSplit') = 0
BEGIN
    CREATE TABLE GenJnlTempSplit(
     GlYear                   DECIMAL(4,0)        NOT NULL,
     GlPeriod                 DECIMAL(2,0)        NOT NULL,
     Journal                  DECIMAL(5,0)        NOT NULL,
     EntryNumber              DECIMAL(5,0)        NOT NULL,
     TemplateLineNo           DECIMAL(5,0)        NOT NULL,
     GlCode                   CHAR(15)            NULL,
     EntryValue               DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT GenJnlTempSplitKey PRIMARY KEY CLUSTERED
         (
          GlYear,
          GlPeriod,
          Journal,
          EntryNumber,
          TemplateLineNo
         )
    )
    PRINT 'New table GenJnlTempSplit'
END
GO

--  Add new 'GenShares' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'GenShares') = 0
BEGIN
    CREATE TABLE GenShares(
     Company                  CHAR(1)             NOT NULL,
     DateSharesChange         DATETIME            NOT NULL,
     ShareQty                 DECIMAL(9,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT GenSharesKey PRIMARY KEY CLUSTERED
         (
          Company,
          DateSharesChange
         )
    )
    PRINT 'New table GenShares'
END
GO

--  Add new 'InvDocument' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvDocument') = 0
BEGIN
    CREATE TABLE InvDocument(
     TransactionType          CHAR(1)             NOT NULL,
     KeyWarehouse             CHAR(2)             NOT NULL,
     KeyBin                   CHAR(6)             NOT NULL,
     Reference                CHAR(9)             NOT NULL,
     KeyPurchaseOrder         CHAR(6)             NOT NULL,
     KeyPurchaseOrdLine       DECIMAL(4,0)        NOT NULL,
     JnlYear                  DECIMAL(4,0)        NOT NULL,
     JnlMonth                 DECIMAL(2,0)        NOT NULL,
     Journal                  DECIMAL(5,0)        NOT NULL,
     EntryNumber              DECIMAL(5,0)        NOT NULL,
     TransferWarehouse        CHAR(2)             NULL,
     TransferBin              CHAR(6)             NULL,
     GtrReference             CHAR(9)             NULL,
     IssueWarehouse           CHAR(2)             NULL,
     Grn                      CHAR(9)             NULL,
     PurchaseOrder            CHAR(6)             NULL,
     PurchaseOrderLin         DECIMAL(4,0)        NULL,
     ReceiptWarehouse         CHAR(2)             NULL,
     ReceiptBin               CHAR(6)             NULL,
     Document                 CHAR(9)             NULL,
     Operator                 CHAR(6)             NULL,
     Supplier                 CHAR(7)             NULL,
     SupplierName             CHAR(30)            NULL,
     StockCode                CHAR(30)            NULL,
     Description              CHAR(30)            NULL,
     LongDescription          CHAR(30)            NULL,
     StockUom                 CHAR(3)             NULL,
     ProductClass             CHAR(4)             NULL,
     TransQuantity            DECIMAL(10,3)       NULL,
     TransValue               DECIMAL(14,2)       NULL,
     TransUnitCost            DECIMAL(15,5)       NULL,
     TransMass                DECIMAL(14,6)       NULL,
     TransVolume              DECIMAL(14,6)       NULL,
     TransDate                DATETIME            NULL,
     TransWarehouse           CHAR(2)             NULL,
     TransReference           CHAR(9)             NULL,
     TransAddRef              CHAR(30)            NULL,
     Notation                 CHAR(45)            NULL,
     OrderDuedate             DATETIME            NULL,
     LineDuedate              DATETIME            NULL,
     OrderQuantity            DECIMAL(10,3)       NULL,
     OutOrderQty              DECIMAL(10,3)       NULL,
     OrderValueMerch          DECIMAL(14,2)       NULL,
     OrderValueNonMerch       DECIMAL(14,2)       NULL,
     GlCode                   CHAR(15)            NULL,
     GlCodeDebit              CHAR(15)            NULL,
     GrnSource                CHAR(1)             NULL,
     Bin                      CHAR(6)             NULL,
     Job                      CHAR(8)             NULL,
     Lot                      CHAR(10)            NULL,
     Tariff                   CHAR(15)            NULL,
     Requisition              CHAR(10)            NULL,
     Line                     DECIMAL(3,0)        NULL,
     Originator               CHAR(3)             NULL,
     Decimals                 DECIMAL(1,0)        NULL,
     RejectScrapCode          CHAR(2)             NULL,
     StockedFlag              CHAR(1)             NULL,
     PrintedFlag              CHAR(1)             NULL,
     SerialMethod             CHAR(1)             NULL,
     DeliveryNote             CHAR(15)            NULL,
     GtrLine                  DECIMAL(5,0)        NULL,
     LeadTime                 DECIMAL(3,0)        NULL,
     Concession               CHAR(10)            NULL,
     MovtStockCode            CHAR(30)            NULL,
     MovtWarehouse            CHAR(2)             NULL,
     MovtPostYear             DECIMAL(4,0)        NULL,
     MovtPostMonth            DECIMAL(2,0)        NULL,
     MovtDate                 DATETIME            NULL,
     MovtTime                 DECIMAL(8,0)        NULL,
     MovtType                 CHAR(1)             NULL,
     ExchangeRate             DECIMAL(12,6)       NULL,
     MulDiv                   CHAR(1)             NULL,
     Currency                 CHAR(3)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvDocumentKey PRIMARY KEY CLUSTERED
         (
          TransactionType,
          KeyWarehouse,
          KeyBin,
          Reference,
          KeyPurchaseOrder,
          KeyPurchaseOrdLine,
          JnlYear,
          JnlMonth,
          Journal,
          EntryNumber
         )
    )
    PRINT 'New table InvDocument'
END
GO

--  Add new 'InvInspectDoc' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvInspectDoc') = 0
BEGIN
    CREATE TABLE InvInspectDoc(
     TransactionType          CHAR(1)             NOT NULL,
     DocumentNum              DECIMAL(9,0)        NOT NULL,
     Grn                      CHAR(9)             NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     Lot                      CHAR(10)            NULL,
     ReprintFlag              CHAR(1)             NULL,
     Version                  CHAR(3)             NULL,
     Release                  CHAR(3)             NULL,
     StockCode                CHAR(30)            NULL,
     PurchaseOrder            CHAR(6)             NULL,
     Line                     DECIMAL(4,0)        NULL,
     Supplier                 CHAR(7)             NULL,
     Job                      CHAR(8)             NULL,
     RejectCode               CHAR(2)             NULL,
     TransactionDate          DATETIME            NULL,
     Quantity                 DECIMAL(10,3)       NULL,
     DeliveryNote             CHAR(15)            NULL,
     DeliveryNoteDate         DATETIME            NULL,
     Certificate              CHAR(10)            NULL,
     ExpiryDate               DATETIME            NULL,
     OrigDueDate              DATETIME            NULL,
     LatestDueDate            DATETIME            NULL,
     Bin                      CHAR(6)             NULL,
     Notation                 CHAR(60)            NULL,
     TrnDocument              CHAR(10)            NULL,
     Description              CHAR(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvInspectDocKey PRIMARY KEY CLUSTERED
         (
          TransactionType,
          DocumentNum,
          Grn,
          Warehouse
         )
    )
    PRINT 'New table InvInspectDoc'
END
GO

--  Add new 'InvDocumentSerial' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvDocumentSerial') = 0
BEGIN
    CREATE TABLE InvDocumentSerial(
     TransactionType          CHAR(1)             NOT NULL,
     KeyWarehouse             CHAR(2)             NOT NULL,
     KeyBin                   CHAR(6)             NOT NULL,
     Reference                CHAR(9)             NOT NULL,
     KeyPurchaseOrder         CHAR(6)             NOT NULL,
     KeyPurchaseOrdLine       DECIMAL(4,0)        NOT NULL,
     JnlYear                  DECIMAL(4,0)        NOT NULL,
     JnlMonth                 DECIMAL(2,0)        NOT NULL,
     Journal                  DECIMAL(5,0)        NOT NULL,
     EntryNumber              DECIMAL(5,0)        NOT NULL,
     Serial                   CHAR(20)            NOT NULL,
     Quantity                 DECIMAL(10,3)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvDocumentSerialKey PRIMARY KEY CLUSTERED
         (
          TransactionType,
          KeyWarehouse,
          KeyBin,
          Reference,
          KeyPurchaseOrder,
          KeyPurchaseOrdLine,
          JnlYear,
          JnlMonth,
          Journal,
          EntryNumber,
          Serial
         )
    )
    PRINT 'New table InvDocumentSerial'
END
GO

--  Add new 'InvInspectDocSer' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvInspectDocSer') = 0
BEGIN
    CREATE TABLE InvInspectDocSer(
     TransactionType          CHAR(1)             NOT NULL,
     DocumentNum              DECIMAL(9,0)        NOT NULL,
     Grn                      CHAR(9)             NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     Serial                   CHAR(20)            NOT NULL,
     Quantity                 DECIMAL(10,3)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvInspectDocSerKey PRIMARY KEY CLUSTERED
         (
          TransactionType,
          DocumentNum,
          Grn,
          Warehouse,
          Serial
         )
    )
    PRINT 'New table InvInspectDocSer'
END
GO

--  Add new 'InvMasterUom' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvMasterUom') = 0
BEGIN
    CREATE TABLE InvMasterUom(
     StockCode                CHAR(30)            NOT NULL,
     UomCode                  CHAR(20)            NOT NULL,
     StockUnitsPerUom         CHAR(20)            NULL,
     ConvFact                 DECIMAL(10,6)       NULL,
     MulDiv                   CHAR(1)             NULL,
     Barcode                  CHAR(30)            NULL,
     Rfid                     CHAR(60)            NULL,
     DimensionUnit            CHAR(20)            NULL,
     PhysicalLength           DECIMAL(12,6)       NULL,
     PhysicalWidth            DECIMAL(12,6)       NULL,
     PhysicalHeight           DECIMAL(12,6)       NULL,
     MassUnit                 CHAR(20)            NULL,
     Mass                     DECIMAL(12,6)       NULL,
     VolumeUnit               CHAR(20)            NULL,
     Volume                   DECIMAL(12,6)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvMasterUomKey PRIMARY KEY CLUSTERED
         (
          StockCode,
          UomCode
         )
    )
    CREATE UNIQUE INDEX InvMasterUomIdxBarcode ON InvMasterUom(
     Barcode,
     StockCode,
     UomCode
     )
    CREATE UNIQUE INDEX InvMasterUomIdxRfid ON InvMasterUom(
     Rfid,
     StockCode,
     UomCode
     )
    PRINT 'New table InvMasterUom'
END
GO

--  Add new 'InvPhysicalUnit' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvPhysicalUnit') = 0
BEGIN
    CREATE TABLE InvPhysicalUnit(
     PhysicalUnit             CHAR(20)            NOT NULL,
     Description              CHAR(60)            NULL,
     UnitGroup                CHAR(1)             NULL,
     UnitType                 CHAR(1)             NULL,
     BaseCode                 CHAR(20)            NULL,
     BaseConvFact             DECIMAL(15,6)       NULL,
     BaseMulDiv               CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvPhysicalUnitKey PRIMARY KEY CLUSTERED
         (
          PhysicalUnit
         )
    )
    CREATE UNIQUE INDEX InvPhysicalUnitIdxGroupTyp ON InvPhysicalUnit(
     UnitGroup,
     UnitType,
     PhysicalUnit
     )
    PRINT 'New table InvPhysicalUnit'
END
GO

--  Add new 'InvSite' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvSite') = 0
BEGIN
    CREATE TABLE InvSite(
     SiteId                   CHAR(20)            NOT NULL,
     SiteType                 CHAR(20)            NULL,
     Description              CHAR(30)            NULL,
     SiteIdParent             CHAR(20)            NULL,
     AllocResolveDays         DECIMAL(3,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvSiteKey PRIMARY KEY CLUSTERED
         (
          SiteId
         )
    )
    CREATE UNIQUE INDEX InvSiteIdxParentSi ON InvSite(
     SiteIdParent,
     SiteId
     )
    PRINT 'New table InvSite'
END
GO

--  Add new 'InvSiteType' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvSiteType') = 0
BEGIN
    CREATE TABLE InvSiteType(
     SiteType                 CHAR(20)            NOT NULL,
     Description              CHAR(30)            NULL,
     SiteTypeParent           CHAR(20)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvSiteTypeKey PRIMARY KEY CLUSTERED
         (
          SiteType
         )
    )
    PRINT 'New table InvSiteType'
END
GO

--  Add new 'InvUom' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvUom') = 0
BEGIN
    CREATE TABLE InvUom(
     UomCode                  CHAR(20)            NOT NULL,
     Description              CHAR(60)            NULL,
     UomRank                  DECIMAL(3,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvUomKey PRIMARY KEY CLUSTERED
         (
          UomCode
         )
    )
    CREATE UNIQUE INDEX InvUomIdxRank ON InvUom(
     UomRank,
     UomCode
     )
    PRINT 'New table InvUom'
END
GO

--  Add new 'InvWhArea' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvWhArea') = 0
BEGIN
    CREATE TABLE InvWhArea(
     WhArea                   CHAR(20)            NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     Description              CHAR(60)            NULL,
     BinFormat                CHAR(60)            NULL,
     WidthTag                 CHAR(20)            NULL,
     LengthTag                CHAR(20)            NULL,
     BinCount                 DECIMAL(6,0)        NULL,
     GroupOps                 CHAR(20)            NULL,
     BinPickStrategy          CHAR(10)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvWhAreaKey PRIMARY KEY CLUSTERED
         (
          WhArea,
          Warehouse
         )
    )
    PRINT 'New table InvWhArea'
END
GO

--  Add new 'InvWhBin' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'InvWhBin') = 0
BEGIN
    CREATE TABLE InvWhBin(
     Warehouse                CHAR(2)             NOT NULL,
     Bin                      CHAR(6)             NOT NULL,
     BinSeq                   DECIMAL(6,0)        NULL,
     WhArea                   CHAR(20)            NULL,
     BinType                  CHAR(20)            NULL,
     BinBarcode               CHAR(30)            NULL,
     BinRfid                  CHAR(60)            NULL,
     ReservedStockCode        CHAR(30)            NULL,
     BinOnHold                CHAR(1)             NULL,
     OnHoldReason             CHAR(40)            NULL,
     ActiveCycleCount         CHAR(1)             NULL,
     AllowReplenish           CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT InvWhBinKey PRIMARY KEY CLUSTERED
         (
          Warehouse,
          Bin
         )
    )
    CREATE UNIQUE INDEX InvWhBinIdxBarcode ON InvWhBin(
     BinBarcode,
     Warehouse,
     Bin
     )
    CREATE UNIQUE INDEX InvWhBinIdxBinSeq ON InvWhBin(
     Warehouse,
     WhArea,
     BinSeq,
     Bin
     )
    CREATE UNIQUE INDEX InvWhBinIdxRfid ON InvWhBin(
     BinRfid,
     Warehouse,
     Bin
     )
    CREATE UNIQUE INDEX InvWhBinIdxResStock ON InvWhBin(
     ReservedStockCode,
     Warehouse,
     WhArea,
     Bin
     )
    CREATE UNIQUE INDEX InvWhBinIdxResArea ON InvWhBin(
     Warehouse,
     WhArea,
     ReservedStockCode,
     Bin
     )
    PRINT 'New table InvWhBin'
END
GO

--  Add new 'IopDeliveryPerf' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopDeliveryPerf') = 0
BEGIN
    CREATE TABLE IopDeliveryPerf(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     SupplyType               CHAR(1)             NOT NULL,
     SupplySource             CHAR(7)             NOT NULL,
     DeliveryMethod           CHAR(10)            NOT NULL,
     RunDate                  DATETIME            NOT NULL,
     Company                  CHAR(1)             NOT NULL,
     Warehouse                CHAR(2)             NULL,
     NewOrders                DECIMAL(7,0)        NULL,
     NewQuantity              DECIMAL(10,3)       NULL,
     NewValue                 DECIMAL(14,2)       NULL,
     ReceivedOrders           DECIMAL(7,0)        NULL,
     ReceivedQuantity         DECIMAL(10,3)       NULL,
     ReceivedValue            DECIMAL(14,2)       NULL,
     CurrentOrders            DECIMAL(7,0)        NULL,
     CurrentQuantity          DECIMAL(10,3)       NULL,
     CurrentValue             DECIMAL(14,2)       NULL,
     OverdueOrders            DECIMAL(7,0)        NULL,
     OverdueValue             DECIMAL(14,2)       NULL,
     OverDueQuantity          DECIMAL(10,3)       NULL,
     OverDueDays              DECIMAL(7,0)        NULL,
     OnTimeOrders             DECIMAL(7,0)        NULL,
     OnTimeQuantity           DECIMAL(10,3)       NULL,
     OnTimeValue              DECIMAL(14,2)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopDeliveryPerfKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          SupplyType,
          SupplySource,
          DeliveryMethod,
          RunDate,
          Company
         )
    )
    CREATE UNIQUE INDEX IopDeliveryPerfIdxWh ON IopDeliveryPerf(
     Warehouse,
     SupplyType,
     SupplySource,
     DeliveryMethod,
     RunDate,
     IdNumber,
     Company
     )
    PRINT 'New table IopDeliveryPerf'
END
GO

--  Add new 'IopForeSnapshot' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopForeSnapshot') = 0
BEGIN
    CREATE TABLE IopForeSnapshot(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     DatePrepared             DATETIME            NOT NULL,
     ForecastDate             DATETIME            NOT NULL,
     ForecastQty              DECIMAL(10,3)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopForeSnapshotKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          DatePrepared,
          ForecastDate
         )
    )
    PRINT 'New table IopForeSnapshot'
END
GO

--  Add new 'IopForeSnapHead' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopForeSnapHead') = 0
BEGIN
    CREATE TABLE IopForeSnapHead(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     DateCreated              DATETIME            NOT NULL,
     Operator                 CHAR(6)             NULL,
     Reference                CHAR(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopForeSnapHeadKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          DateCreated
         )
    )
    PRINT 'New table IopForeSnapHead'
END
GO

--  Add new 'IopSelectionList' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopSelectionList') = 0
BEGIN
    CREATE TABLE IopSelectionList(
     SelectionSet             CHAR(10)            NOT NULL,
     ListType                 CHAR(1)             NOT NULL,
     ListEntry                CHAR(30)            NOT NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopSelectionListKey PRIMARY KEY CLUSTERED
         (
          SelectionSet,
          ListType,
          ListEntry
         )
    )
    PRINT 'New table IopSelectionList'
END
GO

--  Add new 'IopArchiveStockLvl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopArchiveStockLvl') = 0
BEGIN
    CREATE TABLE IopArchiveStockLvl(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     ArchiveDate              DATETIME            NOT NULL,
     ArchiveNumber            DECIMAL(4,0)        NOT NULL,
     StartDate                DATETIME            NOT NULL,
     MinimumQty               DECIMAL(10,3)       NULL,
     MaximumQty               DECIMAL(10,3)       NULL,
     EffectiveDate            DATETIME            NULL,
     Reference                CHAR(30)            NULL,
     Freeze                   CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopArchiveStockLvlKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          ArchiveDate,
          ArchiveNumber,
          StartDate
         )
    )
    PRINT 'New table IopArchiveStockLvl'
END
GO

--  Add new 'IopDraftStockLvl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopDraftStockLvl') = 0
BEGIN
    CREATE TABLE IopDraftStockLvl(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     StartDate                DATETIME            NOT NULL,
     MinimumQty               DECIMAL(10,3)       NULL,
     MaximumQty               DECIMAL(10,3)       NULL,
     Reference                CHAR(30)            NULL,
     Freeze                   CHAR(1)             NULL,
     EffectiveDate            DATETIME            NULL,
     Operator                 CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopDraftStockLvlKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          StartDate
         )
    )
    PRINT 'New table IopDraftStockLvl'
END
GO

--  Add new 'IopLvlAmendJnl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopLvlAmendJnl') = 0
BEGIN
    CREATE TABLE IopLvlAmendJnl(
     JnlDate                  DATETIME            NOT NULL,
     JnlTime                  DECIMAL(8,0)        NOT NULL,
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     JnlPrinted               CHAR(1)             NULL,
     ChangeFlag               CHAR(1)             NULL,
     Operator                 CHAR(6)             NULL,
     OldStartDate             DATETIME            NULL,
     OldMinimumQty            DECIMAL(10,3)       NULL,
     OldMaximumQty            DECIMAL(10,3)       NULL,
     OldReference             CHAR(30)            NULL,
     OldFreeze                CHAR(1)             NULL,
     NewStartDate             DATETIME            NULL,
     NewMinimumQty            DECIMAL(10,3)       NULL,
     NewMaximumQty            DECIMAL(10,3)       NULL,
     NewReference             CHAR(30)            NULL,
     NewFreeze                CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopLvlAmendJnlKey PRIMARY KEY CLUSTERED
         (
          JnlDate,
          JnlTime,
          IdNumber
         )
    )
    PRINT 'New table IopLvlAmendJnl'
END
GO

--  Add new 'IopStockLevel' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopStockLevel') = 0
BEGIN
    CREATE TABLE IopStockLevel(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     StartDate                DATETIME            NOT NULL,
     MinimumQty               DECIMAL(10,3)       NULL,
     MaximumQty               DECIMAL(10,3)       NULL,
     EffectiveDate            DATETIME            NULL,
     Operator                 CHAR(6)             NULL,
     Reference                CHAR(30)            NULL,
     Freeze                   CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopStockLevelKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          StartDate
         )
    )
    PRINT 'New table IopStockLevel'
END
GO

--  Add new 'MrpStockLevel' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'MrpStockLevel') = 0
BEGIN
    CREATE TABLE MrpStockLevel(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     StartDate                DATETIME            NOT NULL,
     MinimumQty               DECIMAL(10,3)       NULL,
     MaximumQty               DECIMAL(10,3)       NULL,
     EffectiveDate            DATETIME            NULL,
     Operator                 CHAR(6)             NULL,
     Reference                CHAR(30)            NULL,
     Freeze                   CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT MrpStockLevelKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          StartDate
         )
    )
    PRINT 'New table MrpStockLevel'
END
GO

--  Add new 'IopMovements' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopMovements') = 0
BEGIN
    CREATE TABLE IopMovements(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     TrnDate                  DATETIME            NOT NULL,
     OpeningQty               DECIMAL(10,3)       NULL,
     QtyReceived              DECIMAL(10,3)       NULL,
     QtyIssued                DECIMAL(10,3)       NULL,
     ValueReceived            DECIMAL(14,2)       NULL,
     ValueIssued              DECIMAL(14,2)       NULL,
     NumberStockOuts          DECIMAL(4,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopMovementsKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          TrnDate
         )
    )
    PRINT 'New table IopMovements'
END
GO

--  Add new 'IopPolicyAmendJnl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopPolicyAmendJnl') = 0
BEGIN
    CREATE TABLE IopPolicyAmendJnl(
     JnlDate                  DATETIME            NOT NULL,
     JnlTime                  DECIMAL(8,0)        NOT NULL,
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     EffectiveDate            DATETIME            NOT NULL,
     JnlPrinted               CHAR(1)             NULL,
     ChangeFlag               CHAR(1)             NULL,
     Operator                 CHAR(6)             NULL,
     OReference               CHAR(50)            NULL,
     OPolicySource            CHAR(1)             NULL,
     OSelectSet               CHAR(10)            NULL,
     OPolicyType              CHAR(1)             NULL,
     ODaysOrQuantity          CHAR(1)             NULL,
     OSafetyDays              DECIMAL(3,0)        NULL,
     OSafetyQty               DECIMAL(10,3)       NULL,
     OSafetyCapDays           DECIMAL(3,0)        NULL,
     OSafetyCapQty            DECIMAL(10,3)       NULL,
     OAlgorithmUsed           CHAR(1)             NULL,
     OTargetServiceLvl        DECIMAL(5,2)        NULL,
     OServiceLevelMsr         CHAR(4)             NULL,
     OLeadTimeDays            DECIMAL(3,0)        NULL,
     OReviewFreq              DECIMAL(3,0)        NULL,
     OSupplyCode              CHAR(10)            NULL,
     NReference               CHAR(50)            NULL,
     NPolicySource            CHAR(1)             NULL,
     NSelectSet               CHAR(10)            NULL,
     NPolicyType              CHAR(1)             NULL,
     NDaysOrQuantity          CHAR(1)             NULL,
     NSafetyDays              DECIMAL(3,0)        NULL,
     NSafetyQty               DECIMAL(10,3)       NULL,
     NSafetyCapDays           DECIMAL(3,0)        NULL,
     NSafetyCapQty            DECIMAL(10,3)       NULL,
     NAlgorithmUsed           CHAR(1)             NULL,
     NTargetServiceLvl        DECIMAL(5,2)        NULL,
     NServiceLevelMsr         CHAR(4)             NULL,
     NLeadTimeDays            DECIMAL(3,0)        NULL,
     NReviewFreq              DECIMAL(3,0)        NULL,
     NSupplyCode              CHAR(10)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopPolicyAmendJnlKey PRIMARY KEY CLUSTERED
         (
          JnlDate,
          JnlTime,
          IdNumber,
          EffectiveDate
         )
    )
    PRINT 'New table IopPolicyAmendJnl'
END
GO

--  Add new 'IopPolicies' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopPolicies') = 0
BEGIN
    CREATE TABLE IopPolicies(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     EffectiveDate            DATETIME            NOT NULL,
     Reference                CHAR(50)            NULL,
     PolicySource             CHAR(1)             NULL,
     SelectionSet             CHAR(10)            NULL,
     PolicyType               CHAR(1)             NULL,
     DaysOrQuantity           CHAR(1)             NULL,
     SafetyDays               DECIMAL(3,0)        NULL,
     SafetyQty                DECIMAL(10,3)       NULL,
     SafetyCapDays            DECIMAL(3,0)        NULL,
     SafetyCapQty             DECIMAL(10,3)       NULL,
     AlgorithmUsed            CHAR(1)             NULL,
     TargetServiceLvl         DECIMAL(5,2)        NULL,
     ServiceLevelMsr          CHAR(4)             NULL,
     LeadTimeDays             DECIMAL(3,0)        NULL,
     ReviewFreq               DECIMAL(3,0)        NULL,
     SupplyCode               CHAR(10)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopPoliciesKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          EffectiveDate
         )
    )
    PRINT 'New table IopPolicies'
END
GO

--  Add new 'IopSupplyCon' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopSupplyCon') = 0
BEGIN
    CREATE TABLE IopSupplyCon(
     Supplier                 CHAR(7)             NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     DeliveryMethod           CHAR(10)            NOT NULL,
     MinValue                 DECIMAL(14,2)       NULL,
     MaxValue                 DECIMAL(14,2)       NULL,
     MinMass                  DECIMAL(11,3)       NULL,
     MaxMass                  DECIMAL(11,3)       NULL,
     MinVolume                DECIMAL(11,3)       NULL,
     MaxVolume                DECIMAL(11,3)       NULL,
     LeadTime                 DECIMAL(3,0)        NULL,
     DeliveryFreq             CHAR(1)             NULL,
     IntervalPeriod           DECIMAL(2,0)        NULL,
     DayOfWeekMonth           DECIMAL(2,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopSupplyConKey PRIMARY KEY CLUSTERED
         (
          Supplier,
          Warehouse,
          DeliveryMethod
         )
    )
    PRINT 'New table IopSupplyCon'
END
GO

--  Add new 'IopSelSetAmendJnl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopSelSetAmendJnl') = 0
BEGIN
    CREATE TABLE IopSelSetAmendJnl(
     JnlDate                  DATETIME            NOT NULL,
     JnlTime                  DECIMAL(8,0)        NOT NULL,
     SelectionSet             CHAR(10)            NOT NULL,
     JnlPrinted               CHAR(1)             NULL,
     ChangeFlag               CHAR(1)             NULL,
     Operator                 CHAR(6)             NULL,
     OldDescription           CHAR(30)            NULL,
     OldDateLastUsed          DATETIME            NULL,
     OldUseFgCol              CHAR(1)             NULL,
     OldCollection            CHAR(30)            NULL,
     OldInstance              DECIMAL(5,0)        NULL,
     OldStockSel              CHAR(1)             NULL,
     OldStockFrom             CHAR(30)            NULL,
     OldStockTo               CHAR(30)            NULL,
     OldWarehouseSel          CHAR(1)             NULL,
     OldWarehouseFrom         CHAR(2)             NULL,
     OldWarehouseTo           CHAR(2)             NULL,
     OldSupplierSel           CHAR(1)             NULL,
     OldSupplierFrom          CHAR(7)             NULL,
     OldSupplierTo            CHAR(7)             NULL,
     OldProdClassSel          CHAR(1)             NULL,
     OldProdClassFrom         CHAR(4)             NULL,
     OldProdClassTo           CHAR(4)             NULL,
     OldPlannerSel            CHAR(1)             NULL,
     OldPlannerFrom           CHAR(3)             NULL,
     OldPlannerTo             CHAR(3)             NULL,
     OldBuyerSel              CHAR(1)             NULL,
     OldBuyerFrom             CHAR(3)             NULL,
     OldBuyerTo               CHAR(3)             NULL,
     OldIncludeAbcA           DECIMAL(1,0)        NULL,
     OldIncludeAbcB           DECIMAL(1,0)        NULL,
     OldIncludeAbcC           DECIMAL(1,0)        NULL,
     OldIncludeAbcD           DECIMAL(1,0)        NULL,
     OldIncludeAbcE           DECIMAL(1,0)        NULL,
     OldIncludeAbcNone        DECIMAL(1,0)        NULL,
     OldAbcType               CHAR(1)             NULL,
     OldAbcLevel              CHAR(1)             NULL,
     OldAbcBase               CHAR(1)             NULL,
     OldAbcMonths             DECIMAL(2,0)        NULL,
     OldParetoBreakAb         DECIMAL(2,0)        NULL,
     OldParetoBreakBc         DECIMAL(2,0)        NULL,
     OldParetoBreakCd         DECIMAL(2,0)        NULL,
     OldIncludeAdjust         DECIMAL(1,0)        NULL,
     OldAnalyzeByEcc          DECIMAL(1,0)        NULL,
     OldManualForecast        DECIMAL(1,0)        NULL,
     OldReplenishItem         DECIMAL(1,0)        NULL,
     OldIncMto                DECIMAL(1,0)        NULL,
     OldIncMps                DECIMAL(1,0)        NULL,
     OldIncMadeIn             DECIMAL(1,0)        NULL,
     OldIncBoughtOut          DECIMAL(1,0)        NULL,
     OldIncSubCon             DECIMAL(1,0)        NULL,
     OldIncKit                DECIMAL(1,0)        NULL,
     OldIncCoProd             DECIMAL(1,0)        NULL,
     OldIncByProd             DECIMAL(1,0)        NULL,
     OldExcessStock           CHAR(1)             NULL,
     OldForecastCreate        CHAR(1)             NULL,
     OldInactivateCur         DECIMAL(1,0)        NULL,
     OldBatchTarget           CHAR(1)             NULL,
     OldAdjustOutliers        DECIMAL(1,0)        NULL,
     OldForecastRef           CHAR(30)            NULL,
     OldIncNoDraft            DECIMAL(1,0)        NULL,
     OldIncNoCurrent          DECIMAL(1,0)        NULL,
     OldIncPrdNoFore          DECIMAL(1,0)        NULL,
     OldOnlyIfDiff            DECIMAL(1,0)        NULL,
     OldPercentDiff           DECIMAL(3,0)        NULL,
     OldMonthsDiff            DECIMAL(2,0)        NULL,
     OldCalendar              CHAR(3)             NULL,
     OldOptionsMaint          CHAR(1)             NULL,
     OldUpdateLiveFore        CHAR(1)             NULL,
     OldBatchForecasts        CHAR(1)             NULL,
     OldManualForecasts       CHAR(1)             NULL,
     OldFamsAndGroups         CHAR(1)             NULL,
     OldParetoAnalysis        CHAR(1)             NULL,
     OldListOfForecasts       CHAR(1)             NULL,
     OldForecastCompare       CHAR(1)             NULL,
     OldForecastAcc           CHAR(1)             NULL,
     OldPolicySetting         CHAR(1)             NULL,
     OldIoModelling           CHAR(1)             NULL,
     OldForeAccCal            CHAR(3)             NULL,
     OldForeAccPeriods        DECIMAL(3,0)        NULL,
     OldForeAccCompare        CHAR(1)             NULL,
     OldForeAccMovePrd        DECIMAL(3,0)        NULL,
     OldForeAccUse            CHAR(1)             NULL,
     OldForeAccNoSnap         DECIMAL(3,0)        NULL,
     NewDescription           CHAR(30)            NULL,
     NewDateLastUsed          DATETIME            NULL,
     NewUseFgCollection       CHAR(1)             NULL,
     NewCollection            CHAR(30)            NULL,
     NewInstance              DECIMAL(5,0)        NULL,
     NewStockSel              CHAR(1)             NULL,
     NewStockFrom             CHAR(30)            NULL,
     NewStockTo               CHAR(30)            NULL,
     NewWarehouseSel          CHAR(1)             NULL,
     NewWarehouseFrom         CHAR(2)             NULL,
     NewWarehouseTo           CHAR(2)             NULL,
     NewSupplierSel           CHAR(1)             NULL,
     NewSupplierFrom          CHAR(7)             NULL,
     NewSupplierTo            CHAR(7)             NULL,
     NewProdClassSel          CHAR(1)             NULL,
     NewProdClassFrom         CHAR(4)             NULL,
     NewProdClassTo           CHAR(4)             NULL,
     NewPlannerSel            CHAR(1)             NULL,
     NewPlannerFrom           CHAR(3)             NULL,
     NewPlannerTo             CHAR(3)             NULL,
     NewBuyerSel              CHAR(1)             NULL,
     NewBuyerFrom             CHAR(3)             NULL,
     NewBuyerTo               CHAR(3)             NULL,
     NewIncludeAbcA           DECIMAL(1,0)        NULL,
     NewIncludeAbcB           DECIMAL(1,0)        NULL,
     NewIncludeAbcC           DECIMAL(1,0)        NULL,
     NewIncludeAbcD           DECIMAL(1,0)        NULL,
     NewIncludeAbcE           DECIMAL(1,0)        NULL,
     NewIncludeAbcNone        DECIMAL(1,0)        NULL,
     NewAbcType               CHAR(1)             NULL,
     NewAbcLevel              CHAR(1)             NULL,
     NewAbcBase               CHAR(1)             NULL,
     NewAbcMonths             DECIMAL(2,0)        NULL,
     NewParetoBreakAb         DECIMAL(2,0)        NULL,
     NewParetoBreakBc         DECIMAL(2,0)        NULL,
     NewParetoBreakCd         DECIMAL(2,0)        NULL,
     NewIncludeAdjust         DECIMAL(1,0)        NULL,
     NewAnalyzeByEcc          DECIMAL(1,0)        NULL,
     NewManualForecast        DECIMAL(1,0)        NULL,
     NewReplenishItem         DECIMAL(1,0)        NULL,
     NewIncMto                DECIMAL(1,0)        NULL,
     NewIncMps                DECIMAL(1,0)        NULL,
     NewIncMadeIn             DECIMAL(1,0)        NULL,
     NewIncBoughtOut          DECIMAL(1,0)        NULL,
     NewIncSubCon             DECIMAL(1,0)        NULL,
     NewIncKit                DECIMAL(1,0)        NULL,
     NewIncCoProd             DECIMAL(1,0)        NULL,
     NewIncByProd             DECIMAL(1,0)        NULL,
     NewExcessStock           CHAR(1)             NULL,
     NewForecastCreate        CHAR(1)             NULL,
     NewInactivateCur         DECIMAL(1,0)        NULL,
     NewBatchTarget           CHAR(1)             NULL,
     NewAdjustOutliers        DECIMAL(1,0)        NULL,
     NewForecastRef           CHAR(30)            NULL,
     NewIncNoDraft            DECIMAL(1,0)        NULL,
     NewIncNoCurrent          DECIMAL(1,0)        NULL,
     NewIncPrdNoFore          DECIMAL(1,0)        NULL,
     NewOnlyIfDiff            DECIMAL(1,0)        NULL,
     NewPercentDiff           DECIMAL(3,0)        NULL,
     NewMonthsDiff            DECIMAL(2,0)        NULL,
     NewCalendar              CHAR(3)             NULL,
     NewOptionsMaint          CHAR(1)             NULL,
     NewUpdateLiveFore        CHAR(1)             NULL,
     NewBatchForecasts        CHAR(1)             NULL,
     NewManualForecasts       CHAR(1)             NULL,
     NewFamsAndGroups         CHAR(1)             NULL,
     NewParetoAnalysis        CHAR(1)             NULL,
     NewListOfForecasts       CHAR(1)             NULL,
     NewForecastCompare       CHAR(1)             NULL,
     NewForecastAcc           CHAR(1)             NULL,
     NewPolicySetting         CHAR(1)             NULL,
     NewIoModelling           CHAR(1)             NULL,
     NewForeAccCal            CHAR(3)             NULL,
     NewForeAccPeriods        DECIMAL(3,0)        NULL,
     NewForeAccCompare        CHAR(1)             NULL,
     NewForeAccMovePrd        DECIMAL(3,0)        NULL,
     NewForeAccUse            CHAR(1)             NULL,
     NewForeAccNoSnap         DECIMAL(3,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopSelSetAmendJnlKey PRIMARY KEY CLUSTERED
         (
          JnlDate,
          JnlTime,
          SelectionSet
         )
    )
    PRINT 'New table IopSelSetAmendJnl'
END
GO

--  Add new 'IopSelectionSet' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopSelectionSet') = 0
BEGIN
    CREATE TABLE IopSelectionSet(
     SelectionSet             CHAR(10)            NOT NULL,
     Description              CHAR(30)            NULL,
     DateLastUsed             DATETIME            NULL,
     UseFgCollection          CHAR(1)             NULL,
     Collection               CHAR(30)            NULL,
     Instance                 DECIMAL(5,0)        NULL,
     StockSel                 CHAR(1)             NULL,
     StockFrom                CHAR(30)            NULL,
     StockTo                  CHAR(30)            NULL,
     WarehouseSel             CHAR(1)             NULL,
     WarehouseFrom            CHAR(2)             NULL,
     WarehouseTo              CHAR(2)             NULL,
     SupplierSel              CHAR(1)             NULL,
     SupplierFrom             CHAR(7)             NULL,
     SupplierTo               CHAR(7)             NULL,
     ProdClassSel             CHAR(1)             NULL,
     ProdClassFrom            CHAR(4)             NULL,
     ProdClassTo              CHAR(4)             NULL,
     PlannerSel               CHAR(1)             NULL,
     PlannerFrom              CHAR(3)             NULL,
     PlannerTo                CHAR(3)             NULL,
     BuyerSel                 CHAR(1)             NULL,
     BuyerFrom                CHAR(3)             NULL,
     BuyerTo                  CHAR(3)             NULL,
     IncludeAbcA              DECIMAL(1,0)        NULL,
     IncludeAbcB              DECIMAL(1,0)        NULL,
     IncludeAbcC              DECIMAL(1,0)        NULL,
     IncludeAbcD              DECIMAL(1,0)        NULL,
     IncludeAbcE              DECIMAL(1,0)        NULL,
     IncludeAbcNone           DECIMAL(1,0)        NULL,
     AbcType                  CHAR(1)             NULL,
     AbcLevel                 CHAR(1)             NULL,
     AbcBase                  CHAR(1)             NULL,
     AbcMonths                DECIMAL(2,0)        NULL,
     ParetoBreakAb            DECIMAL(2,0)        NULL,
     ParetoBreakBc            DECIMAL(2,0)        NULL,
     ParetoBreakCd            DECIMAL(2,0)        NULL,
     IncludeAdjust            DECIMAL(1,0)        NULL,
     AnalyzeByEcc             DECIMAL(1,0)        NULL,
     ManualForecast           DECIMAL(1,0)        NULL,
     ReplenishItem            DECIMAL(1,0)        NULL,
     IncMto                   DECIMAL(1,0)        NULL,
     IncMps                   DECIMAL(1,0)        NULL,
     IncMadeIn                DECIMAL(1,0)        NULL,
     IncBoughtOut             DECIMAL(1,0)        NULL,
     IncSubCon                DECIMAL(1,0)        NULL,
     IncKit                   DECIMAL(1,0)        NULL,
     IncCoProd                DECIMAL(1,0)        NULL,
     IncByProd                DECIMAL(1,0)        NULL,
     ExcessStock              CHAR(1)             NULL,
     ForecastCreate           CHAR(1)             NULL,
     InactivateCur            DECIMAL(1,0)        NULL,
     BatchTarget              CHAR(1)             NULL,
     AdjustOutliers           DECIMAL(1,0)        NULL,
     ForecastRef              CHAR(30)            NULL,
     IncNoDraft               DECIMAL(1,0)        NULL,
     IncNoCurrent             DECIMAL(1,0)        NULL,
     IncPrdNoFore             DECIMAL(1,0)        NULL,
     OnlyIfDiff               DECIMAL(1,0)        NULL,
     PercentDiff              DECIMAL(3,0)        NULL,
     MonthsDiff               DECIMAL(2,0)        NULL,
     Calendar                 CHAR(3)             NULL,
     OptionsMaint             CHAR(1)             NULL,
     UpdateLiveFore           CHAR(1)             NULL,
     BatchForecasts           CHAR(1)             NULL,
     ManualForecasts          CHAR(1)             NULL,
     FamsAndGroups            CHAR(1)             NULL,
     ParetoAnalysis           CHAR(1)             NULL,
     ListOfForecasts          CHAR(1)             NULL,
     ForecastCompare          CHAR(1)             NULL,
     ForecastAccuracy         CHAR(1)             NULL,
     PolicySetting            CHAR(1)             NULL,
     IoModelling              CHAR(1)             NULL,
     ForeAccCal               CHAR(3)             NULL,
     ForeAccPeriods           DECIMAL(3,0)        NULL,
     ForeAccCompare           CHAR(1)             NULL,
     ForeAccMovePeriods       DECIMAL(3,0)        NULL,
     ForeAccUse               CHAR(1)             NULL,
     ForeAccNoSnap            DECIMAL(3,0)        NULL,
     FreezeInLead             DECIMAL(1,0)        NULL,
     DeleteDraft              DECIMAL(1,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopSelectionSetKey PRIMARY KEY CLUSTERED
         (
          SelectionSet
         )
    )
    PRINT 'New table IopSelectionSet'
END
GO

--  Add new 'IopSupplyMethod' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopSupplyMethod') = 0
BEGIN
    CREATE TABLE IopSupplyMethod(
     IdNumber                 DECIMAL(10,0)       NOT NULL,
     SupplyCode               CHAR(10)            NOT NULL,
     Reference                CHAR(50)            NULL,
     SupplyType               CHAR(1)             NULL,
     Supplier                 CHAR(7)             NULL,
     Route                    CHAR(1)             NULL,
     SourceWh                 CHAR(2)             NULL,
     PlanOrderFreq            CHAR(1)             NULL,
     IntervalPeriod           DECIMAL(2,0)        NULL,
     DayOfWeekMonth           DECIMAL(2,0)        NULL,
     DeliveryMethod           CHAR(10)            NULL,
     IntLeadTime              DECIMAL(3,0)        NULL,
     SupLeadTime              DECIMAL(3,0)        NULL,
     InspectLead              DECIMAL(3,0)        NULL,
     MajorOrderMult           DECIMAL(10,3)       NULL,
     MinorOrderMult           DECIMAL(10,3)       NULL,
     OrderMinimum             DECIMAL(10,3)       NULL,
     OrderMaximum             DECIMAL(10,3)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopSupplyMethodKey PRIMARY KEY CLUSTERED
         (
          IdNumber,
          SupplyCode
         )
    )
    PRINT 'New table IopSupplyMethod'
END
GO

--  Add new 'IopSalesPerf' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'IopSalesPerf') = 0
BEGIN
    CREATE TABLE IopSalesPerf(
     StockCode                CHAR(30)            NOT NULL,
     Version                  CHAR(3)             NOT NULL,
     Release                  CHAR(3)             NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     SalesOrder               CHAR(6)             NOT NULL,
     SalesOrderInitLine       DECIMAL(4,0)        NOT NULL,
     EntrySystemDate          DATETIME            NOT NULL,
     EntrySystemTime          DECIMAL(4,0)        NOT NULL,
     OrderQty                 DECIMAL(10,3)       NULL,
     ShipQty                  DECIMAL(10,3)       NULL,
     LineShipDate             DATETIME            NULL,
     CustRequestDate          DATETIME            NULL,
     DeliveryCnt              DECIMAL(3,0)        NULL,
     Line                     DECIMAL(4,0)        NULL,
     Company                  CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT IopSalesPerfKey PRIMARY KEY CLUSTERED
         (
          StockCode,
          Version,
          Release,
          Warehouse,
          SalesOrder,
          SalesOrderInitLine,
          EntrySystemDate,
          EntrySystemTime
         )
    )
    CREATE UNIQUE INDEX IopSalesPerfIdxOrd ON IopSalesPerf(
     SalesOrder,
     SalesOrderInitLine,
     EntrySystemDate,
     EntrySystemTime,
     StockCode,
     Version,
     Release,
     Warehouse
     )
    CREATE UNIQUE INDEX IopSalesPerfIdxDent ON IopSalesPerf(
     EntrySystemDate,
     EntrySystemTime,
     StockCode,
     Version,
     Release,
     Warehouse,
     SalesOrder,
     SalesOrderInitLine
     )
    PRINT 'New table IopSalesPerf'
END
GO

--  Add new 'MrpDetailPegging' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'MrpDetailPegging') = 0
BEGIN
    CREATE TABLE MrpDetailPegging(
     StockCode                CHAR(30)            NOT NULL,
     Version                  CHAR(3)             NOT NULL,
     Release                  CHAR(3)             NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     SupplyDemandDate         DATETIME            NOT NULL,
     SourceType               CHAR(1)             NOT NULL,
     OrigSourceKey            CHAR(30)            NOT NULL,
     Quantity                 DECIMAL(10,3)       NULL,
     ParentStockCode          CHAR(30)            NULL,
     ParentLine               DECIMAL(3,0)        NULL,
     OrderNumber              CHAR(10)            NULL,
     LineNumber               DECIMAL(5,0)        NULL,
     JobLine                  CHAR(6)             NULL,
     UserCode                 CHAR(3)             NULL,
     SourceWarehouse          CHAR(2)             NULL,
     TargetWarehouse          CHAR(2)             NULL,
     ForecastDate             DATETIME            NULL,
     LiveDate                 DATETIME            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT MrpDetailPeggingKey PRIMARY KEY CLUSTERED
         (
          StockCode,
          Version,
          Release,
          Warehouse,
          SupplyDemandDate,
          SourceType,
          OrigSourceKey
         )
    )
    CREATE UNIQUE INDEX MrpDetailPeggingIdxSource ON MrpDetailPegging(
     SourceType,
     OrigSourceKey,
     StockCode,
     Version,
     Release,
     Warehouse,
     SupplyDemandDate
     )
    PRINT 'New table MrpDetailPegging'
END
GO

--  Add new 'MrpMpsDetPegging' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'MrpMpsDetPegging') = 0
BEGIN
    CREATE TABLE MrpMpsDetPegging(
     StockCode                CHAR(30)            NOT NULL,
     Version                  CHAR(3)             NOT NULL,
     Release                  CHAR(3)             NOT NULL,
     Warehouse                CHAR(2)             NOT NULL,
     SupplyDemandDate         DATETIME            NOT NULL,
     SourceType               CHAR(1)             NOT NULL,
     OrigSourceKey            CHAR(30)            NOT NULL,
     Quantity                 DECIMAL(10,3)       NULL,
     ParentStockCode          CHAR(30)            NULL,
     ParentLine               DECIMAL(3,0)        NULL,
     OrderNumber              CHAR(10)            NULL,
     LineNumber               DECIMAL(5,0)        NULL,
     JobLine                  CHAR(6)             NULL,
     UserCode                 CHAR(3)             NULL,
     SourceWarehouse          CHAR(2)             NULL,
     TargetWarehouse          CHAR(2)             NULL,
     ForecastDate             DATETIME            NULL,
     LiveDate                 DATETIME            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT MrpMpsDetPeggingKey PRIMARY KEY CLUSTERED
         (
          StockCode,
          Version,
          Release,
          Warehouse,
          SupplyDemandDate,
          SourceType,
          OrigSourceKey
         )
    )
    CREATE UNIQUE INDEX MrpMpsDetPeggingIdxSource ON MrpMpsDetPegging(
     SourceType,
     OrigSourceKey,
     StockCode,
     Version,
     Release,
     Warehouse,
     SupplyDemandDate
     )
    PRINT 'New table MrpMpsDetPegging'
END
GO

--  Add new 'PrjHierarchyXref' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'PrjHierarchyXref') = 0
BEGIN
    CREATE TABLE PrjHierarchyXref(
     HierarchyType            CHAR(1)             NOT NULL,
     JobEstimate              CHAR(8)             NOT NULL,
     HierHead                 CHAR(3)             NOT NULL,
     Section1                 CHAR(3)             NOT NULL,
     Section2                 CHAR(3)             NOT NULL,
     Section3                 CHAR(3)             NOT NULL,
     Section4                 CHAR(3)             NOT NULL,
     TrnType                  CHAR(1)             NOT NULL,
     SourceKey                CHAR(50)            NOT NULL,
     StockCode                CHAR(30)            NULL,
     Warehouse                CHAR(2)             NULL,
     MatAllocLine             CHAR(2)             NULL,
     PostLine                 DECIMAL(7,0)        NULL,
     Operation                DECIMAL(5,0)        NULL,
     Supplier                 CHAR(7)             NULL,
     IndexJob                 CHAR(8)             NULL,
     PostJob                  CHAR(8)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT PrjHierarchyXrefKey PRIMARY KEY CLUSTERED
         (
          HierarchyType,
          JobEstimate,
          HierHead,
          Section1,
          Section2,
          Section3,
          Section4,
          TrnType,
          SourceKey
         )
    )
    PRINT 'New table PrjHierarchyXref'
END
GO

--  Add new 'QmsElement' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'QmsElement') = 0
BEGIN
    CREATE TABLE QmsElement(
     QmsElement               CHAR(30)            NOT NULL,
     Description              CHAR(50)            NULL,
     ScreenLabel              CHAR(30)            NULL,
     FieldType                CHAR(1)             NULL,
     FieldLength              DECIMAL(3,0)        NULL,
     Decimals                 DECIMAL(2,0)        NULL,
     ValueFlag                CHAR(1)             NULL,
     VarianceType             CHAR(1)             NULL,
     VariancePlusFlag         CHAR(1)             NULL,
     VarianceMinusFlag        CHAR(1)             NULL,
     PhysicalUnit             CHAR(20)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT QmsElementKey PRIMARY KEY CLUSTERED
         (
          QmsElement
         )
    )
    PRINT 'New table QmsElement'
END
GO

--  Add new 'QmsInspectDetail' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'QmsInspectDetail') = 0
BEGIN
    CREATE TABLE QmsInspectDetail(
     QmsInspection            CHAR(30)            NOT NULL,
     QmsElement               CHAR(30)            NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     XrefType                 CHAR(1)             NULL,
     XrefKey                  CHAR(30)            NULL,
     DetailStatus             CHAR(1)             NULL,
     DetailResult             CHAR(1)             NULL,
     Warehouse                CHAR(2)             NULL,
     LotJob                   CHAR(10)            NULL,
     Version                  CHAR(3)             NULL,
     Release                  CHAR(3)             NULL,
     MeasurementRef           CHAR(60)            NULL,
     CalibrationRef           CHAR(60)            NULL,
     MeasurementDate          DATETIME            NULL,
     Temperature              DECIMAL(3,0)        NULL,
     Humidity                 DECIMAL(3,0)        NULL,
     Operator                 CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT QmsInspectDetailKey PRIMARY KEY CLUSTERED
         (
          QmsInspection,
          QmsElement,
          StockCode
         )
    )
    CREATE UNIQUE INDEX QmsInspectDetailIdxStatus ON QmsInspectDetail(
     DetailStatus,
     QmsInspection,
     QmsElement,
     StockCode
     )
    CREATE UNIQUE INDEX QmsInspectDetailIdxXref ON QmsInspectDetail(
     XrefType,
     XrefKey,
     QmsInspection,
     QmsElement,
     StockCode
     )
    PRINT 'New table QmsInspectDetail'
END
GO

--  Add new 'QmsInspectElement' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'QmsInspectElement') = 0
BEGIN
    CREATE TABLE QmsInspectElement(
     QmsElement               CHAR(30)            NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     XrefType                 CHAR(1)             NOT NULL,
     XrefKey                  CHAR(30)            NOT NULL,
     InspectionRule           CHAR(2)             NULL,
     SampleType               CHAR(1)             NULL,
     SampleSize               DECIMAL(18,6)       NULL,
     InspectPeriodType        CHAR(1)             NULL,
     InspectPeriodInt         DECIMAL(10,0)       NULL,
     PlusVariance             DECIMAL(18,6)       NULL,
     MinusVariance            DECIMAL(18,6)       NULL,
     ApplyWipInspect          CHAR(1)             NULL,
     ApplyPoInspect           CHAR(1)             NULL,
     ApplySoInspect           CHAR(1)             NULL,
     ApplyInvInspect          CHAR(1)             NULL,
     DateValueFrom            DATETIME            NULL,
     DateValueTo              DATETIME            NULL,
     AlphaValueFrom           CHAR(50)            NULL,
     AlphaValueTo             CHAR(50)            NULL,
     NumericValueFrom         DECIMAL(18,6)       NULL,
     NumericValueTo           DECIMAL(18,6)       NULL,
     BooleanValue             CHAR(1)             NULL,
     Warehouse                CHAR(2)             NULL,
     LotJob                   CHAR(10)            NULL,
     Version                  CHAR(3)             NULL,
     Release                  CHAR(3)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT QmsInspectElementKey PRIMARY KEY CLUSTERED
         (
          QmsElement,
          StockCode,
          XrefType,
          XrefKey
         )
    )
    PRINT 'New table QmsInspectElement'
END
GO

--  Add new 'QmsInspectElemList' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'QmsInspectElemList') = 0
BEGIN
    CREATE TABLE QmsInspectElemList(
     QmsElement               CHAR(30)            NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     XrefType                 CHAR(1)             NOT NULL,
     XrefKey                  CHAR(30)            NOT NULL,
     ListSequence             DECIMAL(3,0)        NOT NULL,
     DateValue                DATETIME            NULL,
     AlphaValue               CHAR(50)            NULL,
     NumericValue             DECIMAL(18,6)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT QmsInspectElemListKey PRIMARY KEY CLUSTERED
         (
          QmsElement,
          StockCode,
          XrefType,
          XrefKey,
          ListSequence
         )
    )
    PRINT 'New table QmsInspectElemList'
END
GO

--  Add new 'QmsInspectDtMetric' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'QmsInspectDtMetric') = 0
BEGIN
    CREATE TABLE QmsInspectDtMetric(
     QmsInspection            CHAR(30)            NOT NULL,
     QmsElement               CHAR(30)            NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     MetricSequence           DECIMAL(4,0)        NOT NULL,
     DetailResult             CHAR(1)             NULL,
     MeasuredDate             DATETIME            NULL,
     MeasuredAlpha            CHAR(50)            NULL,
     MeasuredNumeric          DECIMAL(18,6)       NULL,
     MeasuredBoolean          CHAR(1)             NULL,
     Serial                   CHAR(20)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT QmsInspectDtMetricKey PRIMARY KEY CLUSTERED
         (
          QmsInspection,
          QmsElement,
          StockCode,
          MetricSequence
         )
    )
    PRINT 'New table QmsInspectDtMetric'
END
GO

--  Add new 'QmsInspection' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'QmsInspection') = 0
BEGIN
    CREATE TABLE QmsInspection(
     QmsInspection            CHAR(30)            NOT NULL,
     ProcessTransaction       CHAR(5)             NULL,
     InspectionStatus         CHAR(1)             NULL,
     InspectionResult         CHAR(1)             NULL,
     InspectionRef            CHAR(30)            NULL,
     Supplier                 CHAR(7)             NULL,
     Customer                 CHAR(7)             NULL,
     Route                    CHAR(1)             NULL,
     WorkCentre               CHAR(6)             NULL,
     Warehouse                CHAR(2)             NULL,
     LotJob                   CHAR(10)            NULL,
     Job                      CHAR(8)             NULL,
     PurchaseOrder            CHAR(6)             NULL,
     SalesOrder               CHAR(6)             NULL,
     Line                     DECIMAL(4,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT QmsInspectionKey PRIMARY KEY CLUSTERED
         (
          QmsInspection
         )
    )
    CREATE UNIQUE INDEX QmsInspectionIdxStatus ON QmsInspection(
     InspectionStatus,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxTrans ON QmsInspection(
     ProcessTransaction,
     InspectionStatus,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxRef ON QmsInspection(
     InspectionRef,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxSup ON QmsInspection(
     Supplier,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxCus ON QmsInspection(
     Customer,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxRoute ON QmsInspection(
     Route,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxWrk ON QmsInspection(
     WorkCentre,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxPord ON QmsInspection(
     PurchaseOrder,
     Line,
     QmsInspection
     )
    CREATE UNIQUE INDEX QmsInspectionIdxSord ON QmsInspection(
     SalesOrder,
     Line,
     QmsInspection
     )
    PRINT 'New table QmsInspection'
END
GO

--  Add new 'ReqGroupActualUse' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ReqGroupActualUse') = 0
BEGIN
    CREATE TABLE ReqGroupActualUse(
     RequisitionGroup         CHAR(6)             NOT NULL,
     ProductClass             CHAR(4)             NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     BudgetYear               DECIMAL(4,0)        NOT NULL,
     GroupApproved1           DECIMAL(12,0)       NULL,
     GroupApproved2           DECIMAL(12,0)       NULL,
     GroupApproved3           DECIMAL(12,0)       NULL,
     GroupApproved4           DECIMAL(12,0)       NULL,
     GroupApproved5           DECIMAL(12,0)       NULL,
     GroupApproved6           DECIMAL(12,0)       NULL,
     GroupApproved7           DECIMAL(12,0)       NULL,
     GroupApproved8           DECIMAL(12,0)       NULL,
     GroupApproved9           DECIMAL(12,0)       NULL,
     GroupApproved10          DECIMAL(12,0)       NULL,
     GroupApproved11          DECIMAL(12,0)       NULL,
     GroupApproved12          DECIMAL(12,0)       NULL,
     GroupApproved13          DECIMAL(12,0)       NULL,
     GroupActual1             DECIMAL(12,0)       NULL,
     GroupActual2             DECIMAL(12,0)       NULL,
     GroupActual3             DECIMAL(12,0)       NULL,
     GroupActual4             DECIMAL(12,0)       NULL,
     GroupActual5             DECIMAL(12,0)       NULL,
     GroupActual6             DECIMAL(12,0)       NULL,
     GroupActual7             DECIMAL(12,0)       NULL,
     GroupActual8             DECIMAL(12,0)       NULL,
     GroupActual9             DECIMAL(12,0)       NULL,
     GroupActual10            DECIMAL(12,0)       NULL,
     GroupActual11            DECIMAL(12,0)       NULL,
     GroupActual12            DECIMAL(12,0)       NULL,
     GroupActual13            DECIMAL(12,0)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ReqGroupActualUseKey PRIMARY KEY CLUSTERED
         (
          RequisitionGroup,
          ProductClass,
          StockCode,
          BudgetYear
         )
    )
    PRINT 'New table ReqGroupActualUse'
END
GO

--  Add new 'ReqGroupBudgets' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ReqGroupBudgets') = 0
BEGIN
    CREATE TABLE ReqGroupBudgets(
     RequisitionGroup         CHAR(6)             NOT NULL,
     ProductClass             CHAR(4)             NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     BudgetYear               DECIMAL(4,0)        NOT NULL,
     GroupBudget1             DECIMAL(12,0)       NULL,
     GroupBudget2             DECIMAL(12,0)       NULL,
     GroupBudget3             DECIMAL(12,0)       NULL,
     GroupBudget4             DECIMAL(12,0)       NULL,
     GroupBudget5             DECIMAL(12,0)       NULL,
     GroupBudget6             DECIMAL(12,0)       NULL,
     GroupBudget7             DECIMAL(12,0)       NULL,
     GroupBudget8             DECIMAL(12,0)       NULL,
     GroupBudget9             DECIMAL(12,0)       NULL,
     GroupBudget10            DECIMAL(12,0)       NULL,
     GroupBudget11            DECIMAL(12,0)       NULL,
     GroupBudget12            DECIMAL(12,0)       NULL,
     GroupBudget13            DECIMAL(12,0)       NULL,
     DateLastUpdated          DATETIME            NULL,
     Operator                 CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ReqGroupBudgetsKey PRIMARY KEY CLUSTERED
         (
          RequisitionGroup,
          ProductClass,
          StockCode,
          BudgetYear
         )
    )
    PRINT 'New table ReqGroupBudgets'
END
GO

--  Add new 'ReqGroupAuthority' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ReqGroupAuthority') = 0
BEGIN
    CREATE TABLE ReqGroupAuthority(
     RequisitionGroup         CHAR(6)             NOT NULL,
     ProductClass             CHAR(4)             NOT NULL,
     NextUser                 CHAR(3)             NULL,
     MaxApproveValue          DECIMAL(14,2)       NULL,
     UserForPorder            CHAR(3)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ReqGroupAuthorityKey PRIMARY KEY CLUSTERED
         (
          RequisitionGroup,
          ProductClass
         )
    )
    PRINT 'New table ReqGroupAuthority'
END
GO

--  Add new 'ReqGroupActualQty' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ReqGroupActualQty') = 0
BEGIN
    CREATE TABLE ReqGroupActualQty(
     RequisitionGroup         CHAR(6)             NOT NULL,
     ProductClass             CHAR(4)             NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     BudgetYear               DECIMAL(4,0)        NOT NULL,
     GroupApprovedQty1        DECIMAL(10,3)       NULL,
     GroupApprovedQty2        DECIMAL(10,3)       NULL,
     GroupApprovedQty3        DECIMAL(10,3)       NULL,
     GroupApprovedQty4        DECIMAL(10,3)       NULL,
     GroupApprovedQty5        DECIMAL(10,3)       NULL,
     GroupApprovedQty6        DECIMAL(10,3)       NULL,
     GroupApprovedQty7        DECIMAL(10,3)       NULL,
     GroupApprovedQty8        DECIMAL(10,3)       NULL,
     GroupApprovedQty9        DECIMAL(10,3)       NULL,
     GroupApprovedQty10       DECIMAL(10,3)       NULL,
     GroupApprovedQty11       DECIMAL(10,3)       NULL,
     GroupApprovedQty12       DECIMAL(10,3)       NULL,
     GroupApprovedQty13       DECIMAL(10,3)       NULL,
     GroupActualQty1          DECIMAL(10,3)       NULL,
     GroupActualQty2          DECIMAL(10,3)       NULL,
     GroupActualQty3          DECIMAL(10,3)       NULL,
     GroupActualQty4          DECIMAL(10,3)       NULL,
     GroupActualQty5          DECIMAL(10,3)       NULL,
     GroupActualQty6          DECIMAL(10,3)       NULL,
     GroupActualQty7          DECIMAL(10,3)       NULL,
     GroupActualQty8          DECIMAL(10,3)       NULL,
     GroupActualQty9          DECIMAL(10,3)       NULL,
     GroupActualQty10         DECIMAL(10,3)       NULL,
     GroupActualQty11         DECIMAL(10,3)       NULL,
     GroupActualQty12         DECIMAL(10,3)       NULL,
     GroupActualQty13         DECIMAL(10,3)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ReqGroupActualQtyKey PRIMARY KEY CLUSTERED
         (
          RequisitionGroup,
          ProductClass,
          StockCode,
          BudgetYear
         )
    )
    PRINT 'New table ReqGroupActualQty'
END
GO

--  Add new 'ReqGroup' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'ReqGroup') = 0
BEGIN
    CREATE TABLE ReqGroup(
     RequisitionGroup         CHAR(6)             NOT NULL,
     GroupDescription         CHAR(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT ReqGroupKey PRIMARY KEY CLUSTERED
         (
          RequisitionGroup
         )
    )
    PRINT 'New table ReqGroup'
END
GO

--  Add new 'SalSalesTaxUkVat' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SalSalesTaxUkVat') = 0
BEGIN
    CREATE TABLE SalSalesTaxUkVat(
     TrnYear                  DECIMAL(4,0)        NOT NULL,
     TrnMonth                 DECIMAL(2,0)        NOT NULL,
     TrnDate                  DATETIME            NOT NULL,
     InvoiceRegister          DECIMAL(5,0)        NOT NULL,
     Invoice                  CHAR(6)             NOT NULL,
     Line                     DECIMAL(5,0)        NOT NULL,
     ExemptValue              DECIMAL(14,2)       NULL,
     NonExemptValue           DECIMAL(14,2)       NULL,
     InvoiceValue             DECIMAL(14,2)       NULL,
     TaxValue1                DECIMAL(14,2)       NULL,
     TaxValue2                DECIMAL(14,2)       NULL,
     TaxValue3                DECIMAL(14,2)       NULL,
     TaxValue4                DECIMAL(14,2)       NULL,
     TaxValue5                DECIMAL(14,2)       NULL,
     TaxCode1                 CHAR(1)             NULL,
     TaxCode2                 CHAR(1)             NULL,
     TaxCode3                 CHAR(1)             NULL,
     TaxCode4                 CHAR(1)             NULL,
     TaxCode5                 CHAR(1)             NULL,
     TaxableValue             DECIMAL(14,2)       NULL,
     UkCurrency               CHAR(3)             NULL,
     UkRate                   DECIMAL(12,6)       NULL,
     UkMulDiv                 CHAR(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT SalSalesTaxUkVatKey PRIMARY KEY CLUSTERED
         (
          TrnYear,
          TrnMonth,
          TrnDate,
          InvoiceRegister,
          Invoice,
          Line
         )
    )
    PRINT 'New table SalSalesTaxUkVat'
END
GO

--  Add new 'SwsAction' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SwsAction') = 0
BEGIN
    CREATE TABLE SwsAction(
     ActionId                 DECIMAL(6,0)        NOT NULL,
     ActionNumber             DECIMAL(2,0)        NOT NULL,
     Description              CHAR(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT SwsActionKey PRIMARY KEY CLUSTERED
         (
          ActionId,
          ActionNumber
         )
    )
    PRINT 'New table SwsAction'
END
GO

--  Add new 'SwsActionDetail' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SwsActionDetail') = 0
BEGIN
    CREATE TABLE SwsActionDetail(
     ActionId                 DECIMAL(6,0)        NOT NULL,
     ActionNumber             DECIMAL(2,0)        NOT NULL,
     Description              CHAR(30)            NULL,
     ActionType               DECIMAL(2,0)        NULL,
     UserActionType           DECIMAL(2,0)        NULL,
     ToolTip                  CHAR(50)            NULL,
     ProgramToCall            CHAR(256)           NULL,
     ProgramParameter         CHAR(256)           NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT SwsActionDetailKey PRIMARY KEY CLUSTERED
         (
          ActionId,
          ActionNumber
         )
    )
    PRINT 'New table SwsActionDetail'
END
GO

--  Add new 'SwsMessages' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'SwsMessages') = 0
BEGIN
    CREATE TABLE SwsMessages(
     OperatorCode             CHAR(6)             NOT NULL,
     DateCreated              DATETIME            NOT NULL,
     TimeCreated              DECIMAL(8,0)        NOT NULL,
     ExpiryDate               DATETIME            NULL,
     ExpiryTime               DECIMAL(8,0)        NULL,
     Category                 CHAR(1)             NULL,
     Status                   DECIMAL(2,0)        NULL,
     ActionId                 DECIMAL(6,0)        NULL,
     Subject                  CHAR(100)           NULL,
     Message                  CHAR(400)           NULL,
     Priority                 DECIMAL(1,0)        NULL,
     ActioningOperator        CHAR(6)             NULL,
     OperatorCreated          CHAR(6)             NULL,
     WorkflowName             CHAR(255)           NULL,
     WorkflowKey              CHAR(200)           NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT SwsMessagesKey PRIMARY KEY CLUSTERED
         (
          OperatorCode,
          DateCreated,
          TimeCreated
         )
    )
    CREATE UNIQUE INDEX SwsMessagesIdxActionId ON SwsMessages(
     ActionId,
     OperatorCode,
     DateCreated,
     TimeCreated
     )
    PRINT 'New table SwsMessages'
END
GO

--  Add new 'TblSaSupplUnits' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'TblSaSupplUnits') = 0
BEGIN
    CREATE TABLE TblSaSupplUnits(
     SupplUnitCode            CHAR(3)             NOT NULL,
     Description              CHAR(30)            NULL,
     ExtendedCode             CHAR(40)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT TblSaSupplUnitsKey PRIMARY KEY CLUSTERED
         (
          SupplUnitCode
         )
    )
    PRINT 'New table TblSaSupplUnits'
END
GO

--  Add new 'TpmPromoDetTrans' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'TpmPromoDetTrans') = 0
BEGIN
    CREATE TABLE TpmPromoDetTrans(
     Invoice                  CHAR(6)             NOT NULL,
     InvoiceLine              DECIMAL(4,0)        NOT NULL,
     PromotionCode            CHAR(10)            NOT NULL,
     TpmSequence              DECIMAL(6,0)        NOT NULL,
     SalesOrder               CHAR(6)             NOT NULL,
     SalesOrderLine           DECIMAL(4,0)        NOT NULL,
     TrnDate                  DATETIME            NOT NULL,
     TrnTime                  DECIMAL(8,0)        NOT NULL,
     Customer                 CHAR(7)             NULL,
     TransactionValue         DECIMAL(14,2)       NULL,
     PromotionType            CHAR(1)             NULL,
     Globalflag               CHAR(1)             NULL,
     OriginalPrice            DECIMAL(15,5)       NULL,
     SoChargeLine             DECIMAL(4,0)        NULL,
     StockCode                CHAR(30)            NULL,
     FreeGoodsStock           CHAR(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT TpmPromoDetTransKey PRIMARY KEY CLUSTERED
         (
          Invoice,
          InvoiceLine,
          PromotionCode,
          TpmSequence,
          SalesOrder,
          SalesOrderLine,
          TrnDate,
          TrnTime
         )
    )
    CREATE UNIQUE INDEX TpmPromoDetTransIdxCust ON TpmPromoDetTrans(
     Customer,
     Invoice,
     InvoiceLine,
     PromotionCode,
     TpmSequence,
     SalesOrder,
     SalesOrderLine,
     TrnDate,
     TrnTime
     )
    CREATE UNIQUE INDEX TpmPromoDetTransIdxPromo ON TpmPromoDetTrans(
     PromotionCode,
     TrnDate,
     TrnTime,
     Invoice,
     InvoiceLine,
     TpmSequence,
     SalesOrder,
     SalesOrderLine
     )
    PRINT 'New table TpmPromoDetTrans'
END
GO

--  Add new 'WipLabJnlStat' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WipLabJnlStat') = 0
BEGIN
    CREATE TABLE WipLabJnlStat(
     Journal                  DECIMAL(5,0)        NOT NULL,
     Status                   CHAR(1)             NULL,
     JournalDate              DATETIME            NULL,
     Operator                 CHAR(6)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WipLabJnlStatKey PRIMARY KEY CLUSTERED
         (
          Journal
         )
    )
    PRINT 'New table WipLabJnlStat'
END
GO

--  Add new 'WmsBinContainer' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsBinContainer') = 0
BEGIN
    CREATE TABLE WmsBinContainer(
     Warehouse                CHAR(2)             NOT NULL,
     Bin                      CHAR(6)             NOT NULL,
     BinContainType           CHAR(20)            NOT NULL,
     BinContainCode           CHAR(40)            NOT NULL,
     StorageSequence          DECIMAL(6,0)        NULL,
     ContainStatus            CHAR(1)             NULL,
     BinContainBarcode        CHAR(30)            NULL,
     BinContainRfid           CHAR(60)            NULL,
     UomCode                  CHAR(20)            NULL,
     BinContainParType        CHAR(20)            NULL,
     BinContainParCode        CHAR(40)            NULL,
     BinContainRef            CHAR(60)            NULL,
     ReceiptType              CHAR(10)            NULL,
     ReceiptRef               CHAR(30)            NULL,
     LastTouchDate            DATETIME            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsBinContainerKey PRIMARY KEY CLUSTERED
         (
          Warehouse,
          Bin,
          BinContainType,
          BinContainCode
         )
    )
    CREATE UNIQUE INDEX WmsBinContainerIdxBarcode ON WmsBinContainer(
     BinContainBarcode,
     BinContainType,
     Warehouse,
     Bin,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinContainerIdxRfid ON WmsBinContainer(
     BinContainRfid,
     BinContainType,
     Warehouse,
     Bin,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinContainerIdxRec ON WmsBinContainer(
     ReceiptType,
     ReceiptRef,
     Warehouse,
     Bin,
     BinContainType,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinContainerIdxParent ON WmsBinContainer(
     BinContainParType,
     BinContainParCode,
     Warehouse,
     Bin,
     BinContainType,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinContainerIdxSeq ON WmsBinContainer(
     Warehouse,
     Bin,
     BinContainType,
     StorageSequence,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinContainerIdxWhsTyp ON WmsBinContainer(
     Warehouse,
     BinContainType,
     BinContainCode,
     Bin
     )
    PRINT 'New table WmsBinContainer'
END
GO

--  Add new 'WmsBinContainerTyp' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsBinContainerTyp') = 0
BEGIN
    CREATE TABLE WmsBinContainerTyp(
     BinContainType           CHAR(20)            NOT NULL,
     Description              CHAR(60)            NULL,
     IsCarrier                CHAR(1)             NULL,
     DimensionUnit            CHAR(20)            NULL,
     PhysicalLength           DECIMAL(12,6)       NULL,
     PhysicalWidth            DECIMAL(12,6)       NULL,
     PhysicalHeight           DECIMAL(12,6)       NULL,
     MassUnit                 CHAR(20)            NULL,
     MassMax                  DECIMAL(12,6)       NULL,
     VolumeUnit               CHAR(20)            NULL,
     VolumeMax                DECIMAL(12,6)       NULL,
     SerialTrack              CHAR(1)             NULL,
     SerialIssue              CHAR(1)             NULL,
     SerialPrefix             CHAR(20)            NULL,
     LastSerialNumber         DECIMAL(15,0)       NULL,
     SerialSuffix             CHAR(20)            NULL,
     VolumeSelf               DECIMAL(12,6)       NULL,
     MassSelf                 DECIMAL(12,6)       NULL,
     UseOriginalFlag          CHAR(1)             NULL,
     UomCode                  CHAR(20)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsBinContainerTypKey PRIMARY KEY CLUSTERED
         (
          BinContainType
         )
    )
    PRINT 'New table WmsBinContainerTyp'
END
GO

--  Add new 'WmsBinType' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsBinType') = 0
BEGIN
    CREATE TABLE WmsBinType(
     Warehouse                CHAR(2)             NOT NULL,
     BinType                  CHAR(20)            NOT NULL,
     Description              CHAR(60)            NULL,
     FlowType                 CHAR(10)            NULL,
     AllowMultiProduct        CHAR(1)             NULL,
     AllowMultiLot            CHAR(1)             NULL,
     AutoReplenish            CHAR(1)             NULL,
     DimensionUnit            CHAR(20)            NULL,
     PhysicalLength           DECIMAL(12,6)       NULL,
     PhysicalWidth            DECIMAL(12,6)       NULL,
     PhysicalHeight           DECIMAL(12,6)       NULL,
     MassUnit                 CHAR(20)            NULL,
     MassMax                  DECIMAL(12,6)       NULL,
     VolumeUnit               CHAR(20)            NULL,
     VolumeMax                DECIMAL(12,6)       NULL,
     StorageSecurity          CHAR(20)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsBinTypeKey PRIMARY KEY CLUSTERED
         (
          Warehouse,
          BinType
         )
    )
    PRINT 'New table WmsBinType'
END
GO

--  Add new 'WmsBinStock' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsBinStock') = 0
BEGIN
    CREATE TABLE WmsBinStock(
     Warehouse                CHAR(2)             NOT NULL,
     Bin                      CHAR(6)             NOT NULL,
     BinContainType           CHAR(20)            NOT NULL,
     BinContainCode           CHAR(40)            NOT NULL,
     StockCode                CHAR(30)            NOT NULL,
     WhArea                   CHAR(20)            NULL,
     LotJob                   CHAR(10)            NULL,
     ExpiryDate               DATETIME            NULL,
     QtyIn                    DECIMAL(10,3)       NULL,
     QtyOnHand                DECIMAL(10,3)       NULL,
     QtyAlloc                 DECIMAL(10,3)       NULL,
     QtyOut                   DECIMAL(10,3)       NULL,
     Version                  CHAR(3)             NULL,
     Release                  CHAR(3)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsBinStockKey PRIMARY KEY CLUSTERED
         (
          Warehouse,
          Bin,
          BinContainType,
          BinContainCode,
          StockCode
         )
    )
    CREATE UNIQUE INDEX WmsBinStockIdxAvail ON WmsBinStock(
     Warehouse,
     WhArea,
     StockCode,
     LotJob,
     Bin,
     BinContainType,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinStockIdxStkOh ON WmsBinStock(
     StockCode,
     Warehouse,
     WhArea,
     LotJob,
     Bin,
     BinContainType,
     BinContainCode
     )
    CREATE UNIQUE INDEX WmsBinStockIdxBin ON WmsBinStock(
     Warehouse,
     Bin,
     StockCode,
     BinContainType,
     BinContainCode
     )
    PRINT 'New table WmsBinStock'
END
GO

--  Add new 'WmsStorageCond' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsStorageCond') = 0
BEGIN
    CREATE TABLE WmsStorageCond(
     StorageCondition         CHAR(20)            NOT NULL,
     Description              CHAR(60)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsStorageCondKey PRIMARY KEY CLUSTERED
         (
          StorageCondition
         )
    )
    PRINT 'New table WmsStorageCond'
END
GO

--  Add new 'WmsStorageHazard' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsStorageHazard') = 0
BEGIN
    CREATE TABLE WmsStorageHazard(
     StorageHazard            CHAR(20)            NOT NULL,
     Description              CHAR(60)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsStorageHazardKey PRIMARY KEY CLUSTERED
         (
          StorageHazard
         )
    )
    PRINT 'New table WmsStorageHazard'
END
GO

--  Add new 'WmsStorageSecurity' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'WmsStorageSecurity') = 0
BEGIN
    CREATE TABLE WmsStorageSecurity(
     StorageSecurity          CHAR(20)            NOT NULL,
     StorageSecurityLvl       DECIMAL(6,0)        NULL,
     Description              CHAR(60)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT WmsStorageSecurityKey PRIMARY KEY CLUSTERED
         (
          StorageSecurity
         )
    )
    CREATE UNIQUE INDEX WmsStorageSecurityIdxSecLevel ON WmsStorageSecurity(
     StorageSecurityLvl,
     StorageSecurity
     )
    PRINT 'New table WmsStorageSecurity'
END
GO

---------------------
-- New tables for 6.1

--  Add new 'MrpSplitLabAll' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'MrpSplitLabAll') = 0
BEGIN
    CREATE TABLE MrpSplitLabAll(
     Job                      CHAR(8)             NOT NULL,
     Operation                DECIMAL(4,0)        NOT NULL,
     OperationSplit           DECIMAL(3,0)        NOT NULL,
     SubcontractOp            CHAR(1)             NULL,
     IMachine                 CHAR(6)             NULL,
     IExpUnitRunTim           DECIMAL(9,4)        NULL,
     IExpSetUpTime            DECIMAL(9,4)        NULL,
     IExpStartupTime          DECIMAL(9,4)        NULL,
     IExpShutdownTim          DECIMAL(9,4)        NULL,
     IWaitTime                DECIMAL(9,4)        NULL,
     IWcRateInd               DECIMAL(1,0)        NULL,
     IStartupQty              DECIMAL(10,3)       NULL,
     ICapacityReqd            DECIMAL(10,3)       NULL,
     IMaxWorkOperators        DECIMAL(5,2)        NULL,
     IMaxProdUnits            DECIMAL(5,2)        NULL,
     SubLeadTime              DECIMAL(3,0)        NULL,
     SubDockToStock           DECIMAL(3,0)        NULL,
     SubOffsiteDays           DECIMAL(3,0)        NULL,
     OperationStatus          CHAR(1)             NULL,
     UnitValueReqd            DECIMAL(16,4)       NULL,
     RunTimeIssued            DECIMAL(7,2)        NULL,
     SetUpIssued              DECIMAL(7,2)        NULL,
     StartUpIssued            DECIMAL(7,2)        NULL,
     ShutdownIssued           DECIMAL(7,2)        NULL,
     ValueIssued              DECIMAL(14,2)       NULL,
     PiecesCompleted          DECIMAL(7,0)        NULL,
     OperCompleted            CHAR(1)             NULL,
     QtyCompleted             DECIMAL(10,3)       NULL,
     QtyScrapped              DECIMAL(10,3)       NULL,
     LastScrapReason          CHAR(2)             NULL,
     PlannedStartDate         DATETIME            NULL,
     PlannedEndDate           DATETIME            NULL,
     ScheduledStartDate       DATETIME            NULL,
     ScheduledStartTime       DECIMAL(4,0)        NULL,
     ScheduledEndDate         DATETIME            NULL,
     ScheduledEndTime         DECIMAL(4,0)        NULL,
     ActualStartDate          DATETIME            NULL,
     ActualFinishDate         DATETIME            NULL,
     WorkCentre               CHAR(6)             NULL,
     WorkCentreDesc           CHAR(30)            NULL,
     ElapsedTime              DECIMAL(3,0)        NULL,
     MovementTime             DECIMAL(3,0)        NULL,
     UnitNumOfPieces          DECIMAL(5,0)        NULL,
     ToolSet                  CHAR(15)            NULL,
     ToolSetQty               DECIMAL(10,3)       NULL,
     ToolConsumption          DECIMAL(8,0)        NULL,
     CapacityIssued           DECIMAL(10,3)       NULL,
     OpCompViaJob             CHAR(1)             NULL,
     TransferQtyOrPct         CHAR(1)             NULL,
     TransferQtyPct           DECIMAL(10,3)       NULL,
     ParentQtyPlanned         DECIMAL(10,3)       NULL,
     OperYieldPct             DECIMAL(4,2)        NULL,
     OperYieldQty             DECIMAL(7,3)        NULL,
     ParentIssQty             DECIMAL(10,3)       NULL,
     ITimeTaken               DECIMAL(9,4)        NULL,
     IQuantity                DECIMAL(10,3)       NULL,
     MaxOpSpan                DECIMAL(4,0)        NULL,
     OpSlack                  DECIMAL(4,0)        NULL,
     IStartupQtyEnt           DECIMAL(10,3)       NULL,
     IQuantityEnt             DECIMAL(10,3)       NULL,
     IExpUnitRunTimEnt        DECIMAL(9,4)        NULL,
     ITimeTakenEnt            DECIMAL(9,4)        NULL,
     QtyScrappedEnt           DECIMAL(10,3)       NULL,
     TransferQtyPctEnt        DECIMAL(10,3)       NULL,
     ParentQtyPlanEnt         DECIMAL(10,3)       NULL,
     OperYieldQtyEnt          DECIMAL(7,3)        NULL,
     ParIssQtyEnt             DECIMAL(10,3)       NULL,
     ResourceMask             CHAR(6)             NULL,
     SchStartRunDate          DATETIME            NULL,
     SchStartRunTime          DECIMAL(4,0)        NULL,
     ScheduledMachine         CHAR(6)             NULL,
     ScheduleStatus           CHAR(1)             NULL,
     OpSplitFlag              CHAR(1)             NULL,
     MaxOpDelay               DECIMAL(4,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT MrpSplitLabAllKey PRIMARY KEY CLUSTERED
         (
          Job,
          Operation,
          OperationSplit
         )
    )
    PRINT 'New table MrpSplitLabAll'
END
GO

--  Add new 'MrpSugSplitLabAll' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'MrpSugSplitLabAll') = 0
BEGIN
    CREATE TABLE MrpSugSplitLabAll(
     Job                      CHAR(8)             NOT NULL,
     Operation                DECIMAL(4,0)        NOT NULL,
     OperationSplit           DECIMAL(3,0)        NOT NULL,
     SubcontractOp            CHAR(1)             NULL,
     IMachine                 CHAR(6)             NULL,
     IExpUnitRunTim           DECIMAL(9,4)        NULL,
     IExpSetUpTime            DECIMAL(9,4)        NULL,
     IExpStartupTime          DECIMAL(9,4)        NULL,
     IExpShutdownTim          DECIMAL(9,4)        NULL,
     IWaitTime                DECIMAL(9,4)        NULL,
     IWcRateInd               DECIMAL(1,0)        NULL,
     IStartupQty              DECIMAL(10,3)       NULL,
     ICapacityReqd            DECIMAL(10,3)       NULL,
     IMaxWorkOperators        DECIMAL(5,2)        NULL,
     IMaxProdUnits            DECIMAL(5,2)        NULL,
     SubLeadTime              DECIMAL(3,0)        NULL,
     SubDockToStock           DECIMAL(3,0)        NULL,
     SubOffsiteDays           DECIMAL(3,0)        NULL,
     OperationStatus          CHAR(1)             NULL,
     UnitValueReqd            DECIMAL(16,4)       NULL,
     RunTimeIssued            DECIMAL(7,2)        NULL,
     SetUpIssued              DECIMAL(7,2)        NULL,
     StartUpIssued            DECIMAL(7,2)        NULL,
     ShutdownIssued           DECIMAL(7,2)        NULL,
     ValueIssued              DECIMAL(14,2)       NULL,
     PiecesCompleted          DECIMAL(7,0)        NULL,
     OperCompleted            CHAR(1)             NULL,
     QtyCompleted             DECIMAL(10,3)       NULL,
     QtyScrapped              DECIMAL(10,3)       NULL,
     LastScrapReason          CHAR(2)             NULL,
     PlannedStartDate         DATETIME            NULL,
     PlannedEndDate           DATETIME            NULL,
     ScheduledStartDate       DATETIME            NULL,
     ScheduledStartTime       DECIMAL(4,0)        NULL,
     ScheduledEndDate         DATETIME            NULL,
     ScheduledEndTime         DECIMAL(4,0)        NULL,
     ActualStartDate          DATETIME            NULL,
     ActualFinishDate         DATETIME            NULL,
     WorkCentre               CHAR(6)             NULL,
     WorkCentreDesc           CHAR(30)            NULL,
     ElapsedTime              DECIMAL(3,0)        NULL,
     MovementTime             DECIMAL(3,0)        NULL,
     UnitNumOfPieces          DECIMAL(5,0)        NULL,
     ToolSet                  CHAR(15)            NULL,
     ToolSetQty               DECIMAL(10,3)       NULL,
     ToolConsumption          DECIMAL(8,0)        NULL,
     CapacityIssued           DECIMAL(10,3)       NULL,
     OpCompViaJob             CHAR(1)             NULL,
     TransferQtyOrPct         CHAR(1)             NULL,
     TransferQtyPct           DECIMAL(10,3)       NULL,
     ParentQtyPlanned         DECIMAL(10,3)       NULL,
     OperYieldPct             DECIMAL(4,2)        NULL,
     OperYieldQty             DECIMAL(7,3)        NULL,
     ParentIssQty             DECIMAL(10,3)       NULL,
     ITimeTaken               DECIMAL(9,4)        NULL,
     IQuantity                DECIMAL(10,3)       NULL,
     MaxOpSpan                DECIMAL(4,0)        NULL,
     OpSlack                  DECIMAL(4,0)        NULL,
     IStartupQtyEnt           DECIMAL(10,3)       NULL,
     IQuantityEnt             DECIMAL(10,3)       NULL,
     IExpUnitRunTimEnt        DECIMAL(9,4)        NULL,
     ITimeTakenEnt            DECIMAL(9,4)        NULL,
     QtyScrappedEnt           DECIMAL(10,3)       NULL,
     TransferQtyPctEnt        DECIMAL(10,3)       NULL,
     ParentQtyPlanEnt         DECIMAL(10,3)       NULL,
     OperYieldQtyEnt          DECIMAL(7,3)        NULL,
     ParIssQtyEnt             DECIMAL(10,3)       NULL,
     ResourceMask             CHAR(6)             NULL,
     SchStartRunDate          DATETIME            NULL,
     SchStartRunTime          DECIMAL(4,0)        NULL,
     ScheduledMachine         CHAR(6)             NULL,
     ScheduleStatus           CHAR(1)             NULL,
     OpSplitFlag              CHAR(1)             NULL,
     MaxOpDelay               DECIMAL(4,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT MrpSugSplitLabAllKey PRIMARY KEY CLUSTERED
         (
          Job,
          Operation,
          OperationSplit
         )
    )
    PRINT 'New table MrpSugSplitLabAll'
END
GO


-------------------------------------------------------------------------
-- New columns

-- New column for table ApBank
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApBank' AND COLUMN_NAME = 'GlExchSeparate') = 0
BEGIN
  ALTER TABLE ApBank ADD GlExchSeparate char(1) NULL
  PRINT 'New column ApBank.GlExchSeparate'
END
GO
-- New column for table ApBank
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApBank' AND COLUMN_NAME = 'GlExchLossCode') = 0
BEGIN
  ALTER TABLE ApBank ADD GlExchLossCode char(15) NULL
  PRINT 'New column ApBank.GlExchLossCode'
END
GO
-- New column for table ApControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApControl' AND COLUMN_NAME = 'LowUnpJnlUpdYear') = 0
BEGIN
  ALTER TABLE ApControl ADD LowUnpJnlUpdYear decimal(4,0) NULL
  PRINT 'New column ApControl.LowUnpJnlUpdYear'
END
GO
-- New column for table ApControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApControl' AND COLUMN_NAME = 'LowUnpJnlUpdMonth') = 0
BEGIN
  ALTER TABLE ApControl ADD LowUnpJnlUpdMonth decimal(2,0) NULL
  PRINT 'New column ApControl.LowUnpJnlUpdMonth'
END
GO
-- New column for table ApControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApControl' AND COLUMN_NAME = 'LowUnpJnlUpd') = 0
BEGIN
  ALTER TABLE ApControl ADD LowUnpJnlUpd decimal(5,0) NULL
  PRINT 'New column ApControl.LowUnpJnlUpd'
END
GO
-- New column for table ApControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApControl' AND COLUMN_NAME = 'UnpExpUpdYear') = 0
BEGIN
  ALTER TABLE ApControl ADD UnpExpUpdYear decimal(4,0) NULL
  PRINT 'New column ApControl.UnpExpUpdYear'
END
GO
-- New column for table ApControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApControl' AND COLUMN_NAME = 'UnpExpUpdPeriod') = 0
BEGIN
  ALTER TABLE ApControl ADD UnpExpUpdPeriod decimal(2,0) NULL
  PRINT 'New column ApControl.UnpExpUpdPeriod'
END
GO
-- New column for table ApGlDisburse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApGlDisburse' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE ApGlDisburse ADD GlIntUpdated char(1) NULL
  PRINT 'New column ApGlDisburse.GlIntUpdated'
END
GO
-- New column for table ApGlDisburse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApGlDisburse' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE ApGlDisburse ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column ApGlDisburse.GlIntYear'
END
GO
-- New column for table ApGlDisburse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApGlDisburse' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE ApGlDisburse ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column ApGlDisburse.GlIntPeriod'
END
GO
-- New column for table ApGlDisburse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApGlDisburse' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE ApGlDisburse ADD GlJournal decimal(5,0) NULL
  PRINT 'New column ApGlDisburse.GlJournal'
END
GO
-- New column for table ApIntegrationCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApIntegrationCtl' AND COLUMN_NAME = 'GlExchSeparate') = 0
BEGIN
  ALTER TABLE ApIntegrationCtl ADD GlExchSeparate char(1) NULL
  PRINT 'New column ApIntegrationCtl.GlExchSeparate'
END
GO
-- New column for table ApIntegrationDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApIntegrationDet' AND COLUMN_NAME = 'GlExchLossCode') = 0
BEGIN
  ALTER TABLE ApIntegrationDet ADD GlExchLossCode char(15) NULL
  PRINT 'New column ApIntegrationDet.GlExchLossCode'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD GlIntUpdated char(1) NULL
  PRINT 'New column ApJnlSummary.GlIntUpdated'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD GlIntPrinted char(1) NULL
  PRINT 'New column ApJnlSummary.GlIntPrinted'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column ApJnlSummary.GlIntYear'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column ApJnlSummary.GlIntPeriod'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD GlJournal decimal(5,0) NULL
  PRINT 'New column ApJnlSummary.GlJournal'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'TrnDate') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD TrnDate datetime NULL
  PRINT 'New column ApJnlSummary.TrnDate'
END
GO
-- New column for table ApJnlSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApJnlSummary' AND COLUMN_NAME = 'AddReference') = 0
BEGIN
  ALTER TABLE ApJnlSummary ADD AddReference char(30) NULL
  PRINT 'New column ApJnlSummary.AddReference'
END
GO
-- New column for table ApSupplier
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApSupplier' AND COLUMN_NAME = 'RemitEmail') = 0
BEGIN
  ALTER TABLE ApSupplier ADD RemitEmail char(50) NULL
  PRINT 'New column ApSupplier.RemitEmail'
END
GO
-- New column for table ApPayRunDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApPayRunDet' AND COLUMN_NAME = 'WithTaxCode') = 0
BEGIN
  ALTER TABLE ApPayRunDet ADD WithTaxCode char(5) NULL
  PRINT 'New column ApPayRunDet.WithTaxCode'
END
GO
-- New column for table ApPayRunDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ApPayRunDet' AND COLUMN_NAME = 'WithTaxableValue') = 0
BEGIN
  ALTER TABLE ApPayRunDet ADD WithTaxableValue decimal(14,2) NULL
  PRINT 'New column ApPayRunDet.WithTaxableValue'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'ArUpdYear') = 0
BEGIN
  ALTER TABLE ArControl ADD ArUpdYear decimal(4,0) NULL
  PRINT 'New column ArControl.ArUpdYear'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'ArUpdMonth') = 0
BEGIN
  ALTER TABLE ArControl ADD ArUpdMonth decimal(2,0) NULL
  PRINT 'New column ArControl.ArUpdMonth'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'ArUpdJournal') = 0
BEGIN
  ALTER TABLE ArControl ADD ArUpdJournal decimal(5,0) NULL
  PRINT 'New column ArControl.ArUpdJournal'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'SaUpdYear') = 0
BEGIN
  ALTER TABLE ArControl ADD SaUpdYear decimal(4,0) NULL
  PRINT 'New column ArControl.SaUpdYear'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'SaUpdMonth') = 0
BEGIN
  ALTER TABLE ArControl ADD SaUpdMonth decimal(2,0) NULL
  PRINT 'New column ArControl.SaUpdMonth'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'SaUpdReg') = 0
BEGIN
  ALTER TABLE ArControl ADD SaUpdReg decimal(5,0) NULL
  PRINT 'New column ArControl.SaUpdReg'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'DtUpdYear') = 0
BEGIN
  ALTER TABLE ArControl ADD DtUpdYear decimal(4,0) NULL
  PRINT 'New column ArControl.DtUpdYear'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'DtUpdMonth') = 0
BEGIN
  ALTER TABLE ArControl ADD DtUpdMonth decimal(2,0) NULL
  PRINT 'New column ArControl.DtUpdMonth'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'DtUpdReg') = 0
BEGIN
  ALTER TABLE ArControl ADD DtUpdReg decimal(5,0) NULL
  PRINT 'New column ArControl.DtUpdReg'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'UnpBdsUpdYear') = 0
BEGIN
  ALTER TABLE ArControl ADD UnpBdsUpdYear decimal(4,0) NULL
  PRINT 'New column ArControl.UnpBdsUpdYear'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'UnpBdsUpdMonnth') = 0
BEGIN
  ALTER TABLE ArControl ADD UnpBdsUpdMonnth decimal(2,0) NULL
  PRINT 'New column ArControl.UnpBdsUpdMonnth'
END
GO
-- New column for table ArControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArControl' AND COLUMN_NAME = 'UnpBdsUpdRegister') = 0
BEGIN
  ALTER TABLE ArControl ADD UnpBdsUpdRegister decimal(5,0) NULL
  PRINT 'New column ArControl.UnpBdsUpdRegister'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'Sequence') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD Sequence decimal(6,0) NULL
  PRINT 'New column ArDiscDrCrDet.Sequence'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'CurrencyValue') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD CurrencyValue decimal(14,2) NULL
  PRINT 'New column ArDiscDrCrDet.CurrencyValue'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'PostCurrency') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD PostCurrency char(3) NULL
  PRINT 'New column ArDiscDrCrDet.PostCurrency'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'ConvRate') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD ConvRate decimal(12,6) NULL
  PRINT 'New column ArDiscDrCrDet.ConvRate'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'MulDiv') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD MulDiv char(1) NULL
  PRINT 'New column ArDiscDrCrDet.MulDiv'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'AccountCur') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD AccountCur char(3) NULL
  PRINT 'New column ArDiscDrCrDet.AccountCur'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'AccConvRate') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD AccConvRate decimal(12,6) NULL
  PRINT 'New column ArDiscDrCrDet.AccConvRate'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'AccMulDiv') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD AccMulDiv char(1) NULL
  PRINT 'New column ArDiscDrCrDet.AccMulDiv'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'TriangCurrency') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD TriangCurrency char(3) NULL
  PRINT 'New column ArDiscDrCrDet.TriangCurrency'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'TriangRate') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD TriangRate decimal(12,6) NULL
  PRINT 'New column ArDiscDrCrDet.TriangRate'
END
GO
-- New column for table ArDiscDrCrDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'TriangMulDiv') = 0
BEGIN
  ALTER TABLE ArDiscDrCrDet ADD TriangMulDiv char(1) NULL
  PRINT 'New column ArDiscDrCrDet.TriangMulDiv'
END
GO
-- New column for table ArIntegrationCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArIntegrationCtl' AND COLUMN_NAME = 'GlExchSeparate') = 0
BEGIN
  ALTER TABLE ArIntegrationCtl ADD GlExchSeparate char(1) NULL
  PRINT 'New column ArIntegrationCtl.GlExchSeparate'
END
GO
-- New column for table ArIntegrationDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArIntegrationDet' AND COLUMN_NAME = 'GlExchLossCode') = 0
BEGIN
  ALTER TABLE ArIntegrationDet ADD GlExchLossCode char(15) NULL
  PRINT 'New column ArIntegrationDet.GlExchLossCode'
END
GO
-- New column for table ArInvoice
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArInvoice' AND COLUMN_NAME = 'DiscBal') = 0
BEGIN
  ALTER TABLE ArInvoice ADD DiscBal decimal(14,2) NULL
  PRINT 'New column ArInvoice.DiscBal'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'AdjustmentGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD AdjustmentGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.AdjustmentGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'CashGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD CashGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.CashGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'PaymentGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD PaymentGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.PaymentGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'DepositGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD DepositGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.DepositGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'WthTaxGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD WthTaxGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.WthTaxGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'TaxGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD TaxGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.TaxGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'DiscountGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD DiscountGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.DiscountGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'SalesCtlTaxGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD SalesCtlTaxGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.SalesCtlTaxGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'BankChargeGlCode') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD BankChargeGlCode char(15) NULL
  PRINT 'New column ArCshJnlDet.BankChargeGlCode'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'AdjustmentAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD AdjustmentAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.AdjustmentAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'CashAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD CashAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.CashAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'PaymentAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD PaymentAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.PaymentAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'DepositAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD DepositAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.DepositAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'WthTaxAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD WthTaxAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.WthTaxAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'TaxAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD TaxAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.TaxAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'DiscountAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD DiscountAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.DiscountAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'SlsCtlTaxAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD SlsCtlTaxAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.SlsCtlTaxAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'BankChargeAnaEntry') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD BankChargeAnaEntry decimal(7,0) NULL
  PRINT 'New column ArCshJnlDet.BankChargeAnaEntry'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD GlIntUpdated char(1) NULL
  PRINT 'New column ArCshJnlDet.GlIntUpdated'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD GlIntPrinted char(1) NULL
  PRINT 'New column ArCshJnlDet.GlIntPrinted'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column ArCshJnlDet.GlIntYear'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column ArCshJnlDet.GlIntPeriod'
END
GO
-- New column for table ArCshJnlDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCshJnlDet' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE ArCshJnlDet ADD GlJournal decimal(5,0) NULL
  PRINT 'New column ArCshJnlDet.GlJournal'
END
GO
-- New column for table ArCustomer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCustomer' AND COLUMN_NAME = 'UkVatFlag') = 0
BEGIN
  ALTER TABLE ArCustomer ADD UkVatFlag char(1) NULL
  PRINT 'New column ArCustomer.UkVatFlag'
END
GO
-- New column for table ArCustomer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArCustomer' AND COLUMN_NAME = 'UkCurrency') = 0
BEGIN
  ALTER TABLE ArCustomer ADD UkCurrency char(3) NULL
  PRINT 'New column ArCustomer.UkCurrency'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'TransactionGlCode') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD TransactionGlCode char(15) NULL
  PRINT 'New column ArTrnDetail.TransactionGlCode'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'DiscountGlCode') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD DiscountGlCode char(15) NULL
  PRINT 'New column ArTrnDetail.DiscountGlCode'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'CostGlCode') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD CostGlCode char(15) NULL
  PRINT 'New column ArTrnDetail.CostGlCode'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD GlIntUpdated char(1) NULL
  PRINT 'New column ArTrnDetail.GlIntUpdated'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD GlIntPrinted char(1) NULL
  PRINT 'New column ArTrnDetail.GlIntPrinted'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column ArTrnDetail.GlIntYear'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column ArTrnDetail.GlIntPeriod'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD GlJournal decimal(5,0) NULL
  PRINT 'New column ArTrnDetail.GlJournal'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'ControlType') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD ControlType char(1) NULL
  PRINT 'New column ArTrnDetail.ControlType'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'TranAnalysisEntry') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD TranAnalysisEntry decimal(7,0) NULL
  PRINT 'New column ArTrnDetail.TranAnalysisEntry'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'DscAnalysisEntry') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD DscAnalysisEntry decimal(7,0) NULL
  PRINT 'New column ArTrnDetail.DscAnalysisEntry'
END
GO
-- New column for table ArTrnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnDetail' AND COLUMN_NAME = 'CstAnalysisEntry') = 0
BEGIN
  ALTER TABLE ArTrnDetail ADD CstAnalysisEntry decimal(7,0) NULL
  PRINT 'New column ArTrnDetail.CstAnalysisEntry'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'DispatchAccount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD DispatchAccount char(15) NULL
  PRINT 'New column ArTrnSummary.DispatchAccount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'DisAnalysisEntry') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD DisAnalysisEntry decimal(7,0) NULL
  PRINT 'New column ArTrnSummary.DisAnalysisEntry'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'DispatchAmount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD DispatchAmount decimal(14,2) NULL
  PRINT 'New column ArTrnSummary.DispatchAmount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'WarehouseAccount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD WarehouseAccount char(15) NULL
  PRINT 'New column ArTrnSummary.WarehouseAccount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'WhAnalysisEntry') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD WhAnalysisEntry decimal(7,0) NULL
  PRINT 'New column ArTrnSummary.WhAnalysisEntry'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'WarehouseAmount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD WarehouseAmount decimal(14,2) NULL
  PRINT 'New column ArTrnSummary.WarehouseAmount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'BranchSalesAccount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD BranchSalesAccount char(15) NULL
  PRINT 'New column ArTrnSummary.BranchSalesAccount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'BrSalesAnaEntry') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD BrSalesAnaEntry decimal(7,0) NULL
  PRINT 'New column ArTrnSummary.BrSalesAnaEntry'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'BranchSalesAmount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD BranchSalesAmount decimal(14,2) NULL
  PRINT 'New column ArTrnSummary.BranchSalesAmount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'BranchCostAccount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD BranchCostAccount char(15) NULL
  PRINT 'New column ArTrnSummary.BranchCostAccount'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'BrCstAnalysisEntry') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD BrCstAnalysisEntry decimal(7,0) NULL
  PRINT 'New column ArTrnSummary.BrCstAnalysisEntry'
END
GO
-- New column for table ArTrnSummary
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnSummary' AND COLUMN_NAME = 'BranchCostAmount') = 0
BEGIN
  ALTER TABLE ArTrnSummary ADD BranchCostAmount decimal(14,2) NULL
  PRINT 'New column ArTrnSummary.BranchCostAmount'
END
GO
-- New column for table ArTrnTax
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArTrnTax' AND COLUMN_NAME = 'UkVatFlag') = 0
BEGIN
  ALTER TABLE ArTrnTax ADD UkVatFlag char(1) NULL
  PRINT 'New column ArTrnTax.UkVatFlag'
END
GO
-- New column for table ArInvoicePay
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ArInvoicePay' AND COLUMN_NAME = 'Branch') = 0
BEGIN
  ALTER TABLE ArInvoicePay ADD Branch char(2) NULL
  PRINT 'New column ArInvoicePay.Branch'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPeriodsTx') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPeriodsTx decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPeriodsTx'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt1') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt1 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt1'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt2') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt2 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt2'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt3') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt3 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt3'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt4') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt4 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt4'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt5') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt5 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt5'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt6') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt6 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt6'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt7') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt7 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt7'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt8') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt8 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt8'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt9') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt9 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt9'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistEntPrdsAlt10') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistEntPrdsAlt10 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistEntPrdsAlt10'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsBv') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsBv decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsBv'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsTax') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsTax decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsTax'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt1') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt1 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt1'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt2') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt2 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt2'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt3') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt3 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt3'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt4') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt4 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt4'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt5') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt5 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt5'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt6') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt6 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt6'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt7') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt7 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt7'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt8') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt8 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt8'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt9') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt9 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt9'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'HistoryYearsAlt10') = 0
BEGIN
  ALTER TABLE AssetControl ADD HistoryYearsAlt10 decimal(3,0) NULL
  PRINT 'New column AssetControl.HistoryYearsAlt10'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead4') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead4 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead4'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead5') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead5 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead5'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead6') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead6 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead6'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead7') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead7 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead7'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead8') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead8 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead8'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead9') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead9 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead9'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'ValuationHead10') = 0
BEGIN
  ALTER TABLE AssetControl ADD ValuationHead10 char(20) NULL
  PRINT 'New column AssetControl.ValuationHead10'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'DateConvDef') = 0
BEGIN
  ALTER TABLE AssetControl ADD DateConvDef char(1) NULL
  PRINT 'New column AssetControl.DateConvDef'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'BvConvention') = 0
BEGIN
  ALTER TABLE AssetControl ADD BvConvention char(1) NULL
  PRINT 'New column AssetControl.BvConvention'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'TaxConvention') = 0
BEGIN
  ALTER TABLE AssetControl ADD TaxConvention char(1) NULL
  PRINT 'New column AssetControl.TaxConvention'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention1') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention1 char(1) NULL
  PRINT 'New column AssetControl.AltConvention1'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention2') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention2 char(1) NULL
  PRINT 'New column AssetControl.AltConvention2'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention3') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention3 char(1) NULL
  PRINT 'New column AssetControl.AltConvention3'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention4') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention4 char(1) NULL
  PRINT 'New column AssetControl.AltConvention4'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention5') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention5 char(1) NULL
  PRINT 'New column AssetControl.AltConvention5'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention6') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention6 char(1) NULL
  PRINT 'New column AssetControl.AltConvention6'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention7') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention7 char(1) NULL
  PRINT 'New column AssetControl.AltConvention7'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention8') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention8 char(1) NULL
  PRINT 'New column AssetControl.AltConvention8'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention9') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention9 char(1) NULL
  PRINT 'New column AssetControl.AltConvention9'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltConvention10') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltConvention10 char(1) NULL
  PRINT 'New column AssetControl.AltConvention10'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'TaxBasis') = 0
BEGIN
  ALTER TABLE AssetControl ADD TaxBasis char(1) NULL
  PRINT 'New column AssetControl.TaxBasis'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis1') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis1 char(1) NULL
  PRINT 'New column AssetControl.AltBasis1'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis2') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis2 char(1) NULL
  PRINT 'New column AssetControl.AltBasis2'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis3') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis3 char(1) NULL
  PRINT 'New column AssetControl.AltBasis3'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis4') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis4 char(1) NULL
  PRINT 'New column AssetControl.AltBasis4'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis5') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis5 char(1) NULL
  PRINT 'New column AssetControl.AltBasis5'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis6') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis6 char(1) NULL
  PRINT 'New column AssetControl.AltBasis6'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis7') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis7 char(1) NULL
  PRINT 'New column AssetControl.AltBasis7'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis8') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis8 char(1) NULL
  PRINT 'New column AssetControl.AltBasis8'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis9') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis9 char(1) NULL
  PRINT 'New column AssetControl.AltBasis9'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'AltBasis10') = 0
BEGIN
  ALTER TABLE AssetControl ADD AltBasis10 char(1) NULL
  PRINT 'New column AssetControl.AltBasis10'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'NextAsset') = 0
BEGIN
  ALTER TABLE AssetControl ADD NextAsset char(15) NULL
  PRINT 'New column AssetControl.NextAsset'
END
GO
-- New column for table AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'NextCapex') = 0
BEGIN
  ALTER TABLE AssetControl ADD NextCapex char(15) NULL
  PRINT 'New column AssetControl.NextCapex'
END
GO
-- New column for table AssetDepreciation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'AnnualDepnPct') = 0
BEGIN
  ALTER TABLE AssetDepreciation ADD AnnualDepnPct decimal(7,4) NULL
  PRINT 'New column AssetDepreciation.AnnualDepnPct'
END
GO
-- New column for table AssetDepreciation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'DateConvention') = 0
BEGIN
  ALTER TABLE AssetDepreciation ADD DateConvention char(1) NULL
  PRINT 'New column AssetDepreciation.DateConvention'
END
GO
-- New column for table AssetDepreciation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'StatGlCode') = 0
BEGIN
  ALTER TABLE AssetDepreciation ADD StatGlCode char(15) NULL
  PRINT 'New column AssetDepreciation.StatGlCode'
END
GO
-- New column for table AssetDepreciation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'NumberOfYears') = 0
BEGIN
  ALTER TABLE AssetDepreciation ADD NumberOfYears decimal(4,0) NULL
  PRINT 'New column AssetDepreciation.NumberOfYears'
END
GO
-- New column for table AssetDepreciation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'ThruputEul') = 0
BEGIN
  ALTER TABLE AssetDepreciation ADD ThruputEul decimal(14,2) NULL
  PRINT 'New column AssetDepreciation.ThruputEul'
END
GO
-- New column for table AssetDepreciation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'VaryingAnniversary') = 0
BEGIN
  ALTER TABLE AssetDepreciation ADD VaryingAnniversary char(1) NULL
  PRINT 'New column AssetDepreciation.VaryingAnniversary'
END
GO
-- New column for table AssetDistReg
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDistReg' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE AssetDistReg ADD GlIntUpdated char(1) NULL
  PRINT 'New column AssetDistReg.GlIntUpdated'
END
GO
-- New column for table AssetDistReg
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDistReg' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE AssetDistReg ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column AssetDistReg.GlIntYear'
END
GO
-- New column for table AssetDistReg
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDistReg' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE AssetDistReg ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column AssetDistReg.GlIntPeriod'
END
GO
-- New column for table AssetDistReg
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetDistReg' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE AssetDistReg ADD GlJournal decimal(5,0) NULL
  PRINT 'New column AssetDistReg.GlJournal'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinTax') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinTax decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinTax'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt1') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt1 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt1'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt2') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt2 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt2'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt3') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt3 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt3'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt4') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt4 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt4'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt5') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt5 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt5'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt6') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt6 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt6'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt7') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt7 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt7'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt8') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt8 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt8'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt9') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt9 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt9'
END
GO
-- New column for table AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'MinAlt10') = 0
BEGIN
  ALTER TABLE AssetGroup ADD MinAlt10 decimal(14,2) NULL
  PRINT 'New column AssetGroup.MinAlt10'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'DepPrdYearSold') = 0
BEGIN
  ALTER TABLE AssetMaster ADD DepPrdYearSold decimal(4,0) NULL
  PRINT 'New column AssetMaster.DepPrdYearSold'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'PurchasePeriod') = 0
BEGIN
  ALTER TABLE AssetMaster ADD PurchasePeriod decimal(2,0) NULL
  PRINT 'New column AssetMaster.PurchasePeriod'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'PurchaseYear') = 0
BEGIN
  ALTER TABLE AssetMaster ADD PurchaseYear decimal(4,0) NULL
  PRINT 'New column AssetMaster.PurchaseYear'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'DisposedFlag') = 0
BEGIN
  ALTER TABLE AssetMaster ADD DisposedFlag char(1) NULL
  PRINT 'New column AssetMaster.DisposedFlag'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag1') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag1 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag1'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag2') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag2 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag2'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag3') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag3 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag3'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag4') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag4 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag4'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag5') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag5 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag5'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag6') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag6 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag6'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag7') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag7 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag7'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag8') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag8 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag8'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag9') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag9 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag9'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'AltFlag10') = 0
BEGIN
  ALTER TABLE AssetMaster ADD AltFlag10 char(1) NULL
  PRINT 'New column AssetMaster.AltFlag10'
END
GO
-- New column for table AssetMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'DisposalReason') = 0
BEGIN
  ALTER TABLE AssetMaster ADD DisposalReason char(6) NULL
  PRINT 'New column AssetMaster.DisposalReason'
END
GO
-- New column for table BomCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomCoProducts' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE BomCoProducts ADD QtyPerEnt decimal(10,3) NULL
  PRINT 'New column BomCoProducts.QtyPerEnt'
END
GO
-- New column for table BomAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomAmendmentJnl' AND COLUMN_NAME = 'OldQtyPerEnt') = 0
BEGIN
  ALTER TABLE BomAmendmentJnl ADD OldQtyPerEnt decimal(12,6) NULL
  PRINT 'New column BomAmendmentJnl.OldQtyPerEnt'
END
GO
-- New column for table BomAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomAmendmentJnl' AND COLUMN_NAME = 'OldScrapQtyEnt') = 0
BEGIN
  ALTER TABLE BomAmendmentJnl ADD OldScrapQtyEnt decimal(7,3) NULL
  PRINT 'New column BomAmendmentJnl.OldScrapQtyEnt'
END
GO
-- New column for table BomAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomAmendmentJnl' AND COLUMN_NAME = 'OldFixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE BomAmendmentJnl ADD OldFixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column BomAmendmentJnl.OldFixedQtyPerEnt'
END
GO
-- New column for table BomAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomAmendmentJnl' AND COLUMN_NAME = 'NewQtyPerEnt') = 0
BEGIN
  ALTER TABLE BomAmendmentJnl ADD NewQtyPerEnt decimal(12,6) NULL
  PRINT 'New column BomAmendmentJnl.NewQtyPerEnt'
END
GO
-- New column for table BomAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomAmendmentJnl' AND COLUMN_NAME = 'NewScrapQtyEnt') = 0
BEGIN
  ALTER TABLE BomAmendmentJnl ADD NewScrapQtyEnt decimal(7,3) NULL
  PRINT 'New column BomAmendmentJnl.NewScrapQtyEnt'
END
GO
-- New column for table BomAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomAmendmentJnl' AND COLUMN_NAME = 'NewFixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE BomAmendmentJnl ADD NewFixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column BomAmendmentJnl.NewFixedQtyPerEnt'
END
GO
-- New column for table BomStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomStructure' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE BomStructure ADD QtyPerEnt decimal(12,6) NULL
  PRINT 'New column BomStructure.QtyPerEnt'
END
GO
-- New column for table BomStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomStructure' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE BomStructure ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column BomStructure.ScrapQuantityEnt'
END
GO
-- New column for table BomStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomStructure' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE BomStructure ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column BomStructure.FixedQtyPerEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'IRunTimeEnt') = 0
BEGIN
  ALTER TABLE BomOperations ADD IRunTimeEnt decimal(9,4) NULL
  PRINT 'New column BomOperations.IRunTimeEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE BomOperations ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column BomOperations.ITimeTakenEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE BomOperations ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column BomOperations.IStartupQtyEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'IQuantityEnt') = 0
BEGIN
  ALTER TABLE BomOperations ADD IQuantityEnt decimal(10,3) NULL
  PRINT 'New column BomOperations.IQuantityEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE BomOperations ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column BomOperations.OperYieldQtyEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE BomOperations ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column BomOperations.TransferQtyPctEnt'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'MaxOpSpan') = 0
BEGIN
  ALTER TABLE BomOperations ADD MaxOpSpan decimal(4,0) NULL
  PRINT 'New column BomOperations.MaxOpSpan'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'OpSlack') = 0
BEGIN
  ALTER TABLE BomOperations ADD OpSlack decimal(4,0) NULL
  PRINT 'New column BomOperations.OpSlack'
END
GO
-- New column for table BomOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'BomOperations' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE BomOperations ADD AllowOpSplit char(1) NULL
  PRINT 'New column BomOperations.AllowOpSplit'
END
GO
-- New column for table CrmAccount
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CrmAccount' AND COLUMN_NAME = 'Supplier') = 0
BEGIN
  ALTER TABLE CrmAccount ADD Supplier char(7) NULL
  PRINT 'New column CrmAccount.Supplier'
END
GO
-- New column for table CrmActivity
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CrmActivity' AND COLUMN_NAME = 'UserField1') = 0
BEGIN
  ALTER TABLE CrmActivity ADD UserField1 char(50) NULL
  PRINT 'New column CrmActivity.UserField1'
END
GO
-- New column for table CrmActivity
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CrmActivity' AND COLUMN_NAME = 'UserField2') = 0
BEGIN
  ALTER TABLE CrmActivity ADD UserField2 char(50) NULL
  PRINT 'New column CrmActivity.UserField2'
END
GO
-- New column for table CrmActivity
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CrmActivity' AND COLUMN_NAME = 'UserField3') = 0
BEGIN
  ALTER TABLE CrmActivity ADD UserField3 char(50) NULL
  PRINT 'New column CrmActivity.UserField3'
END
GO
-- New column for table CshApPayments
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshApPayments' AND COLUMN_NAME = 'Cheque') = 0
BEGIN
  ALTER TABLE CshApPayments ADD Cheque decimal(6,0) NULL
  PRINT 'New column CshApPayments.Cheque'
END
GO
-- New column for table CshTransactionsBal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshTransactionsBal' AND COLUMN_NAME = 'CbTrnBal3') = 0
BEGIN
  ALTER TABLE CshTransactionsBal ADD CbTrnBal3 decimal(14,2) NULL
  PRINT 'New column CshTransactionsBal.CbTrnBal3'
END
GO
-- New column for table CshTransactionsBal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshTransactionsBal' AND COLUMN_NAME = 'CbTrnForBal3') = 0
BEGIN
  ALTER TABLE CshTransactionsBal ADD CbTrnForBal3 decimal(14,2) NULL
  PRINT 'New column CshTransactionsBal.CbTrnForBal3'
END
GO
-- New column for table CshControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshControl' AND COLUMN_NAME = 'UnpGlIntPrintYear') = 0
BEGIN
  ALTER TABLE CshControl ADD UnpGlIntPrintYear decimal(4,0) NULL
  PRINT 'New column CshControl.UnpGlIntPrintYear'
END
GO
-- New column for table CshControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshControl' AND COLUMN_NAME = 'UnpGlIntPrintMonth') = 0
BEGIN
  ALTER TABLE CshControl ADD UnpGlIntPrintMonth decimal(2,0) NULL
  PRINT 'New column CshControl.UnpGlIntPrintMonth'
END
GO
-- New column for table CshControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshControl' AND COLUMN_NAME = 'UnpGlIntPrintJnl') = 0
BEGIN
  ALTER TABLE CshControl ADD UnpGlIntPrintJnl decimal(4,0) NULL
  PRINT 'New column CshControl.UnpGlIntPrintJnl'
END
GO
-- New column for table CshJnlCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshJnlCtl' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE CshJnlCtl ADD GlIntUpdated char(1) NULL
  PRINT 'New column CshJnlCtl.GlIntUpdated'
END
GO
-- New column for table CshJnlCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshJnlCtl' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE CshJnlCtl ADD GlIntPrinted char(1) NULL
  PRINT 'New column CshJnlCtl.GlIntPrinted'
END
GO
-- New column for table CshJnlCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshJnlCtl' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE CshJnlCtl ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column CshJnlCtl.GlIntYear'
END
GO
-- New column for table CshJnlCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshJnlCtl' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE CshJnlCtl ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column CshJnlCtl.GlIntPeriod'
END
GO
-- New column for table CshJnlCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'CshJnlCtl' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE CshJnlCtl ADD GlJournal decimal(5,0) NULL
  PRINT 'New column CshJnlCtl.GlJournal'
END
GO
-- New column for table EccCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccCoProducts' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE EccCoProducts ADD QtyPerEnt decimal(10,3) NULL
  PRINT 'New column EccCoProducts.QtyPerEnt'
END
GO
-- New column for table EccAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccAmendmentJnl' AND COLUMN_NAME = 'OldQtyPerEnt') = 0
BEGIN
  ALTER TABLE EccAmendmentJnl ADD OldQtyPerEnt decimal(12,6) NULL
  PRINT 'New column EccAmendmentJnl.OldQtyPerEnt'
END
GO
-- New column for table EccAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccAmendmentJnl' AND COLUMN_NAME = 'OldScrapQtyEnt') = 0
BEGIN
  ALTER TABLE EccAmendmentJnl ADD OldScrapQtyEnt decimal(7,3) NULL
  PRINT 'New column EccAmendmentJnl.OldScrapQtyEnt'
END
GO
-- New column for table EccAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccAmendmentJnl' AND COLUMN_NAME = 'OldFixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE EccAmendmentJnl ADD OldFixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column EccAmendmentJnl.OldFixedQtyPerEnt'
END
GO
-- New column for table EccAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccAmendmentJnl' AND COLUMN_NAME = 'NewQtyPerEnt') = 0
BEGIN
  ALTER TABLE EccAmendmentJnl ADD NewQtyPerEnt decimal(12,6) NULL
  PRINT 'New column EccAmendmentJnl.NewQtyPerEnt'
END
GO
-- New column for table EccAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccAmendmentJnl' AND COLUMN_NAME = 'NewScrapQtyEnt') = 0
BEGIN
  ALTER TABLE EccAmendmentJnl ADD NewScrapQtyEnt decimal(7,3) NULL
  PRINT 'New column EccAmendmentJnl.NewScrapQtyEnt'
END
GO
-- New column for table EccAmendmentJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccAmendmentJnl' AND COLUMN_NAME = 'NewFixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE EccAmendmentJnl ADD NewFixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column EccAmendmentJnl.NewFixedQtyPerEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE EccOperations ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column EccOperations.IStartupQtyEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'IQuantityEnt') = 0
BEGIN
  ALTER TABLE EccOperations ADD IQuantityEnt decimal(10,3) NULL
  PRINT 'New column EccOperations.IQuantityEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'IRunTimeEnt') = 0
BEGIN
  ALTER TABLE EccOperations ADD IRunTimeEnt decimal(9,4) NULL
  PRINT 'New column EccOperations.IRunTimeEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE EccOperations ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column EccOperations.ITimeTakenEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE EccOperations ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column EccOperations.OperYieldQtyEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE EccOperations ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column EccOperations.TransferQtyPctEnt'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'MaxOpSpan') = 0
BEGIN
  ALTER TABLE EccOperations ADD MaxOpSpan decimal(4,0) NULL
  PRINT 'New column EccOperations.MaxOpSpan'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'OpSlack') = 0
BEGIN
  ALTER TABLE EccOperations ADD OpSlack decimal(4,0) NULL
  PRINT 'New column EccOperations.OpSlack'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'MaxOpDelay') = 0
BEGIN
  ALTER TABLE EccOperations ADD MaxOpDelay decimal(4,0) NULL
  PRINT 'New column EccOperations.MaxOpDelay'
END
GO
-- New column for table EccOperations
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccOperations' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE EccOperations ADD AllowOpSplit char(1) NULL
  PRINT 'New column EccOperations.AllowOpSplit'
END
GO
-- New column for table EccStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccStructure' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE EccStructure ADD QtyPerEnt decimal(12,6) NULL
  PRINT 'New column EccStructure.QtyPerEnt'
END
GO
-- New column for table EccStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccStructure' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE EccStructure ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column EccStructure.ScrapQuantityEnt'
END
GO
-- New column for table EccStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'EccStructure' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE EccStructure ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column EccStructure.FixedQtyPerEnt'
END
GO
-- New column for table GenJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalCtl' AND COLUMN_NAME = 'JournalSource') = 0
BEGIN
  ALTER TABLE GenJournalCtl ADD JournalSource char(2) NULL
  PRINT 'New column GenJournalCtl.JournalSource'
END
GO
-- New column for table GenJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalCtl' AND COLUMN_NAME = 'Type') = 0
BEGIN
  ALTER TABLE GenJournalCtl ADD Type char(4) NULL
  PRINT 'New column GenJournalCtl.Type'
END
GO
-- New column for table GenJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalCtl' AND COLUMN_NAME = 'PostDate') = 0
BEGIN
  ALTER TABLE GenJournalCtl ADD PostDate datetime NULL
  PRINT 'New column GenJournalCtl.PostDate'
END
GO
-- New column for table GenJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalCtl' AND COLUMN_NAME = 'SourceJournal') = 0
BEGIN
  ALTER TABLE GenJournalCtl ADD SourceJournal decimal(5,0) NULL
  PRINT 'New column GenJournalCtl.SourceJournal'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'Source') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD Source char(2) NULL
  PRINT 'New column GenJournalDetail.Source'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'Type') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD Type char(4) NULL
  PRINT 'New column GenJournalDetail.Type'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'SourceAp') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD SourceAp char(1) NULL
  PRINT 'New column GenJournalDetail.SourceAp'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'SourceJournal') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD SourceJournal char(40) NULL
  PRINT 'New column GenJournalDetail.SourceJournal'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'ModifiedFlag') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD ModifiedFlag char(1) NULL
  PRINT 'New column GenJournalDetail.ModifiedFlag'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'AddReference2') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD AddReference2 char(20) NULL
  PRINT 'New column GenJournalDetail.AddReference2'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'CommitmentFlag') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD CommitmentFlag char(1) NULL
  PRINT 'New column GenJournalDetail.CommitmentFlag'
END
GO
-- New column for table GenJournalDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'TransactionDate') = 0
BEGIN
  ALTER TABLE GenJournalDetail ADD TransactionDate datetime NULL
  PRINT 'New column GenJournalDetail.TransactionDate'
END
GO
-- New column for table GenMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenMaster' AND COLUMN_NAME = 'RetEarnsAccount') = 0
BEGIN
  ALTER TABLE GenMaster ADD RetEarnsAccount char(15) NULL
  PRINT 'New column GenMaster.RetEarnsAccount'
END
GO
-- New column for table GenMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenMaster' AND COLUMN_NAME = 'TaxAccount') = 0
BEGIN
  ALTER TABLE GenMaster ADD TaxAccount char(1) NULL
  PRINT 'New column GenMaster.TaxAccount'
END
GO
-- New column for table GenMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenMaster' AND COLUMN_NAME = 'InterestAccount') = 0
BEGIN
  ALTER TABLE GenMaster ADD InterestAccount char(1) NULL
  PRINT 'New column GenMaster.InterestAccount'
END
GO
-- New column for table GenCopyMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenCopyMaster' AND COLUMN_NAME = 'RetEarnsAccount') = 0
BEGIN
  ALTER TABLE GenCopyMaster ADD RetEarnsAccount char(15) NULL
  PRINT 'New column GenCopyMaster.RetEarnsAccount'
END
GO
-- New column for table GenCopyMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenCopyMaster' AND COLUMN_NAME = 'TaxAccount') = 0
BEGIN
  ALTER TABLE GenCopyMaster ADD TaxAccount char(1) NULL
  PRINT 'New column GenCopyMaster.TaxAccount'
END
GO
-- New column for table GenCopyMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenCopyMaster' AND COLUMN_NAME = 'InterestAccount') = 0
BEGIN
  ALTER TABLE GenCopyMaster ADD InterestAccount char(1) NULL
  PRINT 'New column GenCopyMaster.InterestAccount'
END
GO
-- New column for table GenSection
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenSection' AND COLUMN_NAME = 'RetEarnsAccount') = 0
BEGIN
  ALTER TABLE GenSection ADD RetEarnsAccount char(15) NULL
  PRINT 'New column GenSection.RetEarnsAccount'
END
GO
-- New column for table GenSection
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenSection' AND COLUMN_NAME = 'TaxAccount') = 0
BEGIN
  ALTER TABLE GenSection ADD TaxAccount char(1) NULL
  PRINT 'New column GenSection.TaxAccount'
END
GO
-- New column for table GenSection
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenSection' AND COLUMN_NAME = 'InterestAccount') = 0
BEGIN
  ALTER TABLE GenSection ADD InterestAccount char(1) NULL
  PRINT 'New column GenSection.InterestAccount'
END
GO
-- New column for table GenTransaction
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenTransaction' AND COLUMN_NAME = 'Reconciled') = 0
BEGIN
  ALTER TABLE GenTransaction ADD Reconciled char(1) NULL
  PRINT 'New column GenTransaction.Reconciled'
END
GO
-- New column for table GenTransaction
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenTransaction' AND COLUMN_NAME = 'TransactionDate') = 0
BEGIN
  ALTER TABLE GenTransaction ADD TransactionDate datetime NULL
  PRINT 'New column GenTransaction.TransactionDate'
END
GO
-- New column for table GenTransaction
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenTransaction' AND COLUMN_NAME = 'AlternateRate') = 0
BEGIN
  ALTER TABLE GenTransaction ADD AlternateRate decimal(12,6) NULL
  PRINT 'New column GenTransaction.AlternateRate'
END
GO
-- New column for table GenCopyTrans
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenCopyTrans' AND COLUMN_NAME = 'Reconciled') = 0
BEGIN
  ALTER TABLE GenCopyTrans ADD Reconciled char(1) NULL
  PRINT 'New column GenCopyTrans.Reconciled'
END
GO
-- New column for table GenCopyTrans
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenCopyTrans' AND COLUMN_NAME = 'TransactionDate') = 0
BEGIN
  ALTER TABLE GenCopyTrans ADD TransactionDate datetime NULL
  PRINT 'New column GenCopyTrans.TransactionDate'
END
GO
-- New column for table GenCopyTrans
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GenCopyTrans' AND COLUMN_NAME = 'AlternateRate') = 0
BEGIN
  ALTER TABLE GenCopyTrans ADD AlternateRate decimal(12,6) NULL
  PRINT 'New column GenCopyTrans.AlternateRate'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE GrnJournal ADD GlIntUpdated char(1) NULL
  PRINT 'New column GrnJournal.GlIntUpdated'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE GrnJournal ADD GlIntPrinted char(1) NULL
  PRINT 'New column GrnJournal.GlIntPrinted'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE GrnJournal ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column GrnJournal.GlIntYear'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE GrnJournal ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column GrnJournal.GlIntPeriod'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE GrnJournal ADD GlJournal decimal(5,0) NULL
  PRINT 'New column GrnJournal.GlJournal'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'ControlGlCode') = 0
BEGIN
  ALTER TABLE GrnJournal ADD ControlGlCode char(15) NULL
  PRINT 'New column GrnJournal.ControlGlCode'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'TransactionAnaEnt') = 0
BEGIN
  ALTER TABLE GrnJournal ADD TransactionAnaEnt decimal(7,0) NULL
  PRINT 'New column GrnJournal.TransactionAnaEnt'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'ControlAnaEntry') = 0
BEGIN
  ALTER TABLE GrnJournal ADD ControlAnaEntry decimal(7,0) NULL
  PRINT 'New column GrnJournal.ControlAnaEntry'
END
GO
-- New column for table GrnJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GrnJournal' AND COLUMN_NAME = 'ProductClass') = 0
BEGIN
  ALTER TABLE GrnJournal ADD ProductClass char(4) NULL
  PRINT 'New column GrnJournal.ProductClass'
END
GO
-- New column for table GtrFifoTransfer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GtrFifoTransfer' AND COLUMN_NAME = 'LotSerial') = 0
BEGIN
  ALTER TABLE GtrFifoTransfer ADD LotSerial char(20) NULL
  PRINT 'New column GtrFifoTransfer.LotSerial'
END
GO
-- New column for table GtrFifoTransfer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GtrFifoTransfer' AND COLUMN_NAME = 'Version') = 0
BEGIN
  ALTER TABLE GtrFifoTransfer ADD Version char(3) NULL
  PRINT 'New column GtrFifoTransfer.Version'
END
GO
-- New column for table GtrFifoTransfer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'GtrFifoTransfer' AND COLUMN_NAME = 'Release') = 0
BEGIN
  ALTER TABLE GtrFifoTransfer ADD Release char(3) NULL
  PRINT 'New column GtrFifoTransfer.Release'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpInvJnlUpdYear') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpInvJnlUpdYear decimal(4,0) NULL
  PRINT 'New column InvCompanyCtl.UnpInvJnlUpdYear'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpInvJnlUpdMonth') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpInvJnlUpdMonth decimal(2,0) NULL
  PRINT 'New column InvCompanyCtl.UnpInvJnlUpdMonth'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpInvJnlUpd') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpInvJnlUpd decimal(5,0) NULL
  PRINT 'New column InvCompanyCtl.UnpInvJnlUpd'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpInvDisUpdYear') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpInvDisUpdYear decimal(4,0) NULL
  PRINT 'New column InvCompanyCtl.UnpInvDisUpdYear'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpInvDisUpdPeriod') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpInvDisUpdPeriod decimal(2,0) NULL
  PRINT 'New column InvCompanyCtl.UnpInvDisUpdPeriod'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpGrnDisUpdYear') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpGrnDisUpdYear decimal(4,0) NULL
  PRINT 'New column InvCompanyCtl.UnpGrnDisUpdYear'
END
GO
-- New column for table InvCompanyCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvCompanyCtl' AND COLUMN_NAME = 'UnpGrnDisUpdPeriod') = 0
BEGIN
  ALTER TABLE InvCompanyCtl ADD UnpGrnDisUpdPeriod decimal(2,0) NULL
  PRINT 'New column InvCompanyCtl.UnpGrnDisUpdPeriod'
END
GO
-- New column for table InvControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvControl' AND COLUMN_NAME = 'NextStockCode') = 0
BEGIN
  ALTER TABLE InvControl ADD NextStockCode decimal(15,0) NULL
  PRINT 'New column InvControl.NextStockCode'
END
GO
-- New column for table InvFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvFifoLifo' AND COLUMN_NAME = 'ReceiptQty') = 0
BEGIN
  ALTER TABLE InvFifoLifo ADD ReceiptQty decimal(10,3) NULL
  PRINT 'New column InvFifoLifo.ReceiptQty'
END
GO
-- New column for table InvFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvFifoLifo' AND COLUMN_NAME = 'LotSerial') = 0
BEGIN
  ALTER TABLE InvFifoLifo ADD LotSerial char(20) NULL
  PRINT 'New column InvFifoLifo.LotSerial'
END
GO
-- New column for table InvFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvFifoLifo' AND COLUMN_NAME = 'Version') = 0
BEGIN
  ALTER TABLE InvFifoLifo ADD Version char(3) NULL
  PRINT 'New column InvFifoLifo.Version'
END
GO
-- New column for table InvFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvFifoLifo' AND COLUMN_NAME = 'Release') = 0
BEGIN
  ALTER TABLE InvFifoLifo ADD Release char(3) NULL
  PRINT 'New column InvFifoLifo.Release'
END
GO
-- New column for table InvJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvJournalCtl' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE InvJournalCtl ADD GlIntUpdated char(1) NULL
  PRINT 'New column InvJournalCtl.GlIntUpdated'
END
GO
-- New column for table InvJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvJournalCtl' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE InvJournalCtl ADD GlIntPrinted char(1) NULL
  PRINT 'New column InvJournalCtl.GlIntPrinted'
END
GO
-- New column for table InvJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvJournalCtl' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE InvJournalCtl ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column InvJournalCtl.GlIntYear'
END
GO
-- New column for table InvJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvJournalCtl' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE InvJournalCtl ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column InvJournalCtl.GlIntPeriod'
END
GO
-- New column for table InvJournalCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvJournalCtl' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE InvJournalCtl ADD GlJournal decimal(5,0) NULL
  PRINT 'New column InvJournalCtl.GlJournal'
END
GO
-- New column for table InvJournalDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvJournalDet' AND COLUMN_NAME = 'LotSerial') = 0
BEGIN
  ALTER TABLE InvJournalDet ADD LotSerial char(20) NULL
  PRINT 'New column InvJournalDet.LotSerial'
END
GO
-- New column for table InvMovements
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvMovements' AND COLUMN_NAME = 'LotSerial') = 0
BEGIN
  ALTER TABLE InvMovements ADD LotSerial char(20) NULL
  PRINT 'New column InvMovements.LotSerial'
END
GO
-- New column for table InvMovements
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvMovements' AND COLUMN_NAME = 'IoProcessedFlag') = 0
BEGIN
  ALTER TABLE InvMovements ADD IoProcessedFlag char(1) NULL
  PRINT 'New column InvMovements.IoProcessedFlag'
END
GO
-- New column for table InvMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvMaster' AND COLUMN_NAME = 'StorageSecurity') = 0
BEGIN
  ALTER TABLE InvMaster ADD StorageSecurity char(20) NULL
  PRINT 'New column InvMaster.StorageSecurity'
END
GO
-- New column for table InvMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvMaster' AND COLUMN_NAME = 'StorageHazard') = 0
BEGIN
  ALTER TABLE InvMaster ADD StorageHazard char(20) NULL
  PRINT 'New column InvMaster.StorageHazard'
END
GO
-- New column for table InvMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvMaster' AND COLUMN_NAME = 'StorageCondition') = 0
BEGIN
  ALTER TABLE InvMaster ADD StorageCondition char(20) NULL
  PRINT 'New column InvMaster.StorageCondition'
END
GO
-- New column for table InvSerialTrn
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvSerialTrn' AND COLUMN_NAME = 'UnitCost') = 0
BEGIN
  ALTER TABLE InvSerialTrn ADD UnitCost decimal(15,5) NULL
  PRINT 'New column InvSerialTrn.UnitCost'
END
GO
-- New column for table InvSerialTrn
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvSerialTrn' AND COLUMN_NAME = 'Bucket') = 0
BEGIN
  ALTER TABLE InvSerialTrn ADD Bucket decimal(6,0) NULL
  PRINT 'New column InvSerialTrn.Bucket'
END
GO
-- New column for table InvTransFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvTransFifoLifo' AND COLUMN_NAME = 'LotSerial') = 0
BEGIN
  ALTER TABLE InvTransFifoLifo ADD LotSerial char(20) NULL
  PRINT 'New column InvTransFifoLifo.LotSerial'
END
GO
-- New column for table InvTransFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvTransFifoLifo' AND COLUMN_NAME = 'Version') = 0
BEGIN
  ALTER TABLE InvTransFifoLifo ADD Version char(3) NULL
  PRINT 'New column InvTransFifoLifo.Version'
END
GO
-- New column for table InvTransFifoLifo
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvTransFifoLifo' AND COLUMN_NAME = 'Release') = 0
BEGIN
  ALTER TABLE InvTransFifoLifo ADD Release char(3) NULL
  PRINT 'New column InvTransFifoLifo.Release'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'WmsActive') = 0
BEGIN
  ALTER TABLE InvWhControl ADD WmsActive char(1) NULL
  PRINT 'New column InvWhControl.WmsActive'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'PickLeadHours') = 0
BEGIN
  ALTER TABLE InvWhControl ADD PickLeadHours decimal(4,0) NULL
  PRINT 'New column InvWhControl.PickLeadHours'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'StockTakeUpdate') = 0
BEGIN
  ALTER TABLE InvWhControl ADD StockTakeUpdate char(1) NULL
  PRINT 'New column InvWhControl.StockTakeUpdate'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'NonStockedGl') = 0
BEGIN
  ALTER TABLE InvWhControl ADD NonStockedGl char(15) NULL
  PRINT 'New column InvWhControl.NonStockedGl'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'State') = 0
BEGIN
  ALTER TABLE InvWhControl ADD State char(2) NULL
  PRINT 'New column InvWhControl.State'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'CountyZip') = 0
BEGIN
  ALTER TABLE InvWhControl ADD CountyZip char(5) NULL
  PRINT 'New column InvWhControl.CountyZip'
END
GO
-- New column for table InvWhControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'InvWhControl' AND COLUMN_NAME = 'City') = 0
BEGIN
  ALTER TABLE InvWhControl ADD City char(3) NULL
  PRINT 'New column InvWhControl.City'
END
GO
-- New column for table IopColInstance
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopColInstance' AND COLUMN_NAME = 'Disaggregate') = 0
BEGIN
  ALTER TABLE IopColInstance ADD Disaggregate char(1) NULL
  PRINT 'New column IopColInstance.Disaggregate'
END
GO
-- New column for table IopCollectAdjust
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopCollectAdjust' AND COLUMN_NAME = 'LostSaleTrnDate') = 0
BEGIN
  ALTER TABLE IopCollectAdjust ADD LostSaleTrnDate datetime NULL
  PRINT 'New column IopCollectAdjust.LostSaleTrnDate'
END
GO
-- New column for table IopCollectAdjust
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopCollectAdjust' AND COLUMN_NAME = 'LostSaleTrnTime') = 0
BEGIN
  ALTER TABLE IopCollectAdjust ADD LostSaleTrnTime decimal(8,0) NULL
  PRINT 'New column IopCollectAdjust.LostSaleTrnTime'
END
GO
-- New column for table IopColSelect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopColSelect' AND COLUMN_NAME = 'SelectionSet') = 0
BEGIN
  ALTER TABLE IopColSelect ADD SelectionSet char(10) NULL
  PRINT 'New column IopColSelect.SelectionSet'
END
GO
-- New column for table IopConSalesAdjust
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopConSalesAdjust' AND COLUMN_NAME = 'LostSaleTrnDate') = 0
BEGIN
  ALTER TABLE IopConSalesAdjust ADD LostSaleTrnDate datetime NULL
  PRINT 'New column IopConSalesAdjust.LostSaleTrnDate'
END
GO
-- New column for table IopConSalesAdjust
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopConSalesAdjust' AND COLUMN_NAME = 'LostSaleTrnTime') = 0
BEGIN
  ALTER TABLE IopConSalesAdjust ADD LostSaleTrnTime decimal(8,0) NULL
  PRINT 'New column IopConSalesAdjust.LostSaleTrnTime'
END
GO
-- New column for table IopProxies
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopProxies' AND COLUMN_NAME = 'Warehouse') = 0
BEGIN
  ALTER TABLE IopProxies ADD Warehouse char(2) NULL
  PRINT 'New column IopProxies.Warehouse'
END
GO
-- New column for table IopProxies
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopProxies' AND COLUMN_NAME = 'ProxyWarehouse') = 0
BEGIN
  ALTER TABLE IopProxies ADD ProxyWarehouse char(2) NULL
  PRINT 'New column IopProxies.ProxyWarehouse'
END
GO
-- New column for table IopSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSales' AND COLUMN_NAME = 'TransCount') = 0
BEGIN
  ALTER TABLE IopSales ADD TransCount decimal(7,0) NULL
  PRINT 'New column IopSales.TransCount'
END
GO
-- New column for table IopSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSales' AND COLUMN_NAME = 'Quantity') = 0
BEGIN
  ALTER TABLE IopSales ADD Quantity decimal(12,3) NULL
  PRINT 'New column IopSales.Quantity'
END
GO
-- New column for table IopSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSales' AND COLUMN_NAME = 'CostValue') = 0
BEGIN
  ALTER TABLE IopSales ADD CostValue decimal(14,2) NULL
  PRINT 'New column IopSales.CostValue'
END
GO
-- New column for table IopSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSales' AND COLUMN_NAME = 'SalesValue') = 0
BEGIN
  ALTER TABLE IopSales ADD SalesValue decimal(14,2) NULL
  PRINT 'New column IopSales.SalesValue'
END
GO
-- New column for table IopSalesReturns
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSalesReturns' AND COLUMN_NAME = 'TransCount') = 0
BEGIN
  ALTER TABLE IopSalesReturns ADD TransCount decimal(7,0) NULL
  PRINT 'New column IopSalesReturns.TransCount'
END
GO
-- New column for table IopSalesReturns
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSalesReturns' AND COLUMN_NAME = 'Quantity') = 0
BEGIN
  ALTER TABLE IopSalesReturns ADD Quantity decimal(12,3) NULL
  PRINT 'New column IopSalesReturns.Quantity'
END
GO
-- New column for table IopSalesReturns
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSalesReturns' AND COLUMN_NAME = 'CostValue') = 0
BEGIN
  ALTER TABLE IopSalesReturns ADD CostValue decimal(14,2) NULL
  PRINT 'New column IopSalesReturns.CostValue'
END
GO
-- New column for table IopSalesReturns
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopSalesReturns' AND COLUMN_NAME = 'SalesValue') = 0
BEGIN
  ALTER TABLE IopSalesReturns ADD SalesValue decimal(14,2) NULL
  PRINT 'New column IopSalesReturns.SalesValue'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'IdNumber') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD IdNumber decimal(10,0) NULL
  PRINT 'New column IopWarehouse.IdNumber'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'UserField1') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD UserField1 char(30) NULL
  PRINT 'New column IopWarehouse.UserField1'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'UserField2') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD UserField2 char(30) NULL
  PRINT 'New column IopWarehouse.UserField2'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'UserField3') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD UserField3 char(30) NULL
  PRINT 'New column IopWarehouse.UserField3'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'UserField4') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD UserField4 char(10) NULL
  PRINT 'New column IopWarehouse.UserField4'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'UserField5') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD UserField5 char(10) NULL
  PRINT 'New column IopWarehouse.UserField5'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'UserField6') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD UserField6 char(10) NULL
  PRINT 'New column IopWarehouse.UserField6'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'ForeAccuracyDays') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD ForeAccuracyDays decimal(3,0) NULL
  PRINT 'New column IopWarehouse.ForeAccuracyDays'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'IntDemandDays') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD IntDemandDays decimal(3,0) NULL
  PRINT 'New column IopWarehouse.IntDemandDays'
END
GO
-- New column for table IopWarehouse
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'IopWarehouse' AND COLUMN_NAME = 'IntDemandPct') = 0
BEGIN
  ALTER TABLE IopWarehouse ADD IntDemandPct decimal(5,2) NULL
  PRINT 'New column IopWarehouse.IntDemandPct'
END
GO
-- New column for table LotTransactions
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'LotTransactions' AND COLUMN_NAME = 'UnitCost') = 0
BEGIN
  ALTER TABLE LotTransactions ADD UnitCost decimal(15,5) NULL
  PRINT 'New column LotTransactions.UnitCost'
END
GO
-- New column for table LotTransactions
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'LotTransactions' AND COLUMN_NAME = 'Bucket') = 0
BEGIN
  ALTER TABLE LotTransactions ADD Bucket decimal(6,0) NULL
  PRINT 'New column LotTransactions.Bucket'
END
GO
-- New column for table MdnDetailCons
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnDetailCons' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE MdnDetailCons ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column MdnDetailCons.SalesOrderDetStat'
END
GO
-- New column for table MdnDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnDetail' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE MdnDetail ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column MdnDetail.SalesOrderDetStat'
END
GO
-- New column for table MdnMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnMaster' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE MdnMaster ADD DetailStatus char(1) NULL
  PRINT 'New column MdnMaster.DetailStatus'
END
GO
-- New column for table MdnDetailRepCon
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnDetailRepCon' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE MdnDetailRepCon ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column MdnDetailRepCon.SalesOrderDetStat'
END
GO
-- New column for table MdnMasterRepCon
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnMasterRepCon' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE MdnMasterRepCon ADD DetailStatus char(1) NULL
  PRINT 'New column MdnMasterRepCon.DetailStatus'
END
GO
-- New column for table MdnDetailRep
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnDetailRep' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE MdnDetailRep ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column MdnDetailRep.SalesOrderDetStat'
END
GO
-- New column for table MdnMasterRep
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MdnMasterRep' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE MdnMasterRep ADD DetailStatus char(1) NULL
  PRINT 'New column MdnMasterRep.DetailStatus'
END
GO
-- New column for table PorMasterDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'PorMasterDetail' AND COLUMN_NAME = 'OrderLineStatus') = 0
BEGIN
  ALTER TABLE PorMasterDetail ADD OrderLineStatus char(1) NULL
  PRINT 'New column PorMasterDetail.OrderLineStatus'
END
GO
-- New column for table MrpPoMasterDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpPoMasterDet' AND COLUMN_NAME = 'OrderLineStatus') = 0
BEGIN
  ALTER TABLE MrpPoMasterDet ADD OrderLineStatus char(1) NULL
  PRINT 'New column MrpPoMasterDet.OrderLineStatus'
END
GO
-- New column for table PorEcReceipts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'PorEcReceipts' AND COLUMN_NAME = 'SupplUnitQty') = 0
BEGIN
  ALTER TABLE PorEcReceipts ADD SupplUnitQty decimal(12,6) NULL
  PRINT 'New column PorEcReceipts.SupplUnitQty'
END
GO
-- New column for table PorHistReceipt
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'PorHistReceipt' AND COLUMN_NAME = 'Version') = 0
BEGIN
  ALTER TABLE PorHistReceipt ADD Version char(3) NULL
  PRINT 'New column PorHistReceipt.Version'
END
GO
-- New column for table PorHistReceipt
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'PorHistReceipt' AND COLUMN_NAME = 'Release') = 0
BEGIN
  ALTER TABLE PorHistReceipt ADD Release char(3) NULL
  PRINT 'New column PorHistReceipt.Release'
END
GO
-- New column for table PorHistReceipt
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'PorHistReceipt' AND COLUMN_NAME = 'DeliveryMethod') = 0
BEGIN
  ALTER TABLE PorHistReceipt ADD DeliveryMethod char(10) NULL
  PRINT 'New column PorHistReceipt.DeliveryMethod'
END
GO
-- New column for table PorMasterHdr
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'PorMasterHdr' AND COLUMN_NAME = 'DeliveryMethod') = 0
BEGIN
  ALTER TABLE PorMasterHdr ADD DeliveryMethod char(10) NULL
  PRINT 'New column PorMasterHdr.DeliveryMethod'
END
GO
-- New column for table MrpPoMasterHdr
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpPoMasterHdr' AND COLUMN_NAME = 'DeliveryMethod') = 0
BEGIN
  ALTER TABLE MrpPoMasterHdr ADD DeliveryMethod char(10) NULL
  PRINT 'New column MrpPoMasterHdr.DeliveryMethod'
END
GO
-- New column for table QotOffer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOffer' AND COLUMN_NAME = 'MDiscChanged') = 0
BEGIN
  ALTER TABLE QotOffer ADD MDiscChanged char(1) NULL
  PRINT 'New column QotOffer.MDiscChanged'
END
GO
-- New column for table MrpQotOffer
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOffer' AND COLUMN_NAME = 'MDiscChanged') = 0
BEGIN
  ALTER TABLE MrpQotOffer ADD MDiscChanged char(1) NULL
  PRINT 'New column MrpQotOffer.MDiscChanged'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'IRunTimeEnt') = 0
BEGIN
  ALTER TABLE QotOperation ADD IRunTimeEnt decimal(9,4) NULL
  PRINT 'New column QotOperation.IRunTimeEnt'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE QotOperation ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column QotOperation.ITimeTakenEnt'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE QotOperation ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column QotOperation.IStartupQtyEnt'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'IBlockQtyEnt') = 0
BEGIN
  ALTER TABLE QotOperation ADD IBlockQtyEnt decimal(10,3) NULL
  PRINT 'New column QotOperation.IBlockQtyEnt'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE QotOperation ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column QotOperation.OperYieldQtyEnt'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE QotOperation ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column QotOperation.TransferQtyPctEnt'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'MaxOpSpan') = 0
BEGIN
  ALTER TABLE QotOperation ADD MaxOpSpan decimal(4,0) NULL
  PRINT 'New column QotOperation.MaxOpSpan'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'OpSlack') = 0
BEGIN
  ALTER TABLE QotOperation ADD OpSlack decimal(4,0) NULL
  PRINT 'New column QotOperation.OpSlack'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'MaxOpDelay') = 0
BEGIN
  ALTER TABLE QotOperation ADD MaxOpDelay decimal(4,0) NULL
  PRINT 'New column QotOperation.MaxOpDelay'
END
GO
-- New column for table QotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotOperation' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE QotOperation ADD AllowOpSplit char(1) NULL
  PRINT 'New column QotOperation.AllowOpSplit'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'IRunTimeEnt') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD IRunTimeEnt decimal(9,4) NULL
  PRINT 'New column MrpQotOperation.IRunTimeEnt'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column MrpQotOperation.ITimeTakenEnt'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpQotOperation.IStartupQtyEnt'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'IBlockQtyEnt') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD IBlockQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpQotOperation.IBlockQtyEnt'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column MrpQotOperation.OperYieldQtyEnt'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column MrpQotOperation.TransferQtyPctEnt'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'MaxOpSpan') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD MaxOpSpan decimal(4,0) NULL
  PRINT 'New column MrpQotOperation.MaxOpSpan'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'OpSlack') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD OpSlack decimal(4,0) NULL
  PRINT 'New column MrpQotOperation.OpSlack'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'MaxOpDelay') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD MaxOpDelay decimal(4,0) NULL
  PRINT 'New column MrpQotOperation.MaxOpDelay'
END
GO
-- New column for table MrpQotOperation
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotOperation' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE MrpQotOperation ADD AllowOpSplit char(1) NULL
  PRINT 'New column MrpQotOperation.AllowOpSplit'
END
GO
-- New column for table QotStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotStructure' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE QotStructure ADD QtyPerEnt decimal(12,6) NULL
  PRINT 'New column QotStructure.QtyPerEnt'
END
GO
-- New column for table QotStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotStructure' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE QotStructure ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column QotStructure.ScrapQuantityEnt'
END
GO
-- New column for table QotStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotStructure' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE QotStructure ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column QotStructure.FixedQtyPerEnt'
END
GO
-- New column for table MrpQotStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotStructure' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE MrpQotStructure ADD QtyPerEnt decimal(12,6) NULL
  PRINT 'New column MrpQotStructure.QtyPerEnt'
END
GO
-- New column for table MrpQotStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotStructure' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE MrpQotStructure ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column MrpQotStructure.ScrapQuantityEnt'
END
GO
-- New column for table MrpQotStructure
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotStructure' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE MrpQotStructure ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column MrpQotStructure.FixedQtyPerEnt'
END
GO
-- New column for table ReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqDetail' AND COLUMN_NAME = 'ApprovedDate') = 0
BEGIN
  ALTER TABLE ReqDetail ADD ApprovedDate datetime NULL
  PRINT 'New column ReqDetail.ApprovedDate'
END
GO
-- New column for table ReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqDetail' AND COLUMN_NAME = 'SelectionCode') = 0
BEGIN
  ALTER TABLE ReqDetail ADD SelectionCode char(30) NULL
  PRINT 'New column ReqDetail.SelectionCode'
END
GO
-- New column for table ReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqDetail' AND COLUMN_NAME = 'SelectionType') = 0
BEGIN
  ALTER TABLE ReqDetail ADD SelectionType char(3) NULL
  PRINT 'New column ReqDetail.SelectionType'
END
GO
-- New column for table MrpReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpReqDetail' AND COLUMN_NAME = 'ApprovedDate') = 0
BEGIN
  ALTER TABLE MrpReqDetail ADD ApprovedDate datetime NULL
  PRINT 'New column MrpReqDetail.ApprovedDate'
END
GO
-- New column for table MrpReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpReqDetail' AND COLUMN_NAME = 'SelectionCode') = 0
BEGIN
  ALTER TABLE MrpReqDetail ADD SelectionCode char(30) NULL
  PRINT 'New column MrpReqDetail.SelectionCode'
END
GO
-- New column for table MrpReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpReqDetail' AND COLUMN_NAME = 'SelectionType') = 0
BEGIN
  ALTER TABLE MrpReqDetail ADD SelectionType char(3) NULL
  PRINT 'New column MrpReqDetail.SelectionType'
END
GO
-- New column for table MrpSugReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugReqDetail' AND COLUMN_NAME = 'ApprovedDate') = 0
BEGIN
  ALTER TABLE MrpSugReqDetail ADD ApprovedDate datetime NULL
  PRINT 'New column MrpSugReqDetail.ApprovedDate'
END
GO
-- New column for table MrpSugReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugReqDetail' AND COLUMN_NAME = 'SelectionCode') = 0
BEGIN
  ALTER TABLE MrpSugReqDetail ADD SelectionCode char(30) NULL
  PRINT 'New column MrpSugReqDetail.SelectionCode'
END
GO
-- New column for table MrpSugReqDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugReqDetail' AND COLUMN_NAME = 'SelectionType') = 0
BEGIN
  ALTER TABLE MrpSugReqDetail ADD SelectionType char(3) NULL
  PRINT 'New column MrpSugReqDetail.SelectionType'
END
GO
-- New column for table ReqHeader
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqHeader' AND COLUMN_NAME = 'ApprovedValue') = 0
BEGIN
  ALTER TABLE ReqHeader ADD ApprovedValue decimal(14,2) NULL
  PRINT 'New column ReqHeader.ApprovedValue'
END
GO
-- New column for table ReqRoutedToUser
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqRoutedToUser' AND COLUMN_NAME = 'RequisitionType') = 0
BEGIN
  ALTER TABLE ReqRoutedToUser ADD RequisitionType char(1) NULL
  PRINT 'New column ReqRoutedToUser.RequisitionType'
END
GO
-- New column for table ReqUser
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqUser' AND COLUMN_NAME = 'RequisitionGroup') = 0
BEGIN
  ALTER TABLE ReqUser ADD RequisitionGroup char(6) NULL
  PRINT 'New column ReqUser.RequisitionGroup'
END
GO
-- New column for table ReqUser
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqUser' AND COLUMN_NAME = 'AdminUserFlag') = 0
BEGIN
  ALTER TABLE ReqUser ADD AdminUserFlag char(1) NULL
  PRINT 'New column ReqUser.AdminUserFlag'
END
GO
-- New column for table ReqUser
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'ReqUser' AND COLUMN_NAME = 'AdminStopFlag') = 0
BEGIN
  ALTER TABLE ReqUser ADD AdminStopFlag char(1) NULL
  PRINT 'New column ReqUser.AdminStopFlag'
END
GO
-- New column for table RmaDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'RmaDetail' AND COLUMN_NAME = 'PriceUom') = 0
BEGIN
  ALTER TABLE RmaDetail ADD PriceUom char(3) NULL
  PRINT 'New column RmaDetail.PriceUom'
END
GO
-- New column for table RmaDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'RmaDetail' AND COLUMN_NAME = 'ConvFactRmaUm') = 0
BEGIN
  ALTER TABLE RmaDetail ADD ConvFactRmaUm decimal(10,6) NULL
  PRINT 'New column RmaDetail.ConvFactRmaUm'
END
GO
-- New column for table RmaDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'RmaDetail' AND COLUMN_NAME = 'MulDivPrcFct') = 0
BEGIN
  ALTER TABLE RmaDetail ADD MulDivPrcFct char(1) NULL
  PRINT 'New column RmaDetail.MulDivPrcFct'
END
GO
-- New column for table RmaDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'RmaDetail' AND COLUMN_NAME = 'LastActionDate') = 0
BEGIN
  ALTER TABLE RmaDetail ADD LastActionDate datetime NULL
  PRINT 'New column RmaDetail.LastActionDate'
END
GO
-- New column for table RmaMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'RmaMaster' AND COLUMN_NAME = 'Contact') = 0
BEGIN
  ALTER TABLE RmaMaster ADD Contact char(40) NULL
  PRINT 'New column RmaMaster.Contact'
END
GO
-- New column for table SalBranch
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SalBranch' AND COLUMN_NAME = 'NextCreditDisc') = 0
BEGIN
  ALTER TABLE SalBranch ADD NextCreditDisc decimal(6,0) NULL
  PRINT 'New column SalBranch.NextCreditDisc'
END
GO
-- New column for table SalBranch
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SalBranch' AND COLUMN_NAME = 'NextDebitDisc') = 0
BEGIN
  ALTER TABLE SalBranch ADD NextDebitDisc decimal(6,0) NULL
  PRINT 'New column SalBranch.NextDebitDisc'
END
GO
-- New column for table SalEcSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SalEcSales' AND COLUMN_NAME = 'SupplUnitQty') = 0
BEGIN
  ALTER TABLE SalEcSales ADD SupplUnitQty decimal(12,6) NULL
  PRINT 'New column SalEcSales.SupplUnitQty'
END
GO
-- New column for table SalSalesTax
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SalSalesTax' AND COLUMN_NAME = 'UkVatFlag') = 0
BEGIN
  ALTER TABLE SalSalesTax ADD UkVatFlag char(1) NULL
  PRINT 'New column SalSalesTax.UkVatFlag'
END
GO
-- New column for table SorChanges
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorChanges' AND COLUMN_NAME = 'ReasonCode') = 0
BEGIN
  ALTER TABLE SorChanges ADD ReasonCode char(6) NULL
  PRINT 'New column SorChanges.ReasonCode'
END
GO
-- New column for table SorDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorDetail' AND COLUMN_NAME = 'MultiShipCode') = 0
BEGIN
  ALTER TABLE SorDetail ADD MultiShipCode char(5) NULL
  PRINT 'New column SorDetail.MultiShipCode'
END
GO
-- New column for table SorDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorDetail' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE SorDetail ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column SorDetail.SalesOrderDetStat'
END
GO
-- New column for table SorDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorDetail' AND COLUMN_NAME = 'SalesOrderResStat') = 0
BEGIN
  ALTER TABLE SorDetail ADD SalesOrderResStat char(1) NULL
  PRINT 'New column SorDetail.SalesOrderResStat'
END
GO
-- New column for table SorDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorDetail' AND COLUMN_NAME = 'QtyReservedShip') = 0
BEGIN
  ALTER TABLE SorDetail ADD QtyReservedShip decimal(10,3) NULL
  PRINT 'New column SorDetail.QtyReservedShip'
END
GO
-- New column for table MrpQotSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotSoDetail' AND COLUMN_NAME = 'MultiShipCode') = 0
BEGIN
  ALTER TABLE MrpQotSoDetail ADD MultiShipCode char(5) NULL
  PRINT 'New column MrpQotSoDetail.MultiShipCode'
END
GO
-- New column for table MrpQotSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotSoDetail' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE MrpQotSoDetail ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column MrpQotSoDetail.SalesOrderDetStat'
END
GO
-- New column for table MrpQotSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotSoDetail' AND COLUMN_NAME = 'SalesOrderResStat') = 0
BEGIN
  ALTER TABLE MrpQotSoDetail ADD SalesOrderResStat char(1) NULL
  PRINT 'New column MrpQotSoDetail.SalesOrderResStat'
END
GO
-- New column for table MrpQotSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotSoDetail' AND COLUMN_NAME = 'QtyReservedShip') = 0
BEGIN
  ALTER TABLE MrpQotSoDetail ADD QtyReservedShip decimal(10,3) NULL
  PRINT 'New column MrpQotSoDetail.QtyReservedShip'
END
GO
-- New column for table MrpSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSoDetail' AND COLUMN_NAME = 'MultiShipCode') = 0
BEGIN
  ALTER TABLE MrpSoDetail ADD MultiShipCode char(5) NULL
  PRINT 'New column MrpSoDetail.MultiShipCode'
END
GO
-- New column for table MrpSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSoDetail' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE MrpSoDetail ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column MrpSoDetail.SalesOrderDetStat'
END
GO
-- New column for table MrpSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSoDetail' AND COLUMN_NAME = 'SalesOrderResStat') = 0
BEGIN
  ALTER TABLE MrpSoDetail ADD SalesOrderResStat char(1) NULL
  PRINT 'New column MrpSoDetail.SalesOrderResStat'
END
GO
-- New column for table MrpSoDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSoDetail' AND COLUMN_NAME = 'QtyReservedShip') = 0
BEGIN
  ALTER TABLE MrpSoDetail ADD QtyReservedShip decimal(10,3) NULL
  PRINT 'New column MrpSoDetail.QtyReservedShip'
END
GO
-- New column for table SorLostSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorLostSales' AND COLUMN_NAME = 'Version') = 0
BEGIN
  ALTER TABLE SorLostSales ADD Version char(3) NULL
  PRINT 'New column SorLostSales.Version'
END
GO
-- New column for table SorLostSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorLostSales' AND COLUMN_NAME = 'Release') = 0
BEGIN
  ALTER TABLE SorLostSales ADD Release char(3) NULL
  PRINT 'New column SorLostSales.Release'
END
GO
-- New column for table SorLostSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorLostSales' AND COLUMN_NAME = 'SalesOrder') = 0
BEGIN
  ALTER TABLE SorLostSales ADD SalesOrder char(6) NULL
  PRINT 'New column SorLostSales.SalesOrder'
END
GO
-- New column for table SorLostSales
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorLostSales' AND COLUMN_NAME = 'SalesOrderLine') = 0
BEGIN
  ALTER TABLE SorLostSales ADD SalesOrderLine decimal(4,0) NULL
  PRINT 'New column SorLostSales.SalesOrderLine'
END
GO
-- New column for table SorMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorMaster' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE SorMaster ADD DetailStatus char(1) NULL
  PRINT 'New column SorMaster.DetailStatus'
END
GO
-- New column for table MrpQotSoMasterHdr
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpQotSoMasterHdr' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE MrpQotSoMasterHdr ADD DetailStatus char(1) NULL
  PRINT 'New column MrpQotSoMasterHdr.DetailStatus'
END
GO
-- New column for table MrpSoMasterHdr
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSoMasterHdr' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE MrpSoMasterHdr ADD DetailStatus char(1) NULL
  PRINT 'New column MrpSoMasterHdr.DetailStatus'
END
GO
-- New column for table QotSoMasterHdr
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'QotSoMasterHdr' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE QotSoMasterHdr ADD DetailStatus char(1) NULL
  PRINT 'New column QotSoMasterHdr.DetailStatus'
END
GO
-- New column for table SorDetailRep
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorDetailRep' AND COLUMN_NAME = 'SalesOrderDetStat') = 0
BEGIN
  ALTER TABLE SorDetailRep ADD SalesOrderDetStat char(1) NULL
  PRINT 'New column SorDetailRep.SalesOrderDetStat'
END
GO
-- New column for table SorMasterRep
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'SorMasterRep' AND COLUMN_NAME = 'DetailStatus') = 0
BEGIN
  ALTER TABLE SorMasterRep ADD DetailStatus char(1) NULL
  PRINT 'New column SorMasterRep.DetailStatus'
END
GO
-- New column for table TblSoReason
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TblSoReason' AND COLUMN_NAME = 'IoLostSaleFlag') = 0
BEGIN
  ALTER TABLE TblSoReason ADD IoLostSaleFlag char(1) NULL
  PRINT 'New column TblSoReason.IoLostSaleFlag'
END
GO
-- New column for table TpmJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmJournal' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE TpmJournal ADD GlIntUpdated char(1) NULL
  PRINT 'New column TpmJournal.GlIntUpdated'
END
GO
-- New column for table TpmJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmJournal' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE TpmJournal ADD GlIntPrinted char(1) NULL
  PRINT 'New column TpmJournal.GlIntPrinted'
END
GO
-- New column for table TpmJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmJournal' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE TpmJournal ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column TpmJournal.GlIntYear'
END
GO
-- New column for table TpmJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmJournal' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE TpmJournal ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column TpmJournal.GlIntPeriod'
END
GO
-- New column for table TpmJournal
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmJournal' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE TpmJournal ADD GlJournal decimal(5,0) NULL
  PRINT 'New column TpmJournal.GlJournal'
END
GO
-- New column for table TpmPriceDetail
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmPriceDetail' AND COLUMN_NAME = 'PriceCode') = 0
BEGIN
  ALTER TABLE TpmPriceDetail ADD PriceCode char(2) NULL
  PRINT 'New column TpmPriceDetail.PriceCode'
END
GO
-- New column for table TpmPromotion
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmPromotion' AND COLUMN_NAME = 'PriceCode') = 0
BEGIN
  ALTER TABLE TpmPromotion ADD PriceCode char(2) NULL
  PRINT 'New column TpmPromotion.PriceCode'
END
GO
-- New column for table TpmPromotion
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmPromotion' AND COLUMN_NAME = 'PriceCodeCusPrc') = 0
BEGIN
  ALTER TABLE TpmPromotion ADD PriceCodeCusPrc char(2) NULL
  PRINT 'New column TpmPromotion.PriceCodeCusPrc'
END
GO
-- New column for table TpmPromotionTrans
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmPromotionTrans' AND COLUMN_NAME = 'SPriceCode') = 0
BEGIN
  ALTER TABLE TpmPromotionTrans ADD SPriceCode char(2) NULL
  PRINT 'New column TpmPromotionTrans.SPriceCode'
END
GO
-- New column for table TpmPromotionTrans
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'TpmPromotionTrans' AND COLUMN_NAME = 'SPriceCodeCusPrc') = 0
BEGIN
  ALTER TABLE TpmPromotionTrans ADD SPriceCodeCusPrc char(2) NULL
  PRINT 'New column TpmPromotionTrans.SPriceCodeCusPrc'
END
GO
-- New column for table WipJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobClass' AND COLUMN_NAME = 'WipCtlGlCode') = 0
BEGIN
  ALTER TABLE WipJobClass ADD WipCtlGlCode char(15) NULL
  PRINT 'New column WipJobClass.WipCtlGlCode'
END
GO
-- New column for table WipJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobClass' AND COLUMN_NAME = 'WipInsGlCode') = 0
BEGIN
  ALTER TABLE WipJobClass ADD WipInsGlCode char(15) NULL
  PRINT 'New column WipJobClass.WipInsGlCode'
END
GO
-- New column for table WipJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobClass' AND COLUMN_NAME = 'WipAutoGlCode') = 0
BEGIN
  ALTER TABLE WipJobClass ADD WipAutoGlCode char(15) NULL
  PRINT 'New column WipJobClass.WipAutoGlCode'
END
GO
-- New column for table WipJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobClass' AND COLUMN_NAME = 'WipVarGlCode') = 0
BEGIN
  ALTER TABLE WipJobClass ADD WipVarGlCode char(15) NULL
  PRINT 'New column WipJobClass.WipVarGlCode'
END
GO
-- New column for table MrpJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobClass' AND COLUMN_NAME = 'WipCtlGlCode') = 0
BEGIN
  ALTER TABLE MrpJobClass ADD WipCtlGlCode char(15) NULL
  PRINT 'New column MrpJobClass.WipCtlGlCode'
END
GO
-- New column for table MrpJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobClass' AND COLUMN_NAME = 'WipInsGlCode') = 0
BEGIN
  ALTER TABLE MrpJobClass ADD WipInsGlCode char(15) NULL
  PRINT 'New column MrpJobClass.WipInsGlCode'
END
GO
-- New column for table MrpJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobClass' AND COLUMN_NAME = 'WipAutoGlCode') = 0
BEGIN
  ALTER TABLE MrpJobClass ADD WipAutoGlCode char(15) NULL
  PRINT 'New column MrpJobClass.WipAutoGlCode'
END
GO
-- New column for table MrpJobClass
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobClass' AND COLUMN_NAME = 'WipVarGlCode') = 0
BEGIN
  ALTER TABLE MrpJobClass ADD WipVarGlCode char(15) NULL
  PRINT 'New column MrpJobClass.WipVarGlCode'
END
GO
-- New column for table WipCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipCoProducts' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE WipCoProducts ADD QtyPerEnt decimal(10,3) NULL
  PRINT 'New column WipCoProducts.QtyPerEnt'
END
GO
-- New column for table WipCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipCoProducts' AND COLUMN_NAME = 'QtyToMakeEnt') = 0
BEGIN
  ALTER TABLE WipCoProducts ADD QtyToMakeEnt decimal(10,3) NULL
  PRINT 'New column WipCoProducts.QtyToMakeEnt'
END
GO
-- New column for table WipCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipCoProducts' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE WipCoProducts ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column WipCoProducts.QtyManufacturedEnt'
END
GO
-- New column for table WipCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipCoProducts' AND COLUMN_NAME = 'TotalQtyScrapEnt') = 0
BEGIN
  ALTER TABLE WipCoProducts ADD TotalQtyScrapEnt decimal(10,3) NULL
  PRINT 'New column WipCoProducts.TotalQtyScrapEnt'
END
GO
-- New column for table MrpCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpCoProducts' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE MrpCoProducts ADD QtyPerEnt decimal(10,3) NULL
  PRINT 'New column MrpCoProducts.QtyPerEnt'
END
GO
-- New column for table MrpCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpCoProducts' AND COLUMN_NAME = 'QtyToMakeEnt') = 0
BEGIN
  ALTER TABLE MrpCoProducts ADD QtyToMakeEnt decimal(10,3) NULL
  PRINT 'New column MrpCoProducts.QtyToMakeEnt'
END
GO
-- New column for table MrpCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpCoProducts' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE MrpCoProducts ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column MrpCoProducts.QtyManufacturedEnt'
END
GO
-- New column for table MrpCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpCoProducts' AND COLUMN_NAME = 'TotalQtyScrapEnt') = 0
BEGIN
  ALTER TABLE MrpCoProducts ADD TotalQtyScrapEnt decimal(10,3) NULL
  PRINT 'New column MrpCoProducts.TotalQtyScrapEnt'
END
GO
-- New column for table MrpSugCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugCoProducts' AND COLUMN_NAME = 'QtyPerEnt') = 0
BEGIN
  ALTER TABLE MrpSugCoProducts ADD QtyPerEnt decimal(10,3) NULL
  PRINT 'New column MrpSugCoProducts.QtyPerEnt'
END
GO
-- New column for table MrpSugCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugCoProducts' AND COLUMN_NAME = 'QtyToMakeEnt') = 0
BEGIN
  ALTER TABLE MrpSugCoProducts ADD QtyToMakeEnt decimal(10,3) NULL
  PRINT 'New column MrpSugCoProducts.QtyToMakeEnt'
END
GO
-- New column for table MrpSugCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugCoProducts' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE MrpSugCoProducts ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column MrpSugCoProducts.QtyManufacturedEnt'
END
GO
-- New column for table MrpSugCoProducts
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugCoProducts' AND COLUMN_NAME = 'TotalQtyScrapEnt') = 0
BEGIN
  ALTER TABLE MrpSugCoProducts ADD TotalQtyScrapEnt decimal(10,3) NULL
  PRINT 'New column MrpSugCoProducts.TotalQtyScrapEnt'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'LowUnpLabUpdYear') = 0
BEGIN
  ALTER TABLE WipControl ADD LowUnpLabUpdYear decimal(4,0) NULL
  PRINT 'New column WipControl.LowUnpLabUpdYear'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'LowUnpLabUpdPeriod') = 0
BEGIN
  ALTER TABLE WipControl ADD LowUnpLabUpdPeriod decimal(2,0) NULL
  PRINT 'New column WipControl.LowUnpLabUpdPeriod'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'LowUnpLabUpdJnl') = 0
BEGIN
  ALTER TABLE WipControl ADD LowUnpLabUpdJnl decimal(5,0) NULL
  PRINT 'New column WipControl.LowUnpLabUpdJnl'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'LowUnpBillUpdYear') = 0
BEGIN
  ALTER TABLE WipControl ADD LowUnpBillUpdYear decimal(4,0) NULL
  PRINT 'New column WipControl.LowUnpBillUpdYear'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'LowUnpBillUpdPrd') = 0
BEGIN
  ALTER TABLE WipControl ADD LowUnpBillUpdPrd decimal(2,0) NULL
  PRINT 'New column WipControl.LowUnpBillUpdPrd'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'LowUnpBillUpdJnl') = 0
BEGIN
  ALTER TABLE WipControl ADD LowUnpBillUpdJnl decimal(5,0) NULL
  PRINT 'New column WipControl.LowUnpBillUpdJnl'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'UnpLabUpdYear') = 0
BEGIN
  ALTER TABLE WipControl ADD UnpLabUpdYear decimal(4,0) NULL
  PRINT 'New column WipControl.UnpLabUpdYear'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'UnpLabUpdPeriod') = 0
BEGIN
  ALTER TABLE WipControl ADD UnpLabUpdPeriod decimal(2,0) NULL
  PRINT 'New column WipControl.UnpLabUpdPeriod'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'UnpBillUpdYear') = 0
BEGIN
  ALTER TABLE WipControl ADD UnpBillUpdYear decimal(4,0) NULL
  PRINT 'New column WipControl.UnpBillUpdYear'
END
GO
-- New column for table WipControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipControl' AND COLUMN_NAME = 'UnpBillUpdPeriod') = 0
BEGIN
  ALTER TABLE WipControl ADD UnpBillUpdPeriod decimal(2,0) NULL
  PRINT 'New column WipControl.UnpBillUpdPeriod'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'LowUnpLabUpdYear') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD LowUnpLabUpdYear decimal(4,0) NULL
  PRINT 'New column MrpSugWipCtl.LowUnpLabUpdYear'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'LowUnpLabUpdPeriod') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD LowUnpLabUpdPeriod decimal(2,0) NULL
  PRINT 'New column MrpSugWipCtl.LowUnpLabUpdPeriod'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'LowUnpLabUpdJnl') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD LowUnpLabUpdJnl decimal(5,0) NULL
  PRINT 'New column MrpSugWipCtl.LowUnpLabUpdJnl'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'LowUnpBillUpdYear') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD LowUnpBillUpdYear decimal(4,0) NULL
  PRINT 'New column MrpSugWipCtl.LowUnpBillUpdYear'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'LowUnpBillUpdPrd') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD LowUnpBillUpdPrd decimal(2,0) NULL
  PRINT 'New column MrpSugWipCtl.LowUnpBillUpdPrd'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'LowUnpBillUpdJnl') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD LowUnpBillUpdJnl decimal(5,0) NULL
  PRINT 'New column MrpSugWipCtl.LowUnpBillUpdJnl'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'UnpLabUpdYear') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD UnpLabUpdYear decimal(4,0) NULL
  PRINT 'New column MrpSugWipCtl.UnpLabUpdYear'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'UnpLabUpdPeriod') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD UnpLabUpdPeriod decimal(2,0) NULL
  PRINT 'New column MrpSugWipCtl.UnpLabUpdPeriod'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'UnpBillUpdYear') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD UnpBillUpdYear decimal(4,0) NULL
  PRINT 'New column MrpSugWipCtl.UnpBillUpdYear'
END
GO
-- New column for table MrpSugWipCtl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugWipCtl' AND COLUMN_NAME = 'UnpBillUpdPeriod') = 0
BEGIN
  ALTER TABLE MrpSugWipCtl ADD UnpBillUpdPeriod decimal(2,0) NULL
  PRINT 'New column MrpSugWipCtl.UnpBillUpdPeriod'
END
GO
-- New column for table WipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspect' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE WipInspect ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column WipInspect.QtyManufacturedEnt'
END
GO
-- New column for table WipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspect' AND COLUMN_NAME = 'QtyInspectedEnt') = 0
BEGIN
  ALTER TABLE WipInspect ADD QtyInspectedEnt decimal(10,3) NULL
  PRINT 'New column WipInspect.QtyInspectedEnt'
END
GO
-- New column for table WipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspect' AND COLUMN_NAME = 'QtyAcceptedEnt') = 0
BEGIN
  ALTER TABLE WipInspect ADD QtyAcceptedEnt decimal(10,3) NULL
  PRINT 'New column WipInspect.QtyAcceptedEnt'
END
GO
-- New column for table WipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspect' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE WipInspect ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column WipInspect.QtyScrappedEnt'
END
GO
-- New column for table WipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspect' AND COLUMN_NAME = 'QtyReworkedEnt') = 0
BEGIN
  ALTER TABLE WipInspect ADD QtyReworkedEnt decimal(10,3) NULL
  PRINT 'New column WipInspect.QtyReworkedEnt'
END
GO
-- New column for table MrpWipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpWipInspect' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE MrpWipInspect ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column MrpWipInspect.QtyManufacturedEnt'
END
GO
-- New column for table MrpWipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpWipInspect' AND COLUMN_NAME = 'QtyInspectedEnt') = 0
BEGIN
  ALTER TABLE MrpWipInspect ADD QtyInspectedEnt decimal(10,3) NULL
  PRINT 'New column MrpWipInspect.QtyInspectedEnt'
END
GO
-- New column for table MrpWipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpWipInspect' AND COLUMN_NAME = 'QtyAcceptedEnt') = 0
BEGIN
  ALTER TABLE MrpWipInspect ADD QtyAcceptedEnt decimal(10,3) NULL
  PRINT 'New column MrpWipInspect.QtyAcceptedEnt'
END
GO
-- New column for table MrpWipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpWipInspect' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE MrpWipInspect ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column MrpWipInspect.QtyScrappedEnt'
END
GO
-- New column for table MrpWipInspect
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpWipInspect' AND COLUMN_NAME = 'QtyReworkedEnt') = 0
BEGIN
  ALTER TABLE MrpWipInspect ADD QtyReworkedEnt decimal(10,3) NULL
  PRINT 'New column MrpWipInspect.QtyReworkedEnt'
END
GO
-- New column for table WipInspectDet
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspectDet' AND COLUMN_NAME = 'TrnQtyEnt') = 0
BEGIN
  ALTER TABLE WipInspectDet ADD TrnQtyEnt decimal(10,3) NULL
  PRINT 'New column WipInspectDet.TrnQtyEnt'
END
GO
-- New column for table WipInspectSerial
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspectSerial' AND COLUMN_NAME = 'QtyInspectedEnt') = 0
BEGIN
  ALTER TABLE WipInspectSerial ADD QtyInspectedEnt decimal(10,3) NULL
  PRINT 'New column WipInspectSerial.QtyInspectedEnt'
END
GO
-- New column for table WipInspectSerial
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspectSerial' AND COLUMN_NAME = 'QuantityEnt') = 0
BEGIN
  ALTER TABLE WipInspectSerial ADD QuantityEnt decimal(10,3) NULL
  PRINT 'New column WipInspectSerial.QuantityEnt'
END
GO
-- New column for table WipInspectSerial
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspectSerial' AND COLUMN_NAME = 'QtyAcceptedEnt') = 0
BEGIN
  ALTER TABLE WipInspectSerial ADD QtyAcceptedEnt decimal(10,3) NULL
  PRINT 'New column WipInspectSerial.QtyAcceptedEnt'
END
GO
-- New column for table WipInspectSerial
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspectSerial' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE WipInspectSerial ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column WipInspectSerial.QtyScrappedEnt'
END
GO
-- New column for table WipInspectSerial
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipInspectSerial' AND COLUMN_NAME = 'QtyReworkedEnt') = 0
BEGIN
  ALTER TABLE WipInspectSerial ADD QtyReworkedEnt decimal(10,3) NULL
  PRINT 'New column WipInspectSerial.QtyReworkedEnt'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD GlIntUpdated char(1) NULL
  PRINT 'New column WipLabJnl.GlIntUpdated'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD GlIntPrinted char(1) NULL
  PRINT 'New column WipLabJnl.GlIntPrinted'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column WipLabJnl.GlIntYear'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column WipLabJnl.GlIntPeriod'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD GlJournal decimal(5,0) NULL
  PRINT 'New column WipLabJnl.GlJournal'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'RunTimGlCode') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD RunTimGlCode char(15) NULL
  PRINT 'New column WipLabJnl.RunTimGlCode'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'SetTimGlCode') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD SetTimGlCode char(15) NULL
  PRINT 'New column WipLabJnl.SetTimGlCode'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'StartUpTimGlCode') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD StartUpTimGlCode char(15) NULL
  PRINT 'New column WipLabJnl.StartUpTimGlCode'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'TearDownTimGlCode') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD TearDownTimGlCode char(15) NULL
  PRINT 'New column WipLabJnl.TearDownTimGlCode'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'RunTimAnaEntry') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD RunTimAnaEntry decimal(7,0) NULL
  PRINT 'New column WipLabJnl.RunTimAnaEntry'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'SetTimAnaEntry') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD SetTimAnaEntry decimal(7,0) NULL
  PRINT 'New column WipLabJnl.SetTimAnaEntry'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'StartUpAnaEntry') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD StartUpAnaEntry decimal(7,0) NULL
  PRINT 'New column WipLabJnl.StartUpAnaEntry'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'TearDownAnaEntry') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD TearDownAnaEntry decimal(7,0) NULL
  PRINT 'New column WipLabJnl.TearDownAnaEntry'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'FixOverheadGlCode') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD FixOverheadGlCode char(15) NULL
  PRINT 'New column WipLabJnl.FixOverheadGlCode'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'VarOverheadGlCode') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD VarOverheadGlCode char(15) NULL
  PRINT 'New column WipLabJnl.VarOverheadGlCode'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'FixOverAnaEntry') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD FixOverAnaEntry decimal(7,0) NULL
  PRINT 'New column WipLabJnl.FixOverAnaEntry'
END
GO
-- New column for table WipLabJnl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipLabJnl' AND COLUMN_NAME = 'VarOverAnaEntry') = 0
BEGIN
  ALTER TABLE WipLabJnl ADD VarOverAnaEntry decimal(7,0) NULL
  PRINT 'New column WipLabJnl.VarOverAnaEntry'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.IStartupQtyEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'IQuantityEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD IQuantityEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.IQuantityEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'IExpUnitRunTimEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD IExpUnitRunTimEnt decimal(9,4) NULL
  PRINT 'New column WipJobAllLab.IExpUnitRunTimEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column WipJobAllLab.ITimeTakenEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.QtyScrappedEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.TransferQtyPctEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'ParentQtyPlanEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD ParentQtyPlanEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.ParentQtyPlanEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column WipJobAllLab.OperYieldQtyEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'ParIssQtyEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD ParIssQtyEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.ParIssQtyEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'QtyCompletedEnt') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD QtyCompletedEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllLab.QtyCompletedEnt'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'ResourceMask') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD ResourceMask char(6) NULL
  PRINT 'New column WipJobAllLab.ResourceMask'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'SchStartRunDate') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD SchStartRunDate datetime NULL
  PRINT 'New column WipJobAllLab.SchStartRunDate'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'SchStartRunTime') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD SchStartRunTime decimal(4,0) NULL
  PRINT 'New column WipJobAllLab.SchStartRunTime'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'ScheduledMachine') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD ScheduledMachine char(6) NULL
  PRINT 'New column WipJobAllLab.ScheduledMachine'
END
GO
-- New column for table WipJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllLab' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE WipJobAllLab ADD AllowOpSplit char(1) NULL
  PRINT 'New column WipJobAllLab.AllowOpSplit'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.IStartupQtyEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'IQuantityEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD IQuantityEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.IQuantityEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'IExpUnitRunTimEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD IExpUnitRunTimEnt decimal(9,4) NULL
  PRINT 'New column MrpJobAllLab.IExpUnitRunTimEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column MrpJobAllLab.ITimeTakenEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.QtyScrappedEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.TransferQtyPctEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'ParentQtyPlanEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD ParentQtyPlanEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.ParentQtyPlanEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column MrpJobAllLab.OperYieldQtyEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'ParIssQtyEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD ParIssQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.ParIssQtyEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'QtyCompletedEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD QtyCompletedEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllLab.QtyCompletedEnt'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'ResourceMask') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD ResourceMask char(6) NULL
  PRINT 'New column MrpJobAllLab.ResourceMask'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'SchStartRunDate') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD SchStartRunDate datetime NULL
  PRINT 'New column MrpJobAllLab.SchStartRunDate'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'SchStartRunTime') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD SchStartRunTime decimal(4,0) NULL
  PRINT 'New column MrpJobAllLab.SchStartRunTime'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'ScheduledMachine') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD ScheduledMachine char(6) NULL
  PRINT 'New column MrpJobAllLab.ScheduledMachine'
END
GO
-- New column for table MrpJobAllLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllLab' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE MrpJobAllLab ADD AllowOpSplit char(1) NULL
  PRINT 'New column MrpJobAllLab.AllowOpSplit'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.IStartupQtyEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'IQuantityEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD IQuantityEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.IQuantityEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'IExpUnitRunTimEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD IExpUnitRunTimEnt decimal(9,4) NULL
  PRINT 'New column MrpSugJobAlLab.IExpUnitRunTimEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column MrpSugJobAlLab.ITimeTakenEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.QtyScrappedEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.TransferQtyPctEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'ParentQtyPlanEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD ParentQtyPlanEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.ParentQtyPlanEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column MrpSugJobAlLab.OperYieldQtyEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'ParIssQtyEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD ParIssQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.ParIssQtyEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'QtyCompletedEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD QtyCompletedEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlLab.QtyCompletedEnt'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'ResourceMask') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD ResourceMask char(6) NULL
  PRINT 'New column MrpSugJobAlLab.ResourceMask'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'SchStartRunDate') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD SchStartRunDate datetime NULL
  PRINT 'New column MrpSugJobAlLab.SchStartRunDate'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'SchStartRunTime') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD SchStartRunTime decimal(4,0) NULL
  PRINT 'New column MrpSugJobAlLab.SchStartRunTime'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'ScheduledMachine') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD ScheduledMachine char(6) NULL
  PRINT 'New column MrpSugJobAlLab.ScheduledMachine'
END
GO
-- New column for table MrpSugJobAlLab
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlLab' AND COLUMN_NAME = 'AllowOpSplit') = 0
BEGIN
  ALTER TABLE MrpSugJobAlLab ADD AllowOpSplit char(1) NULL
  PRINT 'New column MrpSugJobAlLab.AllowOpSplit'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ITimeTaken') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ITimeTaken decimal(9,4) NULL
  PRINT 'New column WipSplitLabAll.ITimeTaken'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'IQuantity') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD IQuantity decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.IQuantity'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'MaxOpSpan') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD MaxOpSpan decimal(4,0) NULL
  PRINT 'New column WipSplitLabAll.MaxOpSpan'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'OpSlack') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD OpSlack decimal(4,0) NULL
  PRINT 'New column WipSplitLabAll.OpSlack'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'IStartupQtyEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD IStartupQtyEnt decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.IStartupQtyEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'IQuantityEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD IQuantityEnt decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.IQuantityEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'IExpUnitRunTimEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD IExpUnitRunTimEnt decimal(9,4) NULL
  PRINT 'New column WipSplitLabAll.IExpUnitRunTimEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ITimeTakenEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ITimeTakenEnt decimal(9,4) NULL
  PRINT 'New column WipSplitLabAll.ITimeTakenEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'QtyScrappedEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD QtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.QtyScrappedEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'TransferQtyPctEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD TransferQtyPctEnt decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.TransferQtyPctEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ParentQtyPlanEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ParentQtyPlanEnt decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.ParentQtyPlanEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'OperYieldQtyEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD OperYieldQtyEnt decimal(7,3) NULL
  PRINT 'New column WipSplitLabAll.OperYieldQtyEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ParIssQtyEnt') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ParIssQtyEnt decimal(10,3) NULL
  PRINT 'New column WipSplitLabAll.ParIssQtyEnt'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ResourceMask') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ResourceMask char(6) NULL
  PRINT 'New column WipSplitLabAll.ResourceMask'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'SchStartRunDate') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD SchStartRunDate datetime NULL
  PRINT 'New column WipSplitLabAll.SchStartRunDate'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'SchStartRunTime') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD SchStartRunTime decimal(4,0) NULL
  PRINT 'New column WipSplitLabAll.SchStartRunTime'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ScheduledMachine') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ScheduledMachine char(6) NULL
  PRINT 'New column WipSplitLabAll.ScheduledMachine'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'ScheduleStatus') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD ScheduleStatus char(1) NULL
  PRINT 'New column WipSplitLabAll.ScheduleStatus'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'OpSplitFlag') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD OpSplitFlag char(1) NULL
  PRINT 'New column WipSplitLabAll.OpSplitFlag'
END
GO
-- New column for table WipSplitLabAll
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipSplitLabAll' AND COLUMN_NAME = 'MaxOpDelay') = 0
BEGIN
  ALTER TABLE WipSplitLabAll ADD MaxOpDelay decimal(4,0) NULL
  PRINT 'New column WipSplitLabAll.MaxOpDelay'
END
GO
-- New column for table WipJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllMat' AND COLUMN_NAME = 'UnitQtyReqdEnt') = 0
BEGIN
  ALTER TABLE WipJobAllMat ADD UnitQtyReqdEnt decimal(12,6) NULL
  PRINT 'New column WipJobAllMat.UnitQtyReqdEnt'
END
GO
-- New column for table WipJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllMat' AND COLUMN_NAME = 'QtyIssuedEnt') = 0
BEGIN
  ALTER TABLE WipJobAllMat ADD QtyIssuedEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllMat.QtyIssuedEnt'
END
GO
-- New column for table WipJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllMat' AND COLUMN_NAME = 'QtyBilledEnt') = 0
BEGIN
  ALTER TABLE WipJobAllMat ADD QtyBilledEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllMat.QtyBilledEnt'
END
GO
-- New column for table WipJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllMat' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE WipJobAllMat ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column WipJobAllMat.ScrapQuantityEnt'
END
GO
-- New column for table WipJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllMat' AND COLUMN_NAME = 'NetUnitQtyReqdEnt') = 0
BEGIN
  ALTER TABLE WipJobAllMat ADD NetUnitQtyReqdEnt decimal(12,6) NULL
  PRINT 'New column WipJobAllMat.NetUnitQtyReqdEnt'
END
GO
-- New column for table WipJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobAllMat' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE WipJobAllMat ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column WipJobAllMat.FixedQtyPerEnt'
END
GO
-- New column for table MrpJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllMat' AND COLUMN_NAME = 'UnitQtyReqdEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllMat ADD UnitQtyReqdEnt decimal(12,6) NULL
  PRINT 'New column MrpJobAllMat.UnitQtyReqdEnt'
END
GO
-- New column for table MrpJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllMat' AND COLUMN_NAME = 'QtyIssuedEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllMat ADD QtyIssuedEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllMat.QtyIssuedEnt'
END
GO
-- New column for table MrpJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllMat' AND COLUMN_NAME = 'QtyBilledEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllMat ADD QtyBilledEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllMat.QtyBilledEnt'
END
GO
-- New column for table MrpJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllMat' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllMat ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column MrpJobAllMat.ScrapQuantityEnt'
END
GO
-- New column for table MrpJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllMat' AND COLUMN_NAME = 'NetUnitQtyReqdEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllMat ADD NetUnitQtyReqdEnt decimal(12,6) NULL
  PRINT 'New column MrpJobAllMat.NetUnitQtyReqdEnt'
END
GO
-- New column for table MrpJobAllMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobAllMat' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE MrpJobAllMat ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column MrpJobAllMat.FixedQtyPerEnt'
END
GO
-- New column for table MrpSugJobAlMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlMat' AND COLUMN_NAME = 'UnitQtyReqdEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlMat ADD UnitQtyReqdEnt decimal(12,6) NULL
  PRINT 'New column MrpSugJobAlMat.UnitQtyReqdEnt'
END
GO
-- New column for table MrpSugJobAlMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlMat' AND COLUMN_NAME = 'QtyIssuedEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlMat ADD QtyIssuedEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlMat.QtyIssuedEnt'
END
GO
-- New column for table MrpSugJobAlMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlMat' AND COLUMN_NAME = 'QtyBilledEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlMat ADD QtyBilledEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlMat.QtyBilledEnt'
END
GO
-- New column for table MrpSugJobAlMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlMat' AND COLUMN_NAME = 'ScrapQuantityEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlMat ADD ScrapQuantityEnt decimal(7,3) NULL
  PRINT 'New column MrpSugJobAlMat.ScrapQuantityEnt'
END
GO
-- New column for table MrpSugJobAlMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlMat' AND COLUMN_NAME = 'NetUnitQtyReqdEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlMat ADD NetUnitQtyReqdEnt decimal(12,6) NULL
  PRINT 'New column MrpSugJobAlMat.NetUnitQtyReqdEnt'
END
GO
-- New column for table MrpSugJobAlMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobAlMat' AND COLUMN_NAME = 'FixedQtyPerEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobAlMat ADD FixedQtyPerEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobAlMat.FixedQtyPerEnt'
END
GO
-- New column for table WipMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipMaster' AND COLUMN_NAME = 'QtyToMakeEnt') = 0
BEGIN
  ALTER TABLE WipMaster ADD QtyToMakeEnt decimal(10,3) NULL
  PRINT 'New column WipMaster.QtyToMakeEnt'
END
GO
-- New column for table WipMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipMaster' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE WipMaster ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column WipMaster.QtyManufacturedEnt'
END
GO
-- New column for table WipMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipMaster' AND COLUMN_NAME = 'TotQtyScrappedEnt') = 0
BEGIN
  ALTER TABLE WipMaster ADD TotQtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column WipMaster.TotQtyScrappedEnt'
END
GO
-- New column for table WipMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipMaster' AND COLUMN_NAME = 'GrossQtyEnt') = 0
BEGIN
  ALTER TABLE WipMaster ADD GrossQtyEnt decimal(10,3) NULL
  PRINT 'New column WipMaster.GrossQtyEnt'
END
GO
-- New column for table MrpJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobMaster' AND COLUMN_NAME = 'QtyToMakeEnt') = 0
BEGIN
  ALTER TABLE MrpJobMaster ADD QtyToMakeEnt decimal(10,3) NULL
  PRINT 'New column MrpJobMaster.QtyToMakeEnt'
END
GO
-- New column for table MrpJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobMaster' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE MrpJobMaster ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column MrpJobMaster.QtyManufacturedEnt'
END
GO
-- New column for table MrpJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobMaster' AND COLUMN_NAME = 'TotQtyScrappedEnt') = 0
BEGIN
  ALTER TABLE MrpJobMaster ADD TotQtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column MrpJobMaster.TotQtyScrappedEnt'
END
GO
-- New column for table MrpJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpJobMaster' AND COLUMN_NAME = 'GrossQtyEnt') = 0
BEGIN
  ALTER TABLE MrpJobMaster ADD GrossQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpJobMaster.GrossQtyEnt'
END
GO
-- New column for table MrpSugJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobMaster' AND COLUMN_NAME = 'QtyToMakeEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobMaster ADD QtyToMakeEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobMaster.QtyToMakeEnt'
END
GO
-- New column for table MrpSugJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobMaster' AND COLUMN_NAME = 'QtyManufacturedEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobMaster ADD QtyManufacturedEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobMaster.QtyManufacturedEnt'
END
GO
-- New column for table MrpSugJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobMaster' AND COLUMN_NAME = 'TotQtyScrappedEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobMaster ADD TotQtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobMaster.TotQtyScrappedEnt'
END
GO
-- New column for table MrpSugJobMaster
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'MrpSugJobMaster' AND COLUMN_NAME = 'GrossQtyEnt') = 0
BEGIN
  ALTER TABLE MrpSugJobMaster ADD GrossQtyEnt decimal(10,3) NULL
  PRINT 'New column MrpSugJobMaster.GrossQtyEnt'
END
GO
-- New column for table WipPartBook
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipPartBook' AND COLUMN_NAME = 'QtySuppliedEnt') = 0
BEGIN
  ALTER TABLE WipPartBook ADD QtySuppliedEnt decimal(10,3) NULL
  PRINT 'New column WipPartBook.QtySuppliedEnt'
END
GO
-- New column for table WipPartBook
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipPartBook' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE WipPartBook ADD GlIntUpdated char(1) NULL
  PRINT 'New column WipPartBook.GlIntUpdated'
END
GO
-- New column for table WipPartBook
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipPartBook' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE WipPartBook ADD GlIntPrinted char(1) NULL
  PRINT 'New column WipPartBook.GlIntPrinted'
END
GO
-- New column for table WipPartBook
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipPartBook' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE WipPartBook ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column WipPartBook.GlIntYear'
END
GO
-- New column for table WipPartBook
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipPartBook' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE WipPartBook ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column WipPartBook.GlIntPeriod'
END
GO
-- New column for table WipPartBook
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipPartBook' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE WipPartBook ADD GlJournal decimal(5,0) NULL
  PRINT 'New column WipPartBook.GlJournal'
END
GO
-- New column for table WipDistrMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipDistrMat' AND COLUMN_NAME = 'GlIntUpdated') = 0
BEGIN
  ALTER TABLE WipDistrMat ADD GlIntUpdated char(1) NULL
  PRINT 'New column WipDistrMat.GlIntUpdated'
END
GO
-- New column for table WipDistrMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipDistrMat' AND COLUMN_NAME = 'GlIntPrinted') = 0
BEGIN
  ALTER TABLE WipDistrMat ADD GlIntPrinted char(1) NULL
  PRINT 'New column WipDistrMat.GlIntPrinted'
END
GO
-- New column for table WipDistrMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipDistrMat' AND COLUMN_NAME = 'GlIntYear') = 0
BEGIN
  ALTER TABLE WipDistrMat ADD GlIntYear decimal(4,0) NULL
  PRINT 'New column WipDistrMat.GlIntYear'
END
GO
-- New column for table WipDistrMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipDistrMat' AND COLUMN_NAME = 'GlIntPeriod') = 0
BEGIN
  ALTER TABLE WipDistrMat ADD GlIntPeriod decimal(2,0) NULL
  PRINT 'New column WipDistrMat.GlIntPeriod'
END
GO
-- New column for table WipDistrMat
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipDistrMat' AND COLUMN_NAME = 'GlJournal') = 0
BEGIN
  ALTER TABLE WipDistrMat ADD GlJournal decimal(5,0) NULL
  PRINT 'New column WipDistrMat.GlJournal'
END
GO
-- New column for table WipJobPost
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobPost' AND COLUMN_NAME = 'MQtyIssuedEnt') = 0
BEGIN
  ALTER TABLE WipJobPost ADD MQtyIssuedEnt decimal(10,3) NULL
  PRINT 'New column WipJobPost.MQtyIssuedEnt'
END
GO
-- New column for table WipJobPost
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobPost' AND COLUMN_NAME = 'MSerial') = 0
BEGIN
  ALTER TABLE WipJobPost ADD MSerial char(20) NULL
  PRINT 'New column WipJobPost.MSerial'
END
GO
-- New column for table WipJobPost
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobPost' AND COLUMN_NAME = 'MUnitCostActual') = 0
BEGIN
  ALTER TABLE WipJobPost ADD MUnitCostActual decimal(15,5) NULL
  PRINT 'New column WipJobPost.MUnitCostActual'
END
GO
-- New column for table WipJobPost
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobPost' AND COLUMN_NAME = 'LQtyScrappedEnt') = 0
BEGIN
  ALTER TABLE WipJobPost ADD LQtyScrappedEnt decimal(10,3) NULL
  PRINT 'New column WipJobPost.LQtyScrappedEnt'
END
GO
-- New column for table WipJobPost
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobPost' AND COLUMN_NAME = 'LQtyCompleteEnt') = 0
BEGIN
  ALTER TABLE WipJobPost ADD LQtyCompleteEnt decimal(10,3) NULL
  PRINT 'New column WipJobPost.LQtyCompleteEnt'
END
GO
-- New column for table WipJobPost
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'WipJobPost' AND COLUMN_NAME = 'LRunTimeHoursEnt') = 0
BEGIN
  ALTER TABLE WipJobPost ADD LRunTimeHoursEnt decimal(7,2) NULL
  PRINT 'New column WipJobPost.LRunTimeHoursEnt'
END
GO


-----------------------------------------------------
--   Columns changed in size

-- Columns ArCustomerBal..SalesValMth(1-26) changed from decimal(12,0) to decimal(14,2)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ArCustomerBal' AND COLUMN_NAME = 'SalesValMth26') <> 7
BEGIN
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth1  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth2  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth3  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth4  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth5  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth6  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth7  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth8  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth9  decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth10 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth11 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth12 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth13 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth14 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth15 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth16 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth17 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth18 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth19 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth20 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth21 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth22 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth23 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth24 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth25 decimal(14,2) NULL
    ALTER TABLE ArCustomerBal ALTER COLUMN SalesValMth26 decimal(14,2) NULL
    PRINT 'Column ArCustomerBal..SalesValMth(1-26) changed to decimal(14,2)'
END
GO

-- Column AssetDepreciation..AnnualDepnPct changed from decimal(5,2) to decimal(7,4)
IF (SELECT NUMERIC_PRECISION FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AssetDepreciation' AND COLUMN_NAME = 'AnnualDepnPct') <> 7
BEGIN
    ALTER TABLE AssetDepreciation ALTER COLUMN AnnualDepnPct decimal(7,4) NULL
    PRINT 'Column AssetDepreciation..AnnualDepnPct changed to decimal(7,4)'
END
GO


-- Column CshApPayments..Cheque changed from char(6) to decimal(6,0)

-- Must first drop index that references 'Cheque' column
DROP INDEX CshApPayments.CshApPaymentsIdxSupChq
GO
-- Now change datatype of 'Cheque' column
IF (SELECT DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'CshApPayments' AND COLUMN_NAME = 'Cheque') <> 'decimal'
BEGIN
    ALTER TABLE CshApPayments ALTER COLUMN Cheque decimal(6,0) NULL
    PRINT 'Column CshApPayments..Cheque changed to decimal(6,0)'
END
GO
-- Now re-apply index
CREATE UNIQUE INDEX CshApPaymentsIdxSupChq ON CshApPayments(
 Bank,
 CbTrnYear,
 TrnMonth,
 Cheque,
 ChequeType,
 CbTrnDate,
 CbTrnTime,
 EntryNumber
 )
GO


-- Column GenJournalDetail..Reference changed from char(9) to char(30)
IF (SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'GenJournalDetail' AND COLUMN_NAME = 'Reference') <> 40
BEGIN
    ALTER TABLE GenJournalDetail ALTER COLUMN Reference char(30) NULL
    PRINT 'Column GenJournalDetail..Contact Reference to char(30)'
END
GO

-- Column GenRecJnlDet..Reference changed from char(9) to char(30)
IF (SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'GenRecJnlDet' AND COLUMN_NAME = 'Reference') <> 40
BEGIN
    ALTER TABLE GenRecJnlDet ALTER COLUMN Reference char(30) NULL
    PRINT 'Column GenRecJnlDet..Contact Reference to char(30)'
END
GO

-- Column GenStdJnlDet..Reference changed from char(9) to char(30)
IF (SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'GenStdJnlDet' AND COLUMN_NAME = 'Reference') <> 40
BEGIN
    ALTER TABLE GenStdJnlDet ALTER COLUMN Reference char(30) NULL
    PRINT 'Column GenStdJnlDet..Contact Reference to char(30)'
END
GO

-- Column RmaMaster..Contact changed from char(20) to char(40)
IF (SELECT CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'RmaMaster' AND COLUMN_NAME = 'Contact') <> 40
BEGIN
    ALTER TABLE RmaMaster ALTER COLUMN Contact char(40) NULL
    PRINT 'Column RmaMaster..Contact changed to char(40)'
END
GO


-------------------------------------------------------------------------
-- Changes to primary index

--  ArDiscDrCrDet has a 'Sequence' column insert into the primary key
--  The 'Sequence' column did not exist prior to this change
--  The Sequence column will be set to zeros

--  First ensure that Sequence column has a value - defaults to zero
UPDATE ArDiscDrCrDet
  SET Sequence = 0
  WHERE Sequence IS NULL

--  Next drop existing alternate indexes
IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ArDiscDrCrDetIdxTrn') <> 0
BEGIN    
    PRINT 'Dropping old format key ArDiscDrCrDetIdxTrn'
    DROP INDEX ArDiscDrCrDet.ArDiscDrCrDetIdxTrn
END
GO
IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ArDiscDrCrDetIdxPay') <> 0
BEGIN    
    PRINT 'Dropping old format key ArDiscDrCrDetIdxPay'
    DROP INDEX ArDiscDrCrDet.ArDiscDrCrDetIdxPay
END
GO

--  Then drop existing primary key
IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ArDiscDrCrDetKey') <> 0
BEGIN    
    PRINT 'Dropping old format key ArDiscDrCrDetKey'
    ALTER TABLE ArDiscDrCrDet
       DROP CONSTRAINT ArDiscDrCrDetKey
END
GO

-- Ensure that Sequence is not NULLABLE
IF (SELECT IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'ArDiscDrCrDet' AND COLUMN_NAME = 'Sequence') = 'YES'
BEGIN    
    PRINT 'Converting ArDiscDrCrDet.Sequence to NOT NULLABLE'
    ALTER TABLE ArDiscDrCrDet
      ALTER COLUMN Sequence decimal(6,0) NOT NULL
END
GO

PRINT 'Recreating key for table ArDiscDrCrDet'
ALTER TABLE ArDiscDrCrDet
  ADD CONSTRAINT ArDiscDrCrDetKey PRIMARY KEY CLUSTERED
  (
   Customer,
   DiscDrCr,
   Sequence,
   DocumentType,
   Invoice
  )
PRINT 'Added new format key ArDiscDrCrDetKey'
GO

--  Lastly reapply alternate indexes
CREATE UNIQUE INDEX ArDiscDrCrDetIdxTrn ON ArDiscDrCrDet(
 Customer,
 Invoice,
 DocumentType,
 EntryNumber,
 DiscDrCr,
 Sequence
 )
PRINT 'Added new format key ArDiscDrCrDetIdxTrn'
GO

CREATE UNIQUE INDEX ArDiscDrCrDetIdxPay ON ArDiscDrCrDet(
 Customer,
 PayDate,
 CashJournal,
 JnlEntry,
 Invoice,
 DocumentType,
 DiscDrCr,
 Sequence
 )
PRINT 'Added new format key ArDiscDrCrDetIdxPay'
GO


-------------------------------------------------------------------------
-- Changes to primary index

--  IopProxies has a 'Warehouse' column insert into the primary key
--  The 'Warehouse' column did not exist prior to this change
--  The Warehouse column will be set to spaces

--  First ensure that Warehouse column has a value - defaults to spaces
UPDATE IopProxies
  SET Warehouse = ' '
  WHERE Warehouse IS NULL

--  Next drop existing alternate indexes
IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'IopProxiesIdxPrxStk') <> 0
BEGIN    
    PRINT 'Dropping old format key IopProxiesIdxPrxStk'
    DROP INDEX IopProxies.IopProxiesIdxPrxStk
END
GO

--  Then drop existing primary key
IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'IopProxiesKey') <> 0
BEGIN    
    PRINT 'Dropping old format key IopProxiesKey'
    ALTER TABLE IopProxies
      DROP CONSTRAINT IopProxiesKey
END
GO

-- Ensure that Warehouse is not NULLABLE
IF (SELECT IS_NULLABLE FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'IopProxies' AND COLUMN_NAME = 'Warehouse') = 'YES'
BEGIN    
    PRINT 'Converting IopProxies.Warehouse to NOT NULLABLE'
    ALTER TABLE IopProxies
      ALTER COLUMN Warehouse char(2) NOT NULL
END
GO

PRINT 'Recreating key for table IopProxies'
ALTER TABLE IopProxies
  ADD CONSTRAINT IopProxiesKey PRIMARY KEY CLUSTERED
  (
         StockCode,
         Version,
         Release,
         Warehouse
  )
PRINT 'Added new format key IopProxiesKey'
GO

CREATE UNIQUE INDEX IopProxiesIdxPrxStk ON IopProxies(
 ProxyStockCode,
 ProxyVersion,
 ProxyRelease,
 ProxyWarehouse,
 StockCode,
 Version,
 Release,
 Warehouse
 )
PRINT 'Added new format key IopProxiesIdxPrxStk'
GO



-------------------------------------------------------------------------
-- New indexes

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ApGlDisburseIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX ApGlDisburseIdxGlJnl ON ApGlDisburse(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     ChequeRegister,
     DistrEntry,
     GlYear,
     GlPeriod,
     GlCode,
     Supplier
     )
    PRINT 'Added new key ApGlDisburseIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ApGlDisburseIdxGlJnl') = 0
BEGIN 
    CREATE UNIQUE INDEX ApGlDisburseIdxGiUpd ON ApGlDisburse(
     GlIntUpdated,
     ChequeRegister,
     GlYear,
     GlPeriod,
     GlCode,
     Supplier,
     DistrEntry
     )   
    PRINT 'Added new key ApGlDisburseIdxGiUpd'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ApGlDisburseIdxGlJnl') = 0
BEGIN 
    CREATE UNIQUE INDEX ApGlDisburseIdxReg ON ApGlDisburse(
     ChequeRegister,
     GlYear,
     GlPeriod,
     GlCode,
     Supplier,
     DistrEntry
     )
    PRINT 'Added new key ApGlDisburseIdxReg'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'AssetDistRegIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX AssetDistRegIdxGlJnl ON AssetDistReg(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     DistRegNum,
     Entry,
     GlYear,
     GlPeriod,
     GlCode
     )
    PRINT 'Added new key AssetDistRegIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'AssetDistRegIdxGlJnl') = 0
BEGIN 
    CREATE UNIQUE INDEX AssetDistRegIdxGiUpd ON AssetDistReg(
     GlIntUpdated,
     DistRegNum,
     GlYear,
     GlPeriod,
     GlCode,
     Entry
     )   
    PRINT 'Added new key AssetDistRegIdxGiUpd'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'AssetDistRegIdxGlJnl') = 0
BEGIN 
    CREATE UNIQUE INDEX AssetDistRegIdxReg ON AssetDistReg(
     DistRegNum,
     GlYear,
     GlPeriod,
     GlCode,
     Entry
     )   
    PRINT 'Added new key AssetDistRegIdxReg'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'BomResourceMaskIdxMch') = 0
BEGIN    
    CREATE UNIQUE INDEX BomResourceMaskIdxMch ON BomResourceMask(
     Machine,
     WorkCentre,
     ResourceMask
     )
    PRINT 'Added new key BomResourceMaskIdxMch'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'BomToolSetToolsIdxTool') = 0
BEGIN    
    CREATE UNIQUE INDEX BomToolSetToolsIdxTool ON BomToolSetTools(
     Tool,
     Toolset
     )
    PRINT 'Added new key BomToolSetToolsIdxTool'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'CrmAccountIdxSup') = 0
BEGIN    
    CREATE UNIQUE INDEX CrmAccountIdxSup ON CrmAccount(
     Supplier,
     Account
     )
    PRINT 'Added new key CrmAccountIdxSup'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'CrmActivityIdxStartDat') = 0
BEGIN    
    CREATE UNIQUE INDEX CrmActivityIdxStartDat ON CrmActivity(
     StartDate,
     StartTime,
     ContactId
     )
    PRINT 'Added new key CrmActivityIdxStartDat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'CrmActivityIdxStartDat') = 0
BEGIN 
    CREATE UNIQUE INDEX CrmActivityIdxOwner ON CrmActivity(
     OwnerOper,
     StartDate,
     StartTime,
     ContactId
     )   
    PRINT 'Added new key CrmActivityIdxOwner'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'CrmActivityIdxStartDat') = 0
BEGIN 
    CREATE UNIQUE INDEX CrmActivityIdxCreated ON CrmActivity(
     CreatedBy,
     StartDate,
     StartTime,
     ContactId
     )
    PRINT 'Added new key CrmActivityIdxCreated'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'CshJnlCtlIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX CshJnlCtlIdxGlJnl ON CshJnlCtl(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     CbTrnYear,
     CbTrnMonth,
     Journal
     )
    PRINT 'Added new key CshJnlCtlIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'EftBatchCtlIdxDate') = 0
BEGIN    
    CREATE UNIQUE INDEX EftBatchCtlIdxDate ON EftBatchCtl(
     OriginalRunDate,
     EftBatch
     )
    PRINT 'Added new key EftBatchCtlIdxDate'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'GenJournalCtlIdxSource') = 0
BEGIN    
    CREATE UNIQUE INDEX GenJournalCtlIdxSource ON GenJournalCtl(
     JournalSource,
     Type,
     GlYear,
     GlPeriod,
     GlJournal
     )
    PRINT 'Added new key GenJournalCtlIdxSource'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'GrnJournalIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX GrnJournalIdxGlJnl ON GrnJournal(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     GrnJournal,
     JournalEntry,
     JournalYear,
     JournalMonth
     )
    PRINT 'Added new key GrnJournalIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'GtrFifoTransferIdxLotSer') = 0
BEGIN    
    CREATE UNIQUE INDEX GtrFifoTransferIdxLotSer ON GtrFifoTransfer(
     GtrReference,
     StockCode,
     LotSerial,
     SourceWarehouse,
     TargetWarehouse,
     Line,
     DateCreated,
     TimeCreated
     )
    PRINT 'Added new key GtrFifoTransferIdxLotSer'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'InvFifoLifoIdxLotSer') = 0
BEGIN    
    CREATE UNIQUE INDEX InvFifoLifoIdxLotSer ON InvFifoLifo(
     StockCode,
     Version,
     Release,
     Warehouse,
     LotSerial,
     Bucket
     )
    PRINT 'Added new key InvFifoLifoIdxLotSer'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'InvJournalCtlIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX InvJournalCtlIdxGlJnl ON InvJournalCtl(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     YearPost,
     MonthPost,
     Journal
     )
    PRINT 'Added new key InvJournalCtlIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'InvMovementsIdxIoFlag') = 0
BEGIN    
    CREATE UNIQUE INDEX InvMovementsIdxIoFlag ON InvMovements(
     IoProcessedFlag,
     StockCode,
     Warehouse,
     EntryDate,
     TrnTime,
     TrnYear,
     TrnMonth
     )
    PRINT 'Added new key InvMovementsIdxIoFlag'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'InvTransFifoLifoIdxLotSer') = 0
BEGIN    
    CREATE UNIQUE INDEX InvTransFifoLifoIdxLotSer ON InvTransFifoLifo(
     StockCode,
     Version,
     Release,
     RecevieWh,
     LotSerial,
     DateCreated,
     TimeCreated
     )
    PRINT 'Added new key InvTransFifoLifoIdxLotSer'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'IopSalesAdjustIdxType') = 0
BEGIN    
    CREATE UNIQUE INDEX IopSalesAdjustIdxType ON IopSalesAdjust(
     AdjustType,
     StockCode,
     Version,
     Release,
     Warehouse,
     MovementDate,
     EntryNumber
     )
    PRINT 'Added new key IopSalesAdjustIdxType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'IopWarehouseIdxIdNo') = 0
BEGIN    
    CREATE UNIQUE INDEX IopWarehouseIdxIdNo ON IopWarehouse(
     IdNumber,
     StockCode,
     Version,
     Release,
     Warehouse
     )
    PRINT 'Added new key IopWarehouseIdxIdNo'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MdnDetailIdxSodtStat') = 0
BEGIN    
    CREATE UNIQUE INDEX MdnDetailIdxSodtStat ON MdnDetail(
     SalesOrderDetStat,
     DispatchNote,
     DispatchNoteLine
     )
    PRINT 'Added new key MdnDetailIdxSodtStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MdnMasterIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX MdnMasterIdxDetStat ON MdnMaster(
     DetailStatus,
     DispatchNote
     )
    PRINT 'Added new key MdnMasterIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSnapForecastIdxCus') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSnapForecastIdxCus ON MrpSnapForecast(
     Customer,
     InactiveFlag,
     StockCode,
     ForecastWh,
     ForecastDate,
     Line
     )
    PRINT 'Added new key MrpSnapForecastIdxCus'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSnapForecastIdxActive') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSnapForecastIdxActive ON MrpSnapForecast(
     InactiveFlag,
     StockCode,
     ForecastWh,
     ForecastDate,
     Line
     )
    PRINT 'Added new key MrpSnapForecastIdxActive'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpQotSoDetailIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpQotSoDetailIdxDetStat ON MrpQotSoDetail(
     SalesOrderDetStat,
     SalesOrder,
     SalesOrderLine
     )
    PRINT 'Added new key MrpQotSoDetailIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpQotSoMasterHdrIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpQotSoMasterHdrIdxDetStat ON MrpQotSoMasterHdr(
     CancelledFlag,
     DetailStatus,
     SalesOrder
     )
    PRINT 'Added new key MrpQotSoMasterHdrIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'QotStructureIdxOffset') = 0
BEGIN    
    CREATE UNIQUE INDEX QotStructureIdxOffset ON QotStructure(
     ParentPart,
     Route,
     OperationFlag,
     Operation,
     SequenceNum,
     Component
     )
    PRINT 'Added new key QotStructureIdxOffset'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ReqDetailIdxType') = 0
BEGIN    
    CREATE UNIQUE INDEX ReqDetailIdxType ON ReqDetail(
     RequisitionType,
     Originator,
     Requisition,
     Line
     )
    PRINT 'Added new key ReqDetailIdxType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ReqDetailIdxUsType') = 0
BEGIN    
    CREATE UNIQUE INDEX ReqDetailIdxUsType ON ReqDetail(
     Originator,
     RequisitionType,
     Requisition,
     Line
     )
    PRINT 'Added new key ReqDetailIdxUsType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSnapForecastIdxCus') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSnapForecastIdxCus ON MrpSnapForecast(
     Customer,
     InactiveFlag,
     StockCode,
     ForecastWh,
     ForecastDate,
     Line
     )
    PRINT 'Added new key MrpSnapForecastIdxCus'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSnapForecastIdxActive') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSnapForecastIdxActive ON MrpSnapForecast(
     InactiveFlag,
     StockCode,
     ForecastWh,
     ForecastDate,
     Line
     )
    PRINT 'Added new key MrpSnapForecastIdxActive'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSugReqDetailIdxType') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSugReqDetailIdxType ON MrpSugReqDetail(
     RequisitionType,
     Originator,
     Requisition,
     Line
     )
    PRINT 'Added new key MrpSugReqDetailIdxType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSugReqDetailIdxUsType') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSugReqDetailIdxUsType ON MrpSugReqDetail(
     Originator,
     RequisitionType,
     Requisition,
     Line
     )
    PRINT 'Added new key MrpSugReqDetailIdxUsType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSoDetailIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSoDetailIdxDetStat ON MrpSoDetail(
     SalesOrderDetStat,
     SalesOrder,
     SalesOrderLine
     )
    PRINT 'Added new key MrpSoDetailIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'MrpSoMasterHdrIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX MrpSoMasterHdrIdxDetStat ON MrpSoMasterHdr(
     CancelledFlag,
     DetailStatus,
     SalesOrder
     )
    PRINT 'Added new key MrpSoMasterHdrIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'PorHistReceiptIdxStk') = 0
BEGIN    
    CREATE UNIQUE INDEX PorHistReceiptIdxStk ON PorHistReceipt(
     StockCode,
     Version,
     Release,
     Warehouse,
     Supplier,
     JnlDate,
     Journal,
     JournalEntry
     )
    PRINT 'Added new key PorHistReceiptIdxStk'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'QotSoMasterHdrIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX QotSoMasterHdrIdxDetStat ON QotSoMasterHdr(
     CancelledFlag,
     DetailStatus,
     SalesOrder
     )
    PRINT 'Added new key QotSoMasterHdrIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'QotStructureIdxOffset') = 0
BEGIN    
    CREATE UNIQUE INDEX QotStructureIdxOffset ON QotStructure(
     ParentPart,
     Route,
     OperationFlag,
     Operation,
     SequenceNum,
     Component
     )
    PRINT 'Added new key QotStructureIdxOffset'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ReqDetailIdxType') = 0
BEGIN    
    CREATE UNIQUE INDEX ReqDetailIdxType ON ReqDetail(
     RequisitionType,
     Originator,
     Requisition,
     Line
     )
    PRINT 'Added new key ReqDetailIdxType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ReqDetailIdxUsType') = 0
BEGIN    
    CREATE UNIQUE INDEX ReqDetailIdxUsType ON ReqDetail(
     Originator,
     RequisitionType,
     Requisition,
     Line
     )
    PRINT 'Added new key ReqDetailIdxUsType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ReqRoutedToUserIdxType') = 0
BEGIN    
    CREATE UNIQUE INDEX ReqRoutedToUserIdxType ON ReqRoutedToUser(
     RequisitionType,
     UserCode,
     Status,
     Requisition,
     RequisitionLine
     )
    PRINT 'Added new key ReqRoutedToUserIdxType'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'ReqUserIdxGroup') = 0
BEGIN    
    CREATE UNIQUE INDEX ReqUserIdxGroup ON ReqUser(
     RequisitionGroup,
     UserCode
     )
    PRINT 'Added new key ReqUserIdxGroup'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'SorDetailIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX SorDetailIdxDetStat ON SorDetail(
     SalesOrderDetStat,
     SalesOrder,
     SalesOrderLine
     )
    PRINT 'Added new key SorDetailIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'SorLostSalesIdxStk') = 0
BEGIN    
    CREATE UNIQUE INDEX SorLostSalesIdxStk ON SorLostSales(
     StockCode,
     Version,
     Release,
     Warehouse,
     TrnDate,
     TrnTime
     )
    PRINT 'Added new key SorLostSalesIdxStk'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'SorLostSalesIdxSord') = 0
BEGIN    
    CREATE UNIQUE INDEX SorLostSalesIdxSord ON SorLostSales(
     SalesOrder,
     SalesOrderLine,
     TrnDate,
     TrnTime
     )
    PRINT 'Added new key SorLostSalesIdxSord'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'SorMasterIdxDetStat') = 0
BEGIN    
    CREATE UNIQUE INDEX SorMasterIdxDetStat ON SorMaster(
     CancelledFlag,
     DetailStatus,
     SalesOrder
     )
    PRINT 'Added new key SorMasterIdxDetStat'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'SorRouteSoDetailIdxDispatch') = 0
BEGIN    
    CREATE UNIQUE INDEX SorRouteSoDetailIdxDispatch ON SorRouteSoDetail(
     DispatchNote,
     DispatchNoteLine,
     SalesOrder,
     SalesOrderLine,
     RouteCode,
     DeliveryDate,
     DeliverySeq
     )
    PRINT 'Added new key SorRouteSoDetailIdxDispatch'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'TpmJournalIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX TpmJournalIdxGlJnl ON TpmJournal(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     TrnYear,
     TrnMonth,
     Journal
     )
    PRINT 'Added new key TpmJournalIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'WipDistrMatIdxGlJnl') = 0
BEGIN    
    CREATE UNIQUE INDEX WipDistrMatIdxGlJnl ON WipDistrMat(
     GlIntYear,
     GlIntPeriod,
     GlJournal,
     Journal,
     EntryNumber,
     GlYear,
     GlPeriod,
     GlCode
     )
    PRINT 'Added new key WipDistrMatIdxGlJnl'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'WipDistrMatIdxGlJnl') = 0
BEGIN
    CREATE UNIQUE INDEX WipDistrMatIdxGiUpd ON WipDistrMat(
     GlIntUpdated,
     Journal,
     GlYear,
     GlPeriod,
     GlCode,
     EntryNumber
     )    
    PRINT 'Added new key WipDistrMatIdxGiUpd'
END
GO

IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'WipDistrMatIdxGlJnl') = 0
BEGIN
    CREATE UNIQUE INDEX WipDistrMatIdxJnl ON WipDistrMat(
     Journal,
     GlYear,
     GlPeriod,
     GlCode,
     EntryNumber
     )  
    PRINT 'Added new key WipDistrMatIdxJnl'
END
GO

-------------------------------------------------------------------------
--  Asset Master table logic
--  If an old column exists in the Asset Master table and
--  the temp table does not exist then
--  copy the entire table to a temporary table
--  The 6.1 conversion process will read the temp table,
--  clear the live one and then drop the temp one.

--  Create a temp SP2 Asset Master table
--  Add new format 'AssetMaster' Table

DECLARE @UPD NCHAR(4000)
SET @UPD = N'
  SELECT 
      Asset,
      Description,
      Location,
      AssetType,
      RegistrationNum,
      ChassisNum,
      Engine,
      AgreementNum,
      PurchaseDate,
      FirstInstalDate,
      DateSold,
      Branch,
      GlCode,
      AssetGroupCode,
      AgreementCode,
      NewOldFlag,
      LeasePeriod,
      Price,
      TotalInterest,
      MonthlyInstal,
      StartDepnPeriod,
      InvestAllowPct,
      InitialAllowPct,
      RevalDepnPrevYr,
      AccumDepnReval,
      CurRevalueValue,
      MtdPurchases,
      MtdLabour,
      MtdRevenue,
      YtdPurchases,
      YtdLabour,
      YtdRevenue,
      BookDepnPrevYr,
      YtdInterestPaid,
      YtdInstallments,
      AccumPurchases,
      AccumLabour,
      AccumRevenue,
      AccumBookvalDepn,
      AccumInterest,
      AccumInstallments,
      SoldValue,
      CapitalOutst,
      InterestOutst,
      CurBookValue,
      DepositValue,
      TaxPaid,
      InitialAllowVal,
      InvestAllowVal,
      AnnualRevalPct,
      NextTrnLine,
      AllowTakenFlag,
      FinalInstallment,
      TaxDepnPrevYr,
      AccumDepnTax,
      CurTaxValue,
      NewRevaluedCost,
      RevaluationDate,
      BookDepMthSold,
      RevDepMthSold,
      WearTearDep,
      BookValDep,
      StartDep,
      AccountType,
      DepnStartPeriod,
      DepPrdMthSold,
      BookValDepDate,
      BookValDepnFlag,
      WearDepStDate,
      BookValResidual,
      WearTearResidual,
      GroupCodePrevMth,
      AssetId,
      PrevLocation,
      AssetCostCenter,
      CapexCode,
      CycleCount,
      RespUser,
      AssetOwner,
      PrevBranch,
      DepnPrevYrAlt1,
      AccumDepnAlt1,
      AssetValueAlt1,
      NewValueAlt1,
      ValuationDateAlt1,
      BookValCodeAlt1,
      BookDepnYtdAlt1,
      DepnPrevYrAlt2,
      AccumDepnAlt2,
      AssetValueAlt2,
      NewValueAlt2,
      ValuationDateAlt2,
      BookValCodeAlt2,
      BookDepnYtdAlt2,
      DepnPrevYrAlt3,
      AccumDepnAlt3,
      AssetValueAlt3,
      NewValueAlt3,
      ValuationDateAlt3,
      BookValCodeAlt3,
      BookDepnYtdAlt3,
      Suspend,
      DepreciableCost,
      TaxCost,
      CapitalGainsTaxVal,
      OriginalAssetQty,
      AssetQty,
      BookDepnYtd,
      TaxDepnYtd,
      DisposalReason,
      AssetStatus,
      RevalReason,
      OriginalAssetValue,
      Supplier,
      DisposalCost,
      DepnThisPeriod,
      OrigStartDepnDate,
      OrigStartPeriod,
      OrigStartYear,
      StartYear,
      PeriodBalance,
      ThruputThisYear,
      ThruputPrevYear,
      ThruputAccum,
      ThruputAnnum,
      RevalReserveToDate,
      StatGlCode,
      MasterAsset,
      UserDef1,
      UserDef2,
      UserDef3,
      UserDef4,
      TotalPeriods,
      MemoDate,
      TaxStartPeriod,
      SumYears,
      CapexLine
    INTO AssetMasterSp2 FROM AssetMaster'
    

IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_NAME = 'AssetMaster' AND COLUMN_NAME = 'Price') <> 0
BEGIN
  IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
      WHERE TABLE_NAME = 'AssetMasterSp2') = 0

   EXEC sp_executesql @UPD   
   
   PRINT 'Copied SP2 Asset Master to temp table AssetMasterSp2'
END
GO
 
-------------------------------------------------------------------------

-- Drop obsolete columns

--  AssetControl
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'DepnYear') <> 0
BEGIN
  ALTER TABLE AssetControl DROP COLUMN DepnYear
  PRINT 'Dropped obsolete column AssetControl.DepnYear'
END
GO
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'DistEntryNumber') <> 0
BEGIN
  ALTER TABLE AssetControl DROP COLUMN DistEntryNumber
  PRINT 'Dropped obsolete column AssetControl.DistEntryNumber'
END
GO
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'TaxPeriod') <> 0
BEGIN
  ALTER TABLE AssetControl DROP COLUMN TaxPeriod
  PRINT 'Dropped obsolete column AssetControl.TaxPeriod'
END
GO
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetControl' AND COLUMN_NAME = 'TaxYear') <> 0
BEGIN
  ALTER TABLE AssetControl DROP COLUMN TaxYear
  PRINT 'Dropped obsolete column AssetControl.TaxYear'
END
GO


--  AssetGroup
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'AssetGlCode') <> 0
BEGIN
  ALTER TABLE AssetGroup DROP COLUMN AssetGlCode
  PRINT 'Dropped obsolete column AssetGroup.AssetGlCode'
END
GO
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'AccumDepGlCode') <> 0
BEGIN
  ALTER TABLE AssetGroup DROP COLUMN AccumDepGlCode
  PRINT 'Dropped obsolete column AssetGroup.AccumDepGlCode'
END
GO
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'DepGlCode') <> 0
BEGIN
  ALTER TABLE AssetGroup DROP COLUMN DepGlCode
  PRINT 'Dropped obsolete column AssetGroup.DepGlCode'
END
GO
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_NAME = 'AssetGroup' AND COLUMN_NAME = 'CapitalizeTax') <> 0
BEGIN
  ALTER TABLE AssetGroup DROP COLUMN CapitalizeTax
  PRINT 'Dropped obsolete column AssetGroup.CapitalizeTax'
END
GO

-------------------------------------------------------------------------

-- Drop obsolete indexes

--  AssetMaster index on StatGlCode must be dropped
IF (SELECT COUNT(*) FROM sysindexes
    WHERE name = 'AssetMasterIdxStatGl') <> 0
BEGIN    
    PRINT 'Dropping old format key AssetMasterIdxStatGl'
    DROP INDEX AssetMaster.AssetMasterIdxStatGl
END
GO

-------------------------------------------------------------------------


PRINT ' '
PRINT ' '
PRINT 'If no error messages were displayed above here then'
PRINT 'your database is now ready for SYSPRO 6.1'

--  End of script SYSPRO61.SQL
