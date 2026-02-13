table 50102 "INK Inventory Adjust Reason"
{
    Caption = 'Inventory Adjustment Reason';
    DataClassification = CustomerContent;
    LookupPageId = "INK Inv. Adjust Reason List";
    DrillDownPageId = "INK Inv. Adjust Reason List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }

        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(3; "Adjustment Type"; Option)
        {
            Caption = 'Adjustment Type';
            OptionMembers = Increase,Decrease,Both;
            OptionCaption = 'Increase,Decrease,Both';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}