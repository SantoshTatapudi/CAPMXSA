namespace capdemo.db;
using { cuid, managed, temporal, Currency } from '@sap/cds/common';
using { capdemo.commons } from './commons';

type Guid : String(32);


context master {
    entity businesspartner {
        key NODE_KEY : Guid;
        BP_ROLE	:String(2);
        EMAIL_ADDRESS :String(105);
        PHONE_NUMBER: String(32);
        FAX_NUMBER: String(32);
        WEB_ADDRESS:String(44);	
        ADDRESS_GUID: Association to address;	
        BP_ID: String(32);	
        COMPANY_NAME: String(250);
    }

    entity address {
        key NODE_KEY: Guid;
        CITY: String(44);
        POSTAL_CODE: String(8);
        STREET: String(44);
        BUILDING:String(128)  ;
        COUNTRY: String(44);
        ADDRESS_TYPE: String(44);
        VAL_START_DATE: Date;
        VAL_END_DATE:Date;
        LATITUDE: Decimal;
        LONGITUDE: Decimal;
        businesspartner: Association to one businesspartner on businesspartner.ADDRESS_GUID = $self;
    }

    entity product {
        key NODE_KEY: Guid;
        PRODUCT_ID: String(28);
        TYPE_CODE: String(2);
        CATEGORY: String(32);
        DESCRIPTION: localized String(255);
        SUPPLIER_GUID: Association to master.businesspartner;
        TAX_TARIF_CODE: Integer;
        MEASURE_UNIT: String(2);
        WEIGHT_MEASURE	: Decimal;
        WEIGHT_UNIT: String(2);
        CURRENCY_CODE:String(4);
        PRICE: Decimal(15,2);
        WIDTH:Decimal;	
        DEPTH:Decimal;	
        HEIGHT:	Decimal;
        DIM_UNIT:String(2);
    }

    entity employees: cuid {
        nameFirst: String(40);
        nameMiddle: String(40);	
        nameLast: String(40);	
        nameInitials: String(40);	
        sex	: commons.Gender;
        language: String(1);
        phoneNumber: commons.PhoneNumber;
        email: commons.Email;
        loginName: String(12);
        Currency: Currency;
        salaryAmount: commons.AmountT;	
        accountNumber: String(16);	
        bankId: String(20);
        bankName: String(64);
    }
}

context transaction {
    
     entity purchaseorder: commons.Amount, cuid {
            PO_ID: Integer;     	
            PARTNER_GUID: association to master.businesspartner;                      
            LIFECYCLE_STATUS: String(1);	
            OVERALL_STATUS: String(1);
            Items: Composition of many poitems on Items.PARENT_KEY = $self;
            NOTE: String(256);
            CREATEDBY: UUID;
            MODIFIEDBY : UUID;
            CREATEDAT: Date;
            MODIFIEDAT: Date;
     }

     entity poitems: commons.Amount, cuid {
            PARENT_KEY: association to purchaseorder;
            PO_ITEM_POS: Integer;	
            PRODUCT_GUID: association to master.product;           	
              
     }

}

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
         define view ProductValueHelp as 
        select from master.product{
            @EndUserText.label:[
                {
                    language: 'EN',
                    text: 'Product ID'
                },{
                    language: 'DE',
                    text: 'Prodekt ID'
                }
            ]
            PRODUCT_ID as ![ProductId],
            @EndUserText.label:[
                {
                    language: 'EN',
                    text: 'Product Description'
                },{
                    language: 'DE',
                    text: 'Prodekt Description'
                }
            ]
            DESCRIPTION as ![Description]
        };
        define view![ItemView] as 
    select from transaction.poitems{
        PARENT_KEY.PARTNER_GUID.NODE_KEY as![Partner],
        PRODUCT_GUID.NODE_KEY as![ProductId],
        Currency.code as![CurrencyCode],
        GROSS_AMOUNT as![GrossAmount],
        NET_AMOUNT as![NetAmount],
        TAX_AMOUNT as![TaxAmount],
        PARENT_KEY.OVERALL_STATUS as![POStatus]
    };
    define view ProductViewSub as 
    select from master.product as prod{
        PRODUCT_ID as![ProductId],
        texts.DESCRIPTION as![Description],
        (
            select from transaction.poitems as a{
                round(SUM(a.GROSS_AMOUNT),2) as SUM
            }
            where a.PRODUCT_GUID.NODE_KEY = prod.NODE_KEY
        ) as PO_SUM: Decimal(10, 2)
    };
    define view ProductView as select from master.product
    mixin{
        PO_ORDERS: Association[*] to ItemView on
                        PO_ORDERS.ProductId = $projection.ProductId
    }
    into{
        NODE_KEY as![ProductId],
        DESCRIPTION,
        CATEGORY as![Category],
        PRICE as![Price],
        TYPE_CODE as![TypeCode],
        SUPPLIER_GUID.BP_ID as![BPId],
        SUPPLIER_GUID.COMPANY_NAME as![CompanyName],
        SUPPLIER_GUID.ADDRESS_GUID.CITY as![City],
        SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as![Country],
        //Exposed Association, which means when someone read the view
        //the data for orders wont be read by default
        //until unless someone consume the association
        PO_ORDERS
    };
    define view CProductValuesView as 
        select from ProductView{
            ProductId,
            Country,
            PO_ORDERS.CurrencyCode as![CurrencyCode],
            round(sum(PO_ORDERS.GrossAmount),2) as ![POGrossAmount]: Decimal(10, 2)
        }
        group by ProductId,Country,PO_ORDERS.CurrencyCode
}
