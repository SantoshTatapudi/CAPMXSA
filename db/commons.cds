namespace capdemo.commons;
using { sap, Currency, temporal, managed } from '@sap/cds/common';

type Guid : String(32);

type Gender : String(1) enum{
    male = 'M';
    female = 'F';
    nonBinary = 'N';
    noDisclosure = 'D';
    selfDescribe = 'S';
}

type AmountT : Decimal(15, 2)@(
    Semantics.amount.currencyCode : 'CURRENCY_CODE',
    sap.unit: 'CURRENCY_CODE'
);

abstract entity Amount{
    Currency: Currency;
    GROSS_AMOUNT : AmountT;
    NET_AMOUNT : AmountT;
    TAX_AMOUNT : AmountT;
}

type PhoneNumber : String(30)@assert.format : '/^(?:(?:\+|0{0,2})91(\s*|[\-])?|[0]?)?([6789]\d{2}([ -]?)\d{3}([ -]?)\d{4})$/';
type Email: String(255)@assert.format : '^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$';