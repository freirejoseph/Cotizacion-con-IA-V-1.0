--  Add new 'RtvJournal' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'RtvJournal') = 0
BEGIN
    CREATE TABLE RtvJournal(
     YearPost                 decimal(4,0)        NOT NULL,
     MonthPost                decimal(2,0)        NOT NULL,
     Journal                  decimal(5,0)        NOT NULL,
     GlCode                   char(15)            NULL,
     RtvNumber                decimal(9,0)        NULL,
     VendorCode               char(7)             NULL,
     StockCode                char(30)            NULL,
     Description              char(30)            NULL,
     Warehouse                char(2)             NULL,
     RtvOrgQty                decimal(10,3)       NULL,
     RtvOrgCst                decimal(15,5)       NULL,
     RtvAprQty                decimal(10,3)       NULL,
     RtvAprCst                decimal(15,5)       NULL,
     VarianceAmt              decimal(14,2)       NULL,
     TrnDate                  datetime            NULL,
     Operator                 char(12)            NULL,
     RtvPrinted               char(1)             NULL,
     EntryGroup               decimal(5,0)        NULL,
     RmaNumber                char(8)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT RtvJournalKey PRIMARY KEY CLUSTERED
         (
          YearPost,
          MonthPost,
          Journal
         )
    )
    PRINT 'New table RtvJournal'
END
GO

--  Add new 'RtvMaster' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'RtvMaster') = 0
BEGIN
    CREATE TABLE RtvMaster(
     RtvNumber                decimal(9,0)        NOT NULL,
     StockCode                char(30)            NULL,
     Description              char(30)            NULL,
     Warehouse                char(2)             NULL,
     ProductClass             char(4)             NULL,
     StockType                char(1)             NULL,
     RtvStatus                char(1)             NULL,
     VendorCode               char(7)             NULL,
     RtvCrDate                datetime            NULL,
     Reference                char(30)            NULL,
     Operator                 char(12)            NULL,
     RmaNumber                char(8)             NULL,
     RmaLineNumber            decimal(4,0)        NULL,
     RtvOrgQty                decimal(10,3)       NULL,
     RtvOrgCst                decimal(15,5)       NULL,
     RtvType                  char(1)             NULL,
     RtvRetDate               datetime            NULL,
     RtvAprQty                decimal(10,3)       NULL,
     RtvAprCst                decimal(15,5)       NULL,
     RtvVarVal                decimal(14,2)       NULL,
     RtvVdrRef                char(15)            NULL,
     RtvNotation              char(20)            NULL,
     RtvGrn                   char(9)             NULL,
     PurchaseOrder            char(6)             NULL,
     Line                     decimal(4,0)        NULL,
     RtvLastOp                char(12)            NULL,
     RtvPoGrnNo               char(9)             NULL,
     Journal                  decimal(5,0)        NULL,
     EntryGroup               decimal(5,0)        NULL,
     RtvCloseDate             datetime            NULL,
     OrderUom                 char(3)             NULL,
     RtvNonsGl                char(15)            NULL,
     RtvSuplChg               decimal(1,0)        NULL,
     JnlYear                  decimal(4,0)        NULL,
     JnlMonth                 decimal(2,0)        NULL,
     TaxCode                  char(1)             NULL,
     RtvGrnJnl                decimal(5,0)        NULL,
     RtvGrnJnle               decimal(5,0)        NULL,
     RtvRetSlip               char(1)             NULL,
     RtvOrgPO                 char(6)             NULL,
     Buyer                    char(3)             NULL,
     Name                     char(30)            NULL,
     Contact                  char(40)            NULL,
     RtvFreight               decimal(10,3)       NULL,
     RtvHandle                decimal(10,3)       NULL,
     RtvFrtGl                 char(15)            NULL,
     RtvHndGl                 char(15)            NULL,
     RtvRetReport             char(1)             NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT RtvMasterKey PRIMARY KEY CLUSTERED
         (
          RtvNumber
         )
    )
    CREATE UNIQUE INDEX RtvMasterAlt1 ON RtvMaster(
     VendorCode,
     RtvNumber
     )
    CREATE UNIQUE INDEX RtvMasterAlt2 ON RtvMaster(
     StockCode,
     RtvNumber
     )
    CREATE UNIQUE INDEX RtvMasterAlt3 ON RtvMaster(
     PurchaseOrder,
     Line,
     RtvNumber
     )
    PRINT 'New table RtvMaster'
END
GO

--  Add new 'RtvLastPrice' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'RtvLastPrice') = 0
BEGIN
    CREATE TABLE RtvLastPrice(
     StockCode                char(30)            NOT NULL,
     Warehouse                char(2)             NOT NULL,
     LastPurchDate            datetime            NULL,
     LastCost                 decimal(15,5)       NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT RtvLastPriceKey PRIMARY KEY CLUSTERED
         (
          StockCode,
          Warehouse
         )
    )
    PRINT 'New table RtvLastPrice'
END
GO
--  Add new 'RtvNotes' Table
IF (SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME = 'RtvNotes') = 0
BEGIN
    CREATE TABLE RtvNotes(
     RtvnotNum                DECIMAL(9,0)        NOT NULL,
     RtvnotComm1              CHAR(30)            NULL,
     RtvnotComm2              CHAR(30)            NULL,
     RtvnotComm3              CHAR(30)            NULL,
     RtvnotComm4              CHAR(30)            NULL,
     RtvnotComm5              CHAR(30)            NULL,
     RtvnotComm6              CHAR(30)            NULL,
     RtvnotComm7              CHAR(30)            NULL,
     RtvnotComm8              CHAR(30)            NULL,
     RtvnotComm9              CHAR(30)            NULL,
     RtvnotComm10             CHAR(30)            NULL,
     RtvnotComm11             CHAR(30)            NULL,
     RtvnotComm12             CHAR(30)            NULL,
     RtvnotComm13             CHAR(30)            NULL,
     RtvnotComm14             CHAR(30)            NULL,
     RtvnotComm15             CHAR(30)            NULL,
     RtvnotComm16             CHAR(30)            NULL,
     RtvnotComm17             CHAR(30)            NULL,
     RtvnotComm18             CHAR(30)            NULL,
     RtvnotComm19             CHAR(30)            NULL,
     RtvnotComm20             CHAR(30)            NULL,
     RtvnotComm21             CHAR(30)            NULL,
     RtvnotComm22             CHAR(30)            NULL,
     RtvnotComm23             CHAR(30)            NULL,
     RtvnotComm24             CHAR(30)            NULL,
     RtvnotComm25             CHAR(30)            NULL,
     RtvnotComm26             CHAR(30)            NULL,
     RtvnotComm27             CHAR(30)            NULL,
     RtvnotComm28             CHAR(30)            NULL,
     RtvnotComm29             CHAR(30)            NULL,
     RtvnotComm30             CHAR(30)            NULL,
     RtvnotComm31             CHAR(30)            NULL,
     RtvnotComm32             CHAR(30)            NULL,
     RtvnotComm33             CHAR(30)            NULL,
     RtvnotComm34             CHAR(30)            NULL,
     RtvnotComm35             CHAR(30)            NULL,
     RtvnotComm36             CHAR(30)            NULL,
     RtvnotComm37             CHAR(30)            NULL,
     RtvnotComm38             CHAR(30)            NULL,
     RtvnotComm39             CHAR(30)            NULL,
     RtvnotComm40             CHAR(30)            NULL,
     RtvnotComm41             CHAR(30)            NULL,
     RtvnotComm42             CHAR(30)            NULL,
     RtvnotComm43             CHAR(30)            NULL,
     RtvnotComm44             CHAR(30)            NULL,
     RtvnotComm45             CHAR(30)            NULL,
     RtvnotComm46             CHAR(30)            NULL,
     RtvnotComm47             CHAR(30)            NULL,
     RtvnotComm48             CHAR(30)            NULL,
     RtvnotComm49             CHAR(30)            NULL,
     RtvnotComm50             CHAR(30)            NULL,
     RtvnotComm51             CHAR(30)            NULL,
     RtvnotComm52             CHAR(30)            NULL,
     RtvnotComm53             CHAR(30)            NULL,
     RtvnotComm54             CHAR(30)            NULL,
     RtvnotComm55             CHAR(30)            NULL,
     RtvnotComm56             CHAR(30)            NULL,
     RtvnotComm57             CHAR(30)            NULL,
     RtvnotComm58             CHAR(30)            NULL,
     RtvnotComm59             CHAR(30)            NULL,
     RtvnotComm60             CHAR(30)            NULL,
     RtvnotComm61             CHAR(30)            NULL,
     RtvnotComm62             CHAR(30)            NULL,
     RtvnotComm63             CHAR(30)            NULL,
     RtvnotComm64             CHAR(30)            NULL,
     RtvnotComm65             CHAR(30)            NULL,
     RtvnotComm66             CHAR(30)            NULL,
     RtvnotComm67             CHAR(30)            NULL,
     RtvnotComm68             CHAR(30)            NULL,
     RtvnotComm69             CHAR(30)            NULL,
     RtvnotComm70             CHAR(30)            NULL,
     RtvnotComm71             CHAR(30)            NULL,
     RtvnotComm72             CHAR(30)            NULL,
     RtvnotComm73             CHAR(30)            NULL,
     RtvnotComm74             CHAR(30)            NULL,
     RtvnotComm75             CHAR(30)            NULL,
     RtvnotComm76             CHAR(30)            NULL,
     RtvnotComm77             CHAR(30)            NULL,
     RtvnotComm78             CHAR(30)            NULL,
     RtvnotComm79             CHAR(30)            NULL,
     RtvnotComm80             CHAR(30)            NULL,
     RtvnotComm81             CHAR(30)            NULL,
     RtvnotComm82             CHAR(30)            NULL,
     RtvnotComm83             CHAR(30)            NULL,
     RtvnotComm84             CHAR(30)            NULL,
     RtvnotDate               DATETIME            NULL,
     TimeStamp                timestamp           NULL,
     CONSTRAINT RtvNotesKey PRIMARY KEY CLUSTERED
         (
          RtvnotNum
         )
    )
    PRINT 'New table RtvNotes'
END
GO

