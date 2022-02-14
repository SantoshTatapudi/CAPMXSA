namespace capdemo.view;
using { capdemo.db.master, capdemo.db.transaction } from './datamodel';

context CDSView {

    define view ![POWorklist] as
    select from transaction.purchaseorder{
        key PO_ID as ![PurchaseOrderID],
        PARTNER_GUID.BP_ID as ![PartnerID],
        PARTNER_GUID.COMPANY_NAME as ![CompanyName],
        GROSS_AMOUNT as ![POGrossAmount],
        LIFECYCLE_STATUS as ![POStatus],
        Currency.code as ![POCurrencyCode],
        key Items.PO_ITEM_POS as ![ItemPosition],
        Items.PRODUCT_GUID.PRODUCT_ID as ![ProductId],
        Items.PRODUCT_GUID.DESCRIPTION as ![ProductName],
        PARTNER_GUID.ADDRESS_GUID.CITY as ![City],
        PARTNER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
        Items.GROSS_AMOUNT as ![GrossAmount],
        Items.NET_AMOUNT as ![NetAmount],
        Items.TAX_AMOUNT as ![TaxAmount],
        Items.Currency.code as ![CurrencyCode]
    };
    
}
