namespace capdemo.db;

entity orders
{
    key ID : Integer64;
    customername : String(124);
    contactperson : String(64);
    grossamount : Decimal(10,2);
    currency : String(4);
}
