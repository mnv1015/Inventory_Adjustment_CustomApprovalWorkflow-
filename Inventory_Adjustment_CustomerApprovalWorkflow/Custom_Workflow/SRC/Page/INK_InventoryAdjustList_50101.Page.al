page 50101 "Inventory Adjustment List"
{
    Caption = 'Inventory Adjustments';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Inventory Adjustment";
    CardPageId = "Inventory Adjustment Card";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number for the inventory adjustment.';
                }

                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the inventory adjustment.';
                }

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number for the inventory adjustment.';
                }

                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the item.';
                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code for the inventory adjustment.';
                }

                field("Calculated Inventory"; Rec."Calculated Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated inventory quantity from the system.';
                }

                field("Inventory Found"; Rec."Inventory Found")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual inventory quantity found during the count.';
                }

                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code for the inventory adjustment.';
                }

                field("Requested Date"; Rec."Requested Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the inventory adjustment was requested.';
                }

                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the approval status of the inventory adjustment.';
                    StyleExpr = StatusStyleTxt;
                }

                field("Approval Date"; Rec."Approval Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the inventory adjustment was approved.';
                }
            }
        }

        area(FactBoxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = true;
            }
        }
    }

    actions
    {

    }

    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
    end;

    var
        StatusStyleTxt: Text;

    local procedure SetStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Open:
                StatusStyleTxt := 'Favorable';
            Rec.Status::"Pending Approval":
                StatusStyleTxt := 'Attention';
            Rec.Status::Released:
                StatusStyleTxt := 'Standard';
            Rec.Status::Rejected:
                StatusStyleTxt := 'Unfavorable';
        end;
    end;
}





//     area(Processing)
//     {
//         action(New)
//         {
//             ApplicationArea = All;
//             Caption = 'New';
//             Image = New;
//             ToolTip = 'Create a new inventory adjustment.';

//             trigger OnAction()
//             var
//                 InventoryAdjustment: Record "Inventory Adjustment";
//             begin
//                 InventoryAdjustment.Init();
//                 InventoryAdjustment.Insert(true);
//                 Page.RunModal(Page::"Inventory Adjustment Card", InventoryAdjustment);
//             end;
//         }

//         action(Edit)
//         {
//             ApplicationArea = All;
//             Caption = 'Edit';
//             Image = Edit;
//             ToolTip = 'Edit the selected inventory adjustment.';

//             trigger OnAction()
//             begin
//                 Page.RunModal(Page::"Inventory Adjustment Card", Rec);
//             end;
//         }

//         group(Approval)
//         {
//             Caption = 'Approval';
//             Image = Approval;

//             action(SendApprovalRequest)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Send A&pproval Request';
//                 Image = SendApprovalRequest;
//                 ToolTip = 'Request approval of the inventory adjustment.';

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Rec.Status::Open then
//                         Error('Only open documents can be sent for approval.');

//                     Rec.TestField("Item No.");
//                     Rec.TestField("Location Code");
//                     Rec.TestField("Inventory Found");
//                     Rec.TestField("Reason Code");

//                     Rec.SetApprovalStatus(Rec.Status::"Pending Approval");
//                     Message('Approval request has been sent.');
//                 end;
//             }

//             action(CancelApprovalRequest)
//             {
//                 ApplicationArea = All;
//                 Caption = 'Cancel Approval Re&quest';
//                 Image = CancelApprovalRequest;
//                 ToolTip = 'Cancel the approval request.';

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Rec.Status::"Pending Approval" then
//                         Error('Only documents pending approval can be cancelled.');

//                     Rec.SetApprovalStatus(Rec.Status::Open);
//                     Message('Approval request has been cancelled.');
//                 end;
//             }

//             action(Approve)
//             {
//                 ApplicationArea = All;
//                 Caption = '&Approve';
//                 Image = Approve;
//                 ToolTip = 'Approve the inventory adjustment.';

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Rec.Status::"Pending Approval" then
//                         Error('Only documents pending approval can be approved.');

//                     Rec.SetApprovalStatus(Rec.Status::Released);
//                     Message('Document has been approved.');
//                 end;
//             }

//             action(Reject)
//             {
//                 ApplicationArea = All;
//                 Caption = '&Reject';
//                 Image = Reject;
//                 ToolTip = 'Reject the inventory adjustment.';

//                 trigger OnAction()
//                 begin
//                     if Rec.Status <> Rec.Status::"Pending Approval" then
//                         Error('Only documents pending approval can be rejected.');

//                     Rec.SetApprovalStatus(Rec.Status::Rejected);
//                     Message('Document has been rejected.');
//                 end;
//             }
//         }
//     }

//     area(Reporting)
//     {
//         action(Print)
//         {
//             ApplicationArea = All;
//             Caption = '&Print';
//             Image = Print;
//             ToolTip = 'Print the inventory adjustment document.';

//             trigger OnAction()
//             begin
//                 CurrPage.SetSelectionFilter(Rec);
//                 // Report.RunModal(Report::"Inventory Adjustment", true, true, Rec);
//             end;
//         }
//     }

//     area(Navigation)
//     {
//         action(Item)
//         {
//             ApplicationArea = All;
//             Caption = 'Item';
//             Image = Item;
//             RunObject = Page "Item Card";
//             RunPageLink = "No." = field("Item No.");
//             ToolTip = 'View or edit detailed information for the item.';
//         }

//         action(Location)
//         {
//             ApplicationArea = All;
//             Caption = 'Location';
//             // Image = Location;
//             RunObject = Page "Location Card";
//             RunPageLink = Code = field("Location Code");
//             ToolTip = 'View or edit detailed information for the location.';
//         }
//     }