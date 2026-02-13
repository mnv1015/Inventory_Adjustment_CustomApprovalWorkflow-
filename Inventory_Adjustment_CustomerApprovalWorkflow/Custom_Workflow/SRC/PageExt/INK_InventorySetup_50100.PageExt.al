pageextension 50100 "INK Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast("Numbering")
        {
            field("INK Inv. Adjustment Nos."; Rec."INK Inv. Adjustment Nos.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the number series code for inventory adjustments.';
            }
        }
    }
}