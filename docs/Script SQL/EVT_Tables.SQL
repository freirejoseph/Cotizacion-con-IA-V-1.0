--  Add new 'EVTTiposIdentif' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTTiposIdentif') = 0
BEGIN
    CREATE TABLE EVTTiposIdentif(
     EIDCodeID                char(1)             NOT NULL,
     EIDDescID                char(25)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTTiposIdentifKey PRIMARY KEY CLUSTERED
         (
          EIDCodeID
         )
    )
    PRINT 'New table EVTTiposIdentif'
END
GO

--  Add new 'EVTLugarEmicion' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTLugarEmicion') = 0
BEGIN
    CREATE TABLE EVTLugarEmicion(
     ELUCityCode              char(3)             NOT NULL,
     ELUCityName              char(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTLugarEmicionKey PRIMARY KEY CLUSTERED
         (
          ELUCityCode
         )
    )
    PRINT 'New table EVTLugarEmicion'
END
GO

--  Add new 'EVTMerWithholdTax' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTMerWithholdTax') = 0
BEGIN
    CREATE TABLE EVTMerWithholdTax(
     EMWTaxCode               CHAR(3)             NOT NULL,
     EMWDescription           CHAR(60)            NULL,
     EMWRateCo                DECIMAL(5,2)        NULL,
     EMWMinAmountCo           DECIMAL(7,0)        NULL,
     EMWGLCodeCo              CHAR(15)            NULL,
     EMWRateInd               DECIMAL(5,2)        NULL,
     EMWMinAmountInd          DECIMAL(7,0)        NULL,
     EMWGLCodeInd             CHAR(15)            NULL,
     EMWShortDesc             CHAR(10)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTMerWithholdTaxKey PRIMARY KEY CLUSTERED
         (
          EMWTaxCode
         )
    )
    PRINT 'New table EVTMerWithholdTax'
END
GO

--  Add new 'EVTNumBranch' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTNumBranch') = 0
BEGIN
    CREATE TABLE EVTNumBranch(
     ENBBranch                char(2)             NOT NULL,
     ENBNextAuto              decimal(5,0)        NULL,
     ENBNextManual            decimal(5,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTNumBranchKey PRIMARY KEY CLUSTERED
         (
          ENBBranch
         )
    )
    PRINT 'New table EVTNumBranch'
END
GO

--  Add new 'EVTNumeracionCtl' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTNumeracionCtl') = 0
BEGIN
    CREATE TABLE EVTNumeracionCtl(
     ENCCtlKey                char(3)             NOT NULL,
     ENCNumbBranchCo          char(1)             NULL,
     ENCNextAuto              decimal(7,0)        NULL,
     ENCNextManual            decimal(7,0)        NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTNumeracionCtlKey PRIMARY KEY CLUSTERED
         (
          ENCCtlKey
         )
    )
    PRINT 'New table EVTNumeracionCtl'
END
GO

--  Add new 'EVTSupplierAddDet' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTSupplierAddDet') = 0
BEGIN
    CREATE TABLE EVTSupplierAddDet(
     ESDSupplier              char(7)             NOT NULL,
     ESDSupplierType          char(1)             NULL,
     ESDMerWithholdTax        char(3)             NULL,
     ESDMerWithholdVAT        char(3)             NULL,
     ESDMiscWithholdVAT       char(3)             NULL,
     ESDServWithholdTax       char(3)             NULL,
     ESDTipoIdentif           char(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTSupplierAddDetKey PRIMARY KEY CLUSTERED
         (
          ESDSupplier
         )
    )
    PRINT 'New table EVTSupplierAddDet'
END
GO

--  Add new 'EVTDocumentType' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTDocumentType') = 0
BEGIN
    CREATE TABLE EVTDocumentType(
     ETDDocType               char(3)             NOT NULL,
     ETDDocDesc               char(30)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTDocumentTypeKey PRIMARY KEY CLUSTERED
         (
          ETDDocType
         )
    )
    PRINT 'New table EVTDocumentType'
END
GO

--  Add new 'EVTTiposRetencion' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTTiposRetencion') = 0
BEGIN
    CREATE TABLE EVTTiposRetencion(
     ETRTipRetCod             char(3)             NOT NULL,
     ETRTipRetDesc            char(75)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTTiposRetencionKey PRIMARY KEY CLUSTERED
         (
          ETRTipRetCod
         )
    )
    PRINT 'New table EVTTiposRetencion'
END
GO

--  Add new 'EVTVATWithholdTax' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTVATWithholdTax') = 0
BEGIN
    CREATE TABLE EVTVATWithholdTax(
     EVWTaxCode               CHAR(3)             NOT NULL,
     EVWDescription           CHAR(60)            NULL,
     EVWRate                  DECIMAL(5,2)        NULL,
     EVWGLCode                CHAR(15)            NULL,
     EVWShortDesc             CHAR(10)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTVATWithholdTaxKey PRIMARY KEY CLUSTERED
         (
          EVWTaxCode
         )
    )
    PRINT 'New table EVTVATWithholdTax'
END
GO

--  Add new 'EVTVATWithholdTrns' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'EVTVATWithholdTrns') = 0
BEGIN
    CREATE TABLE EVTVATWithholdTrns(
     EWTSupplier              CHAR(7)             NOT NULL,
     EWTAPInvoice             CHAR(20)            NOT NULL,
     EWTSeqNumber             DECIMAL(4,0)        NOT NULL,
     EWTComprRetNo            CHAR(7)             NULL,
     EWTPostYear              DECIMAL(4,0)        NULL,
     EWTPostMonth             DECIMAL(2,0)        NULL,
     EWTJournalDate           DATETIME            NULL,
     EWTJournalNumber         DECIMAL(5,0)        NULL,
     EWTAPBranch              CHAR(2)             NULL,
     EWTInvoiceDate           DATETIME            NULL,
     EWTInvoiceAmount         DECIMAL(14,2)       NULL,
     EWTMerchAmount           DECIMAL(14,2)       NULL,
     EWTMiscAmount            DECIMAL(14,2)       NULL,
     EWTTaxAmount             DECIMAL(14,2)       NULL,
     EWTMiscVATAmount         DECIMAL(14,2)       NULL,
     EWTTaxCode               CHAR(1)             NULL,
     EWTWithhMerchCode        CHAR(3)             NULL,
     EWTWithhMerchPerc        DECIMAL(5,2)        NULL,
     EWTWithhTaxAmnt          DECIMAL(14,2)       NULL,
     EWTGLTaxWithh            CHAR(15)            NULL,
     EWTWithhVATCode          CHAR(3)             NULL,
     EWTWithhVATPerc          DECIMAL(5,2)        NULL,
     EWTWithhVATAmnt          DECIMAL(14,2)       NULL,
     EWTGLVATWithh            CHAR(15)            NULL,
     EWTWithhMiscCode         CHAR(3)             NULL,
     EWTWithhMiscPerc         DECIMAL(5,2)        NULL,
     EWTWithhMVAmnt           DECIMAL(14,2)       NULL,
     EWTGLMiscVATWithh        CHAR(15)            NULL,
     EWTReference             CHAR(30)            NULL,
     EWTPlaceIssue            CHAR(3)             NULL,
     EWTDocType               CHAR(3)             NULL,
     EWTWithhServCode         CHAR(3)             NULL,
     EWTWithhServPerc         DECIMAL(5,2)        NULL,
     EWTWithhServAmnt         DECIMAL(14,2)       NULL,
     EWTGLServWithh           CHAR(15)            NULL,
     EWTEntryNoJnl            DECIMAL(3,0)        NULL,
     EWTTipoRet               CHAR(3)             NULL,
     EWTComprPrefix           CHAR(8)             NULL,
     EWTNoRetMercCode         CHAR(3)             NULL,
     EWTNoRetMercPerc         DECIMAL(5,2)        NULL,
     EWTNoRetMercAmnt         DECIMAL(14,2)       NULL,
     EWTNoRetMercGL           CHAR(15)            NULL,
     EWTNoRetServCode         CHAR(3)             NULL,
     EWTNoRetServPerc         DECIMAL(5,2)        NULL,
     EWTNoRetServAmnt         DECIMAL(14,2)       NULL,
     EWTNoRetServGL           CHAR(15)            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT EVTVATWithholdTrnsKey PRIMARY KEY CLUSTERED
         (
          EWTSupplier,
          EWTAPInvoice,
          EWTSeqNumber
         )
    )
    CREATE UNIQUE INDEX EVTVATWithholdTrnsIdxDocNo ON EVTVATWithholdTrns(
     EWTComprRetNo,
     EWTSupplier,
     EWTAPInvoice,
     EWTSeqNumber
     )
    PRINT 'New table EVTVATWithholdTrns'
END
GO

