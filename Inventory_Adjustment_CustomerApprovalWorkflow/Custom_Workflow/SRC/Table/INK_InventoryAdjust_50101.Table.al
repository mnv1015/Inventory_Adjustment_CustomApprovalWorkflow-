table 50101 "Inventory Adjustment"
{
    Caption = 'Inventory Adjustment';
    DataClassification = CustomerContent;
    LookupPageId = "Inventory Adjustment List";
    DrillDownPageId = "Inventory Adjustment List";

    fields
    {
        field(1; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }

        field(2; "User Name"; Code[50])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                if "User Name" = '' then
                    "User Name" := CopyStr(UserId(), 1, MaxStrLen("User Name"));
            end;
        }

        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            var
                Item: Record Item;
            begin
                if Item.Get("Item No.") then
                    "Item Description" := Item.Description;

                if "Item No." = '' then
                    "Item Description" := '';

                CalcInventory();
            end;
        }

        field(4; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(5; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;

            trigger OnValidate()
            begin
                CalcInventory();
            end;
        }

        field(6; "Calculated Inventory"; Decimal)
        {
            Caption = 'Calculated Inventory';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 0 : 5;

        }

        field(7; "Inventory Found"; Decimal)
        {
            Caption = 'Inventory Found';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }

        field(8; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "INK Inventory Adjust Reason";

            trigger OnValidate()
            var
                ReasonCode: Record "INK Inventory Adjust Reason";
            begin
                if ReasonCode.Get("Reason Code") then
                    Description := ReasonCode.Description;
            end;
        }

        field(9; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }

        field(10; "Requested Date"; DateTime)
        {
            Caption = 'Requested Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(11; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = Open,"Pending Approval",Released,Rejected;
            OptionCaption = 'Open,Pending Approval,Released,Rejected';
        }

        field(12; "Approval Date"; DateTime)
        {
            Caption = 'Approval Date';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(13; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Document No.", "Item No.", "Item Description", "Location Code")
        {
        }
    }

    trigger OnInsert()
    begin
        if "Document No." = '' then begin
            InvSetup.Get();
            InvSetup.TestField("INK Inv. Adjustment Nos.");
            "Document No." := NoSeries.GetNextNo(InvSetup."INK Inv. Adjustment Nos.", DT2Date("Requested Date"));
            "No. Series" := InvSetup."INK Inv. Adjustment Nos.";
        end;
        InitInsert();
    end;

    local procedure InitInsert()
    begin
        if "User Name" = '' then
            "User Name" := CopyStr(UserId(), 1, MaxStrLen("User Name"));

        if "Requested Date" = 0DT then
            "Requested Date" := CurrentDateTime;

        Status := Status::Open;
    end;

    local procedure CalcInventory()
    var
        Item: Record Item;
    begin
        if ("Item No." <> '') and ("Location Code" <> '') then begin
            Item.Get("Item No.");
            Item.SetFilter("Location Filter", "Location Code");
            Item.CalcFields(Inventory);
            "Calculated Inventory" := Item.Inventory;
        end;
    end;

    procedure SetApprovalStatus(NewStatus: Option)
    begin
        Status := NewStatus;
        if Status = Status::Released then
            "Approval Date" := CurrentDateTime;
        Modify(true);
    end;

    // procedure AssistEdit(OldInvAdj: Record "Inventory Adjustment"): Boolean
    // var
    //     InvAdj: Record "Inventory Adjustment";
    //     NoSeriesRec: Record "No. Series";
    // begin
    //     InvAdj := Rec;
    //     InvSetup.Get();
    //     InvSetup.TestField("INK Inv. Adjustment Nos.");

    //     // Use LookupRelatedNoSeries to allow user to select a number series
    //     if NoSeries.LookupRelatedNoSeries(InvSetup."INK Inv. Adjustment Nos.", OldInvAdj."No. Series", InvAdj."No. Series") then begin
    //         InvAdj."Document No." := NoSeries.GetNextNo(InvAdj."No. Series", Today);
    //         Rec := InvAdj;
    //         exit(true);
    //     end;
    //     exit(false);
    // end;

    var
        InvSetup: Record "Inventory Setup";
        NoSeries: Codeunit "No. Series";
}