page 50102 "Inventory Adjustment Card"
{
    Caption = 'Inventory Adjustment Card';
    PageType = Card;
    ApplicationArea = All;
    SourceTable = "Inventory Adjustment";
    RefreshOnActivate = true;
    PromotedActionCategories = 'New, Process, Report, Approvals';
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number for the inventory adjustment.';
                    Editable = DocumentIsEditable;
                    // trigger OnAssistEdit();
                    // begin
                    //     if Rec.AssistEdit(xRec) then
                    //         CurrPage.Update();
                    // end;
                }

                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user who created the inventory adjustment.';
                    // Editable = FieldsEditable;

                }

                field("Requested Date"; Rec."Requested Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the inventory adjustment was requested.';
                    // Editable = FieldsEditable;

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
                    // Editable = FieldsEditable;

                }
            }

            group("Item Information")
            {
                Caption = 'Item Information';

                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item number for the inventory adjustment.';
                    ShowMandatory = true;
                    Editable = DocumentIsEditable;


                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the item.';
                    // Editable =  FieldsEditable;

                }

                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the location code for the inventory adjustment.';
                    ShowMandatory = true;
                    Editable = DocumentIsEditable;


                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
            }

            group("Inventory Details")
            {
                Caption = 'Inventory Details';

                field("Calculated Inventory"; Rec."Calculated Inventory")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the calculated inventory quantity from the system.';
                    // Editable = false;

                }

                field("Inventory Found"; Rec."Inventory Found")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the actual inventory quantity found during the count.';
                    ShowMandatory = true;
                    Editable = DocumentIsEditable;

                }

                field(Difference; Rec."Inventory Found" - Rec."Calculated Inventory")
                {
                    ApplicationArea = All;
                    Caption = 'Difference';
                    ToolTip = 'Specifies the difference between calculated and found inventory.';
                    Editable = false;
                    Style = Attention;
                    // StyleExpr = ("Inventory Found" - Rec."Calculated Inventory") <> 0;
                    Visible = false;
                }
            }

            group("Reason Information")
            {
                Caption = 'Reason Information';

                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code for the inventory adjustment.';
                    ShowMandatory = true;
                    Editable = DocumentIsEditable;


                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }

                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for the inventory adjustment reason.';
                    MultiLine = true;
                    Editable = DocumentIsEditable;

                }
            }
        }

        area(FactBoxes)
        {
            part(ItemPicture; "Item Picture")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Item No.");
            }

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
        area(Processing)
        {
            group("Request Approval")
            {
                Caption = 'Request Approval';
                Image = SendApprovalRequest;

                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Send Approval Request';
                    Image = SendApprovalRequest;
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    ToolTip = 'Request approval of the inventory adjustment document.';
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        InventoryAdjustmentWorkflow: Codeunit "Inventory Adjustment Workflow";
                    begin
                        if Rec.Status <> Rec.Status::Open then
                            Error('You cannot send an approval request for a document that is not open.');

                        InventoryAdjustmentWorkflow.SendApprovalRequest(Rec);
                        CurrPage.Update(false);
                    end;
                }

                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel Approval Re&quest';
                    Image = CancelApprovalRequest;
                    Enabled = CanCancelApprovalForRecord OR CanCancelApprovalForFlow;
                    ToolTip = 'Cancel the approval request for the inventory adjustment document.';
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        InventoryAdjustmentWorkflow: Codeunit "Inventory Adjustment Workflow";
                    begin
                        InventoryAdjustmentWorkflow.CancelApprovalRequest(Rec);
                        CurrPage.Update(false);// 
                    end;
                }
            }
            group(Approval)
            {
                Caption = 'Approval';
                action(Approve)
                {
                    ApplicationArea = All;
                    Caption = 'Approve';
                    Image = Approve;
                    ToolTip = 'Approve the requested changes.';
                    Promoted = true;
                    // PromotedCategory = Category9
                    PromotedCategory = Category4;

                    Visible = OpenApprovalEntriesExistForCurrUser;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reject)
                {
                    ApplicationArea = All;
                    Caption = 'Reject';
                    Image = Reject;
                    ToolTip = 'Reject the approval request.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    Promoted = true;
                    PromotedCategory = Category4;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.RejectRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Delegate)
                {
                    ApplicationArea = All;
                    Caption = 'Delegate';
                    Image = Delegate;
                    ToolTip = 'Delegate the approval to a substitute approver.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    Promoted = true;
                    PromotedCategory = Category4;
                    trigger OnAction()

                    begin
                        ApprovalsMgmt.DelegateRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Comment)
                {
                    ApplicationArea = All;
                    Caption = 'Comments';
                    Image = ViewComments;
                    ToolTip = 'View or add comments for the record.';
                    Visible = OpenApprovalEntriesExistForCurrUser;
                    Promoted = true;
                    PromotedCategory = Category4;


                    trigger OnAction()
                    begin
                        ApprovalsMgmt.GetApprovalComment(Rec);
                    end;
                }
                action(Approvals)
                {
                    ApplicationArea = All;
                    Caption = 'Approvals';
                    Image = Approvals;
                    ToolTip = 'View approval requests.';
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = HasApprovalEntries;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.OpenApprovalEntriesPage(Rec.RecordId);
                    end;

                }
            }
        }
    }


    trigger OnAfterGetRecord()
    begin
        SetStatusStyle();
        SetControlsEditable();
        SetControlAppearance();
        // SetControlsVisibility();
    end;

    trigger onAfterGetCurrRecord()
    begin
        SetControlAppearance();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        SetControlsEditable();
    end;

    trigger OnOpenPage()
    begin
        SetControlAppearance();
    end;

    var
        OpenApprovalEntriesExistCurrUser, HasApprovalEntries : Boolean;
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        DocumentIsEditable: Boolean;
        StatusStyleTxt: Text;
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        CancelApprovalRequestEnabled: Boolean;
        SendApprovalRequestEnabled: Boolean;
        FieldsEditable: Boolean;
        DocumentNoEditable: Boolean;


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

    local procedure SetControlsEditable()
    begin
        DocumentIsEditable := Rec.Status = Rec.Status::Open;
        // CurrPage.Editable(DocumentIsEditable);
    end;

    local procedure SetControlAppearance()
    var
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);

        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);
    end;


}






// local procedure TestMandatoryFields()
// begin
//     Rec.TestField("Item No.");
//     Rec.TestField("Location Code");
//     Rec.TestField("Inventory Found");
//     Rec.TestField("Reason Code");
// end;



// local procedure SetControlsVisibility()
// begin
//     // Document No. is editable only when status is Open and document is new
//     DocumentNoEditable := (Rec.Status = Rec.Status::Open) and (Rec."Document No." = '');

//     // Fields are editable only when status is Open
//     FieldsEditable := (Rec.Status = Rec.Status::Open);
// end;