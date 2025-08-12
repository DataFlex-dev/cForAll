Use Windows.Pkg
Use cForAll.Pkg
Use dfClient.pkg
Use cRichEdit.pkg

Open Customer
Open OrderHeader

DEFERRED_VIEW Activate_oForAllNestedView FOR ;
;
Object oForAllNestedView is a dbView
    Set Border_Style to Border_Thick
    Set Icon to "Default.Ico"
    Set Label to "cForAll Customer Info View"
    Set Location to 2 2
    Set Size to 195 293

    Object oProcessAllRecordsButton is a Button
        Set Label to "Show All Orders for each customer"
        Set Size to 14 284
        Set Location to 5 5
        Set peAnchors to anTopLeft

        Procedure OnClick
            Send Delete_Data Of oResultsBox
            Send DoRemoveConstraintInfo Of oForAllOrders
            Send DoStartProcess Of oForAllCustomers
        End_Procedure
    End_Object

    Object oProcessConstrainedRecordsButton is a Button
        Set Label to "Show All Orders with total > 1000 and date > 05/05/2021 for each customer"
        Set Size to 14 284
        Set Location to 21 5
        Set peAnchors to anTopLeft

        Procedure OnClick
            Send Delete_Data Of oResultsBox
            Send DoRemoveConstraintInfo Of oForAllOrders
            Send DoAddConstraintInfo of oForAllOrders File_Field OrderHeader.Order_Total Ge 1000
            Send DoAddConstraintInfo of oForAllOrders File_Field OrderHeader.Order_Date Gt 05/05/2021
            Send DoStartProcess Of oForAllCustomers
        End_Procedure
    End_Object

    Object oResultsBox is a cRichEdit
        Set Size to 153 284
        Set Location to 37 5
        Set peAnchors to anAll
        Set piMaxChars to 1000000
    End_Object

    Object oForAllCustomers Is A cForAll
        Set piMainTable To Customer.File_Number

        Procedure OnRecordFound Handle hoForAll RowId riRecord
            Set pbBold Of oResultsBox To True
            Send AppendTextLn Of oResultsBox Customer.Name
            Set pbBold Of oResultsBox To False
            Send DoStartProcess Of oForAllOrders
        End_Procedure
    End_Object

    Object oForAllOrders Is A cForAll
        Set piMainTable to OrderHeader.File_Number
        Send DoAddParentForAll oForAllCustomers

        Procedure OnRecordFound Handle hoForAll RowId riRecord
            Send AppendTextLn of oResultsBox ('- ' + String (OrderHeader.Order_number) * String (OrderHeader.Order_date) * String (OrderHeader.Order_total))
        End_Procedure
    End_Object
Cd_End_Object
