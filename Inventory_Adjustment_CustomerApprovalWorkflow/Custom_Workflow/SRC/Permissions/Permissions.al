Permissionset 50110 "Customworkflowper"
{
    Assignable = true;
    Caption = 'INK Inventory Adjustment Permissions';

    Permissions =
        tabledata "Inventory Adjustment" = RIMD; // Read, Insert, Modify, Delete
}