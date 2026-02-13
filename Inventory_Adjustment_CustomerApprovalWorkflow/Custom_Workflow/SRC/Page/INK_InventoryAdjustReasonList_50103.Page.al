page 50103 "INK Inv. Adjust Reason List"
{
    Caption = 'Inventory Adjustment Reasons';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "INK Inventory Adjust Reason";

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the reason.';
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the reason.';
                }

                field("Adjustment Type"; Rec."Adjustment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this reason is for inventory increase, decrease or both.';
                }
            }
        }
    }
}