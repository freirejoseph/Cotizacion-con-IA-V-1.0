-- SYSPRO version 6.0 upgrade script (09-07-06)
 
-- These scripts will upgrade your RTV tables
-- to the current specifications for Issue 010. This script will alter 
-- Issue 009 column names. If you have stored procedures,scripts,reports, 
-- or triggers reliant on Issue 009 column names, refer to
-- documentation before running this script.

-- This is to be applied to SYSPRO 6.x format databases ONLY!!


-- The following script will upgrade your RTV table RtvMaster
-- with the latest naming conventions for Issue 010.
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstNum', N'Tmp_RtvNumber_19', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstStk', N'Tmp_StockCode_20', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstDesc', N'Tmp_Description_21', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstWh', N'Tmp_Warehouse_22', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstPrcl', N'Tmp_ProductClass_23', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstStkType', N'Tmp_StockType_24', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstStatus', N'Tmp_RtvStatus_25', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstVendor', N'Tmp_VendorCode_26', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstCrDate', N'Tmp_RtvCrDate_27', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstRef', N'Tmp_Reference_28', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstOperator', N'Tmp_Operator_29', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstRmaNum', N'Tmp_RmaNumber_30', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstRmaLin', N'Tmp_RmaLineNumber_31', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstOrgQty', N'Tmp_RtvOrgQty_32', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstOrgCst', N'Tmp_RtvOrgCst_33', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstType', N'Tmp_RtvType_34', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstRetDate', N'Tmp_RtvRetDate_35', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstAprQty', N'Tmp_RtvAprQty_36', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstAprCst', N'Tmp_RtvAprCst_37', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstVarVal', N'Tmp_RtvVarVal_38', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstVdrRef', N'Tmp_RtvVdrRef_39', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstNotation', N'Tmp_RtvNotation_40', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstGrn', N'Tmp_RtvGrn_41', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstPoNum', N'Tmp_PurchaseOrder_42', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstPoLine', N'Tmp_Line_43', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstLastOp', N'Tmp_RtvLastOp_44', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstPoGrnNo', N'Tmp_RtvPoGrnNo_45', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstJnlNo', N'Tmp_Journal_46', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstGrpEnt', N'Tmp_EntryGroup_47', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstCloseDate', N'Tmp_RtvCloseDate_48', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstUom', N'Tmp_OrderUom_49', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstNonsGl', N'Tmp_RtvNonsGl_50', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstSuplChg', N'Tmp_RtvSuplChg_51', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstJnlYear', N'Tmp_JnlYear_52', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstJnlMonth', N'Tmp_JnlMonth_53', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstTax', N'Tmp_TaxCode_54', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstGrnJnl', N'Tmp_RtvGrnJnl_55', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstGrnJnle', N'Tmp_RtvGrnJnle_56', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstRetSlip', N'Tmp_RtvRetSlip_57', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstOrgPO', N'Tmp_RtvOrgPO_58', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstBuy', N'Tmp_Buyer_59', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstBuyName', N'Tmp_Name_60', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstContact', N'Tmp_Contact_61', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstFreight', N'Tmp_RtvFreight_62', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstHandle', N'Tmp_RtvHandle_63', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstFrtGl', N'Tmp_RtvFrtGl_64', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstHndGl', N'Tmp_RtvHndGl_65', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.RtvmstRetReport', N'Tmp_RtvRetReport_66', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvNumber_19', N'RtvNumber', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_StockCode_20', N'StockCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Description_21', N'Description', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Warehouse_22', N'Warehouse', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_ProductClass_23', N'ProductClass', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_StockType_24', N'StockType', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvStatus_25', N'RtvStatus', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_VendorCode_26', N'VendorCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvCrDate_27', N'RtvCrDate', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Reference_28', N'Reference', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Operator_29', N'Operator', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RmaNumber_30', N'RmaNumber', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RmaLineNumber_31', N'RmaLineNumber', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvOrgQty_32', N'RtvOrgQty', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvOrgCst_33', N'RtvOrgCst', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvType_34', N'RtvType', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvRetDate_35', N'RtvRetDate', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvAprQty_36', N'RtvAprQty', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvAprCst_37', N'RtvAprCst', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvVarVal_38', N'RtvVarVal', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvVdrRef_39', N'RtvVdrRef', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvNotation_40', N'RtvNotation', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvGrn_41', N'RtvGrn', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_PurchaseOrder_42', N'PurchaseOrder', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Line_43', N'Line', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvLastOp_44', N'RtvLastOp', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvPoGrnNo_45', N'RtvPoGrnNo', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Journal_46', N'Journal', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_EntryGroup_47', N'EntryGroup', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvCloseDate_48', N'RtvCloseDate', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_OrderUom_49', N'OrderUom', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvNonsGl_50', N'RtvNonsGl', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvSuplChg_51', N'RtvSuplChg', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_JnlYear_52', N'JnlYear', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_JnlMonth_53', N'JnlMonth', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_TaxCode_54', N'TaxCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvGrnJnl_55', N'RtvGrnJnl', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvGrnJnle_56', N'RtvGrnJnle', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvRetSlip_57', N'RtvRetSlip', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvOrgPO_58', N'RtvOrgPO', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Buyer_59', N'Buyer', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Name_60', N'Name', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_Contact_61', N'Contact', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvFreight_62', N'RtvFreight', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvHandle_63', N'RtvHandle', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvFrtGl_64', N'RtvFrtGl', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvHndGl_65', N'RtvHndGl', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvMaster.Tmp_RtvRetReport_66', N'RtvRetReport', 'COLUMN'
GO
COMMIT



-- The following script will upgrade your RTV table RtvJounal
-- with the latest naming conventions for Issue 010.

BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlYear', N'Tmp_YearPost', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlMonth', N'Tmp_MonthPost_1', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlJnl', N'Tmp_Journal_2', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlGl', N'Tmp_GlCode_3', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlRtv', N'Tmp_RtvNumber_4', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlVendor', N'Tmp_VendorCode_5', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlStk', N'Tmp_StockCode_6', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Rtvjnldesc', N'Tmp_Description_7', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlWh', N'Tmp_Warehouse_8', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlOrgQty', N'Tmp_RtvOrgQty_9', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlOrgCst', N'Tmp_RtvOrgCst_10', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlAprQty', N'Tmp_RtvAprQty_11', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlaprCst', N'Tmp_RtvAprCst_12', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlVariance', N'Tmp_VarianceAmt_13', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlDate', N'Tmp_TrnDate_14', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlOperator', N'Tmp_Operator_15', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlPrinted', N'Tmp_RtvPrinted_16', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlgrpEnt', N'Tmp_EntryGroup_17', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.RtvjnlrmaNum', N'Tmp_RmaNumber_18', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_YearPost', N'YearPost', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_MonthPost_1', N'MonthPost', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_Journal_2', N'Journal', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_GlCode_3', N'GlCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RtvNumber_4', N'RtvNumber', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_VendorCode_5', N'VendorCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_StockCode_6', N'StockCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_Description_7', N'Description', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_Warehouse_8', N'Warehouse', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RtvOrgQty_9', N'RtvOrgQty', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RtvOrgCst_10', N'RtvOrgCst', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RtvAprQty_11', N'RtvAprQty', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RtvAprCst_12', N'RtvAprCst', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_VarianceAmt_13', N'VarianceAmt', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_TrnDate_14', N'TrnDate', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_Operator_15', N'Operator', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RtvPrinted_16', N'RtvPrinted', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_EntryGroup_17', N'EntryGroup', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvJournal.Tmp_RmaNumber_18', N'RmaNumber', 'COLUMN'
GO
COMMIT



-- The following script will upgrade your RTV table RtvLastPrice
-- with the latest naming conventions for Issue 010.


BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT

BEGIN TRANSACTION
EXECUTE sp_rename N'dbo.RtvLastPrice.RtvprcStk', N'Tmp_StockCode_67', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.RtvprcWh', N'Tmp_Warehouse_68', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.RtvprcDate', N'Tmp_LastPurchDate_69', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.RtvprcLastCst', N'Tmp_LastCost_70', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.Tmp_StockCode_67', N'StockCode', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.Tmp_Warehouse_68', N'Warehouse', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.Tmp_LastPurchDate_69', N'LastPurchDate', 'COLUMN'
GO
EXECUTE sp_rename N'dbo.RtvLastPrice.Tmp_LastCost_70', N'LastCost', 'COLUMN'
GO
COMMIT




PRINT ' '
PRINT 'Your database is now ready for Issue 010'
