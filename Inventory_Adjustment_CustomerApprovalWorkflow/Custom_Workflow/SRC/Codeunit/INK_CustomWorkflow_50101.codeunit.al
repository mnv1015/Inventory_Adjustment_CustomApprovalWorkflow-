codeunit 50101 "Inventory Adjustment Workflow"
{
    // Check if workflow is enabled for the record
    procedure CheckApprovalsWorkflowEnabled(var InventoryAdjustment: Record "Inventory Adjustment"): Boolean
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(InventoryAdjustment);
        if not WorkflowMgt.CanExecuteWorkflow(RecRef, GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef)) then
            Error(NoWorkflowEnabledErr);
        exit(true);
    end;



    // Generate workflow code and description based on record type
    procedure GetWorkflowCode(WorkflowCode: Code[128]; RecRef: RecordRef): Code[128]
    begin
        exit(DelChr(StrSubstNo(WorkflowCode, RecRef.Name), '=', ' '));
    end;

    procedure GetWorkflowEventDesc(WorkflowEventDesc: Text; RecRef: RecordRef): Text
    begin
        exit(StrSubstNo(WorkflowEventDesc, RecRef.Name));
    end;




    // Integration Events / custom events to handle workflow actions
    [IntegrationEvent(false, false)]
    procedure OnSendInventoryAdjustmentForApproval(var InventoryAdjustment: Record "Inventory Adjustment")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnCancelInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
    begin
    end;



    // Action procedures to embed in your page
    procedure SendApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
    begin
        InventoryAdjustment.TestField("Item No.");
        InventoryAdjustment.TestField("Location Code");
        InventoryAdjustment.TestField("Inventory Found");
        InventoryAdjustment.TestField("Reason Code");
        InventoryAdjustment.TestField("Description");

        if InventoryAdjustment.Status = InventoryAdjustment.Status::"Pending Approval" then
            Error('The document is already pending approval.');

        CheckApprovalsWorkflowEnabled(InventoryAdjustment);

        OnSendInventoryAdjustmentForApproval(InventoryAdjustment);
        Message('Approval request has been sent.');
    end;

    procedure CancelApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
    var
        WorkflowWebhookMgt: Codeunit "Workflow Webhook Management";
    begin
        if InventoryAdjustment.Status <> InventoryAdjustment.Status::"Pending Approval" then
            Error('The document is not pending approval.');

        OnCancelInventoryAdjustmentApprovalRequest(InventoryAdjustment);
        WorkflowWebhookMgt.FindAndCancel(InventoryAdjustment.RecordId);

        Message('Approval request has been cancelled.');
    end;




    // Add events to workflow library
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
        RecRef: RecordRef;
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        RecRef.Open(Database::"Inventory Adjustment");
        WorkflowEventHandling.AddEventToLibrary(GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef),
            Database::"Inventory Adjustment", GetWorkflowEventDesc(WorkflowSendForApprovalEventDescTxt, RecRef), 0, false);
        WorkflowEventHandling.AddEventToLibrary(GetWorkflowCode(RUNWORKFLOWONCANCELFORAPPROVALCODE, RecRef),
            Database::"Inventory Adjustment", GetWorkflowEventDesc(WorkflowCancelForApprovalEventDescTxt, RecRef), 0, false);
    end;





    // Event subscribers to handle workflow custom events
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment Workflow", 'OnSendInventoryAdjustmentForApproval', '', false, false)]
    local procedure RunWorkflowOnSendInventoryAdjustmentForApproval(var InventoryAdjustment: Record "Inventory Adjustment")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(InventoryAdjustment);
        WorkflowMgt.HandleEvent(GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef), RecRef);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment Workflow", 'OnCancelInventoryAdjustmentApprovalRequest', '', false, false)]
    local procedure RunWorkflowOnCancelInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
    var
        RecRef: RecordRef;
    begin
        RecRef.GetTable(InventoryAdjustment);
        WorkflowMgt.HandleEvent(GetWorkflowCode(RUNWORKFLOWONCANCELFORAPPROVALCODE, RecRef), RecRef);
    end;




    // Handle document status changes
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        InventoryAdjustment: Record "Inventory Adjustment";
    begin
        case RecRef.Number of
            Database::"Inventory Adjustment":
                begin
                    RecRef.SetTable(InventoryAdjustment);
                    InventoryAdjustment.SetApprovalStatus(InventoryAdjustment.Status::Open);
                    Handled := true;

                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
    local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
    var
        InventoryAdjustment: Record "Inventory Adjustment";
    begin
        case RecRef.Number of
            Database::"Inventory Adjustment":
                begin
                    RecRef.SetTable(InventoryAdjustment);
                    InventoryAdjustment.SetApprovalStatus(InventoryAdjustment.Status::"Pending Approval");
                    Variant := InventoryAdjustment;
                    IsHandled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
    var
        InventoryAdjustment: Record "Inventory Adjustment";
    begin
        case RecRef.Number of
            Database::"Inventory Adjustment":
                begin
                    RecRef.SetTable(InventoryAdjustment);
                    ApprovalEntryArgument."Document No." := InventoryAdjustment."Document No.";
                    ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
    var
        InventoryAdjustment: Record "Inventory Adjustment";
    begin
        case RecRef.Number of
            Database::"Inventory Adjustment":
                begin
                    RecRef.SetTable(InventoryAdjustment);
                    InventoryAdjustment.SetApprovalStatus(InventoryAdjustment.Status::Released);
                    Handled := true;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnApproveApprovalRequest', '', false, false)]
    local procedure OnApproveApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        InventoryAdjustment: Record "Inventory Adjustment";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
    begin
        case ApprovalEntry."Table ID" of
            Database::"Inventory Adjustment":
                begin
                    if InventoryAdjustment.Get(ApprovalEntry."Document No.") then begin
                        // Check if all approvals are completed
                        if not ApprovalsMgmt.HasOpenApprovalEntries(InventoryAdjustment.RecordId) then begin
                            // All approvals completed - release the document
                            InventoryAdjustment.SetApprovalStatus(InventoryAdjustment.Status::Released);
                        end;
                    end;
                end;
        end;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
    local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
    var
        InventoryAdjustment: Record "Inventory Adjustment";
    begin
        case ApprovalEntry."Table ID" of
            Database::"Inventory Adjustment":
                begin
                    if InventoryAdjustment.Get(ApprovalEntry."Document No.") then
                        InventoryAdjustment.SetApprovalStatus(InventoryAdjustment.Status::Rejected);
                end;
        end;
    end;



    var
        WorkflowMgt: Codeunit "Workflow Management";
        RUNWORKFLOWONSENDFORAPPROVALCODE: Label 'RUNWORKFLOWONSEND%1FORAPPROVAL';
        RUNWORKFLOWONCANCELFORAPPROVALCODE: Label 'RUNWORKFLOWONCANCEL%1FORAPPROVAL';
        NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
        WorkflowSendForApprovalEventDescTxt: Label 'Approval of %1 is requested.';
        WorkflowCancelForApprovalEventDescTxt: Label 'Approval of %1 is canceled.';
}










// ADDED: Event subscriber to handle workflow completion
// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Management", 'OnAfterExecuteWorkflow', '', false, false)]
// local procedure OnAfterExecuteWorkflow(var Workflow: Record Workflow; var RecRef: RecordRef; xRecRef: RecordRef; ExecutedWorkflowStepInstance: Record "Workflow Step Instance")
// var
//     InventoryAdjustment: Record "Inventory Adjustment";
//     ApprovalsMgmt: Codeunit "Approvals Mgmt.";
// begin
//     if RecRef.Number = Database::"Inventory Adjustment" then begin
//         RecRef.SetTable(InventoryAdjustment);

//         // Check if this is the final step and no more open approvals exist
//         if not ApprovalsMgmt.HasOpenApprovalEntries(InventoryAdjustment.RecordId) then begin
//             if InventoryAdjustment.Status = InventoryAdjustment.Status::"Pending Approval" then begin
//                 InventoryAdjustment.SetApprovalStatus(InventoryAdjustment.Status::Released);
//             end;
//         end;
//     end;
// end;

// // Enable approval workflow for Inventory Adjustment
// [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
// local procedure OnPopulateApprovalEntryArgumentInventoryAdjustment(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
// var
//     InventoryAdjustment: Record "Inventory Adjustment";
// begin
//     case RecRef.Number of
//         Database::"Inventory Adjustment":
//             begin
//                 RecRef.SetTable(InventoryAdjustment);
//                 ApprovalEntryArgument."Document No." := InventoryAdjustment."Document No.";
//                 ApprovalEntryArgument."Document Type" := ApprovalEntryArgument."Document Type"::" ";
//             end;
//     end;
// end;



// codeunit 50100 "Inventory adjustment events"
// {
//     // Events for Inventory Adjustment Workflow

//     [IntegrationEvent(false, false)]
//     procedure OnSendInventoryAdjustmentForApproval(var InventoryAdjustment: Record "Inventory Adjustment")
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     procedure OnCancelInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     procedure OnApproveInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     procedure OnRejectInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     procedure OnDelegateInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     begin
//     end;

//     // Event Descriptions for Workflow Event Library
//     procedure AddEventsToLibrary()
//     var
//         WorkflowEventHandling: Codeunit "Workflow Event Handling";
//     begin
//         WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendInventoryAdjustmentForApprovalCode(),
//           DATABASE::"Inventory Adjustment", 'An approval request is sent for an Inventory Adjustment.', 0, false);

//         WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelInventoryAdjustmentApprovalRequestCode(),
//           DATABASE::"Inventory Adjustment", 'An approval request is canceled for an Inventory Adjustment.', 0, false);

//         WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnApproveInventoryAdjustmentApprovalRequestCode(),
//           DATABASE::"Inventory Adjustment", 'An approval request is approved for an Inventory Adjustment.', 0, false);

//         WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnRejectInventoryAdjustmentApprovalRequestCode(),
//           DATABASE::"Inventory Adjustment", 'An approval request is rejected for an Inventory Adjustment.', 0, false);

//         WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnDelegateInventoryAdjustmentApprovalRequestCode(),
//           DATABASE::"Inventory Adjustment", 'An approval request is delegated for an Inventory Adjustment.', 0, false);
//     end;

//     // Event Codes
//     procedure RunWorkflowOnSendInventoryAdjustmentForApprovalCode(): Code[128]
//     begin
//         exit('RUNINVADJUSTMENTSENDFORAPPROVAL');
//     end;

//     procedure RunWorkflowOnCancelInventoryAdjustmentApprovalRequestCode(): Code[128]
//     begin
//         exit('RUNINVADJUSTMENTCANCELAPPROVALREQUEST');
//     end;

//     procedure RunWorkflowOnApproveInventoryAdjustmentApprovalRequestCode(): Code[128]
//     begin
//         exit('RUNINVADJUSTMENTAPPROVEAPPROVALREQUEST');
//     end;

//     procedure RunWorkflowOnRejectInventoryAdjustmentApprovalRequestCode(): Code[128]
//     begin
//         exit('RUNINVADJUSTMENTREJECTAPPROVALREQUEST');
//     end;

//     procedure RunWorkflowOnDelegateInventoryAdjustmentApprovalRequestCode(): Code[128]
//     begin
//         exit('RUNINVADJUSTMENTDELEGATEAPPROVALREQUEST');
//     end;

//     // Subscribe to the events and run workflows
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory adjustment events", 'OnSendInventoryAdjustmentForApproval', '', false, false)]
//     local procedure RunWorkflowOnSendInventoryAdjustmentForApproval(var InventoryAdjustment: Record "Inventory Adjustment")
//     var
//         WorkflowManagement: Codeunit "Workflow Management";
//     begin
//         WorkflowManagement.HandleEvent(RunWorkflowOnSendInventoryAdjustmentForApprovalCode(), InventoryAdjustment);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory adjustment events", 'OnCancelInventoryAdjustmentApprovalRequest', '', false, false)]
//     local procedure RunWorkflowOnCancelInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     var
//         WorkflowManagement: Codeunit "Workflow Management";
//     begin
//         WorkflowManagement.HandleEvent(RunWorkflowOnCancelInventoryAdjustmentApprovalRequestCode(), InventoryAdjustment);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory adjustment events", 'OnApproveInventoryAdjustmentApprovalRequest', '', false, false)]
//     local procedure RunWorkflowOnApproveInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     var
//         WorkflowManagement: Codeunit "Workflow Management";
//     begin
//         WorkflowManagement.HandleEvent(RunWorkflowOnApproveInventoryAdjustmentApprovalRequestCode(), InventoryAdjustment);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory adjustment events", 'OnRejectInventoryAdjustmentApprovalRequest', '', false, false)]
//     local procedure RunWorkflowOnRejectInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     var
//         WorkflowManagement: Codeunit "Workflow Management";
//     begin
//         WorkflowManagement.HandleEvent(RunWorkflowOnRejectInventoryAdjustmentApprovalRequestCode(), InventoryAdjustment);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory adjustment events", 'OnDelegateInventoryAdjustmentApprovalRequest', '', false, false)]
//     local procedure RunWorkflowOnDelegateInventoryAdjustmentApprovalRequest(var InventoryAdjustment: Record "Inventory Adjustment")
//     var
//         WorkflowManagement: Codeunit "Workflow Management";
//     begin
//         WorkflowManagement.HandleEvent(RunWorkflowOnDelegateInventoryAdjustmentApprovalRequestCode(), InventoryAdjustment);
//     end;

//     // Event subscriber to register events when the workflow event handling initializes
//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
//     local procedure AddInventoryAdjustmentWorkflowEventsToLibrary()
//     begin
//         AddEventsToLibrary();
//     end;
// }


// codeunit 50101 "Custom Workflow Mgmt"
// {
//     procedure CheckApprovalsWorkflowEnabled(var RecRef: RecordRef): Boolean
//     begin
//         if not WorkflowMgt.CanExecuteWorkflow(RecRef, GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef)) then
//             Error(NoWorkflowEnabledErr);
//         exit(true);
//     end;

//     procedure GetWorkflowCode(WorkflowCode: code[128]; RecRef: RecordRef): Code[128]
//     begin
//         exit(DelChr(StrSubstNo(WorkflowCode, RecRef.Name), '=', ' '));
//     end;


//     [IntegrationEvent(false, false)]
//     procedure OnSendWorkflowForApproval(var RecRef: RecordRef)
//     begin
//     end;

//     [IntegrationEvent(false, false)]
//     procedure OnCancelWorkflowForApproval(var RecRef: RecordRef)
//     begin
//     end;

//     // Add events to the library

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
//     local procedure OnAddWorkflowEventsToLibrary()
//     var
//         RecRef: RecordRef;
//         WorkflowEventHandling: Codeunit "Workflow Event Handling";
//     begin
//         RecRef.Open(Database::"Inventory Adjustment");
//         WorkflowEventHandling.AddEventToLibrary(GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef), Database::"Inventory Adjustment",
//           GetWorkflowEventDesc(WorkflowSendForApprovalEventDescTxt, RecRef), 0, false);
//         WorkflowEventHandling.AddEventToLibrary(GetWorkflowCode(RUNWORKFLOWONCANCELFORAPPROVALCODE, RecRef), DATABASE::"Inventory Adjustment",
//           GetWorkflowEventDesc(WorkflowCancelForApprovalEventDescTxt, RecRef), 0, false);
//     end;
//     // subscribe

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Workflow Mgmt", 'OnSendWorkflowForApproval', '', false, false)]
//     local procedure RunWorkflowOnSendWorkflowForApproval(var RecRef: RecordRef)
//     begin
//         WorkflowMgt.HandleEvent(GetWorkflowCode(RUNWORKFLOWONSENDFORAPPROVALCODE, RecRef), RecRef);
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Custom Workflow Mgmt", 'OnCancelWorkflowForApproval', '', false, false)]
//     local procedure RunWorkflowOnCancelWorkflowForApproval(var RecRef: RecordRef)
//     begin
//         WorkflowMgt.HandleEvent(GetWorkflowCode(RUNWORKFLOWONCANCELFORAPPROVALCODE, RecRef), RecRef);
//     end;

//     procedure GetWorkflowEventDesc(WorkflowEventDesc: Text; RecRef: RecordRef): Text
//     begin
//         exit(StrSubstNo(WorkflowEventDesc, RecRef.Name));
//     end;

//     // handle the document;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
//     local procedure OnOpenDocument(RecRef: RecordRef; var Handled: Boolean)
//     var
//         CustomWorkflowHdr: Record "Inventory Adjustment";
//     begin
//         case RecRef.Number of
//             Database::"Inventory Adjustment":
//                 begin
//                     RecRef.SetTable(CustomWorkflowHdr);
//                     CustomWorkflowHdr.Validate(Status, CustomWorkflowHdr.Status::Open);
//                     CustomWorkflowHdr.Modify(true);
//                     Handled := true;
//                 end;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', false, false)]
//     local procedure OnSetStatusToPendingApproval(RecRef: RecordRef; var Variant: Variant; var IsHandled: Boolean)
//     var
//         CustomWorkflowHdr: Record "Inventory Adjustment";
//     begin
//         case RecRef.Number of
//             Database::"Inventory Adjustment":
//                 begin
//                     RecRef.SetTable(CustomWorkflowHdr);
//                     CustomWorkflowHdr.Validate(Status, CustomWorkflowHdr.Status::"Pending Approval");
//                     CustomWorkflowHdr.Modify(true);
//                     Variant := CustomWorkflowHdr;
//                     IsHandled := true;
//                 end;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', false, false)]
//     local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry"; WorkflowStepInstance: Record "Workflow Step Instance")
//     var
//         CustomWorkflowHdr: Record "Inventory Adjustment";
//     begin
//         case RecRef.Number of
//             DataBase::"Inventory Adjustment":
//                 begin
//                     RecRef.SetTable(CustomWorkflowHdr);
//                     ApprovalEntryArgument."Document No." := CustomWorkflowHdr."Document No.";
//                 end;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
//     local procedure OnReleaseDocument(RecRef: RecordRef; var Handled: Boolean)
//     var
//         CustomWorkflowHdr: Record "Inventory Adjustment";
//     begin
//         case RecRef.Number of
//             DataBase::"Inventory Adjustment":
//                 begin
//                     RecRef.SetTable(CustomWorkflowHdr);
//                     CustomWorkflowHdr.Validate(Status, CustomWorkflowHdr.Status::Released);
//                     CustomWorkflowHdr.Modify(true);
//                     Handled := true;
//                 end;
//         end;
//     end;

//     [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnRejectApprovalRequest', '', false, false)]
//     local procedure OnRejectApprovalRequest(var ApprovalEntry: Record "Approval Entry")
//     var
//         RecRef: RecordRef;
//         CustomWorkflowHdr: Record "Inventory Adjustment";
//         v: Codeunit "Record Restriction Mgt.";
//     begin
//         case ApprovalEntry."Table ID" of
//             DataBase::"Inventory Adjustment":
//                 begin
//                     if CustomWorkflowHdr.Get(ApprovalEntry."Document No.") then begin
//                         CustomWorkflowHdr.Validate(Status, CustomWorkflowHdr.Status::Rejected);
//                         CustomWorkflowHdr.Modify(true);
//                     end;
//                 end;
//         end;
//     end;

//     var

//         WorkflowMgt: Codeunit "Workflow Management";

//         RUNWORKFLOWONSENDFORAPPROVALCODE: Label 'RUNWORKFLOWONSEND%1FORAPPROVAL';
//         RUNWORKFLOWONCANCELFORAPPROVALCODE: Label 'RUNWORKFLOWONCANCEL%1FORAPPROVAL';
//         NoWorkflowEnabledErr: Label 'No approval workflow for this record type is enabled.';
//         WorkflowSendForApprovalEventDescTxt: Label 'Approval of %1 is requested.';
//         WorkflowCancelForApprovalEventDescTxt: Label 'Approval of %1 is canceled.';



// }
