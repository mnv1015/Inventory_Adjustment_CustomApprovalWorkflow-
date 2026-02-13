tableextension 50100 "INK Inventory Setup" extends "Inventory Setup"
{
    fields
    {
        field(50100; "INK Inv. Adjustment Nos."; Code[20])
        {
            Caption = 'Inventory Adjustment Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }
}