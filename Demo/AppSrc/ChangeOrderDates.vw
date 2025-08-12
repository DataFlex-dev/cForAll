Use Windows.pkg
Use cForAll.Pkg
Use dfClient.pkg

Use cCJGrid.pkg
Use cCJGridColumn.pkg
Use cCJGridColumnRowIndicator.pkg

Open OrderHeader

DEFERRED_VIEW Activate_oChangeOrderDateTestView FOR ;
;
Object oChangeOrderDateTestView is a dbView
    Set Icon to "Default.Ico"
    Set Label to "Change Order Date View"
    Set Location to 5 5
    Set Size to 282 262
    Set Border_Style to Border_Thick

    Object oBeforeTextBox is a Textbox
        Set Label to "Before:"
        Set Location to 46 5
        Set Size to 10 24
        Set FontWeight to 800
    End_Object

    Object oBeforeGrid is a cCJGrid
        Set Size to 183 119
        Set Location to 58 5
        Set peAnchors to anTopBottomLeft
        Set pbAllowEdit to False
        Set psNoFieldsAvailableText to "No Data Found"
        Set pbUseAlternateRowBackgroundColor to True
        Set pbAllowAppendRow to False
        Set pbAllowColumnRemove to False
        Set pbAllowColumnReorder to False
        Set pbAllowColumnResize to False
        Set pbAllowDeleteRow to False
        Set pbAllowInsertRow to False
        Set pbAutoAppend to False
        Set pbAutoSave to False
        Set pbEditOnTyping to False

        Object oForAllOrders Is A cForAll
            Set piMainTable to OrderHeader.File_number
            Set phoMessageDestination To (Parent (Self))
            Set phmOnPreFindRecords To 0
            Set phmOnPostFindRecords To 0
            Set piOrdering To Index.1
        End_Object

        Object oOrderNumberColumn is a cCJGridColumn
            Set piWidth to 50
            Set psCaption to "Order"
        End_Object

        Object oOrderDateColumn is a cCJGridColumn
            Set piWidth to 62
            Set psCaption to "Date"
        End_Object

        // For each found record add two items
        Procedure OnRecordFound Handle hoForAll RowId riRecord
            Handle hoDataSource
            tDataSourceRow[] OrderInfo
            Integer iOrderNumberColumnId iOrderDateColumnId iRow

            Get phoDataSource to hoDataSource
            Get DataSource of hoDataSource to OrderInfo

            Get piColumnId of oOrderNumberColumn to iOrderNumberColumnId
            Get piColumnId of oOrderDateColumn to iOrderDateColumnId

            Move (SizeOfArray (OrderInfo)) to iRow

            Move OrderHeader.Order_number to OrderInfo[iRow].sValue[iOrderNumberColumnId]
            Move OrderHeader.Order_Date to OrderInfo[iRow].sValue[iOrderDateColumnId]

            Set pDataSource of hoDataSource to OrderInfo
        End_Procedure

        // At the start remove all the data
        Procedure OnStartProcess Handle hoForAll
            Handle hoDataSource

            Get phoDataSource to hoDataSource
            Send Reset of hoDataSource
        End_Procedure

        // Tell the grid to update itself
        Procedure OnEndProcess Handle hoForAll
            Handle hoDataSource
            tDataSourceRow[] OrderInfo

            Get phoDataSource to hoDataSource
            Get DataSource of hoDataSource to OrderInfo
            Send InitializeData OrderInfo
        End_Procedure

        Procedure Activating
            Forward Send Activating

            Send DoStartProcess Of oForAllOrders
        End_Procedure
    End_Object

    Object oAfterTextBox is a Textbox
        Set Label to "After:"
        Set Location to 46 131
        Set Size to 10 19
        Set FontWeight to 800
    End_Object

    Object oAfterGrid is a cCJGrid
        Set Size to 183 119
        Set Location to 58 131
        Set pbAllowEdit to False
        Set psNoFieldsAvailableText to "No Data Found"
        Set pbUseAlternateRowBackgroundColor to True
        Set pbAllowAppendRow to False
        Set pbAllowColumnRemove to False
        Set pbAllowColumnReorder to False
        Set pbAllowColumnResize to False
        Set pbAllowDeleteRow to False
        Set pbAllowInsertRow to False
        Set pbAutoAppend to False
        Set pbAutoSave to False
        Set pbEditOnTyping to False
        Set peAnchors to anTopBottomRight

        Object oForAllOrders Is A cForAll
            Set piMainTable to OrderHeader.File_number
            Set phoMessageDestination To (Parent (Self))
            Set phmOnPreFindRecords To 0
            Set phmOnPostFindRecords To 0
            Set piOrdering To Index.1
        End_Object

        Object oOrderNumberColumn is a cCJGridColumn
            Set piWidth to 50
            Set psCaption to "Order"
        End_Object

        Object oOrderDateColumn is a cCJGridColumn
            Set piWidth to 62
            Set psCaption to "Date"
        End_Object

        // For each found record add two items
        Procedure OnRecordFound Handle hoForAll RowID riRecord
            Handle hoDataSource
            tDataSourceRow[] OrderInfo
            Integer iOrderNumberColumnId iOrderDateColumnId iRow

            Get phoDataSource to hoDataSource
            Get DataSource of hoDataSource to OrderInfo

            Get piColumnId of oOrderNumberColumn to iOrderNumberColumnId
            Get piColumnId of oOrderDateColumn to iOrderDateColumnId

            Move (SizeOfArray (OrderInfo)) to iRow

            Move OrderHeader.Order_number to OrderInfo[iRow].sValue[iOrderNumberColumnId]
            Move OrderHeader.Order_Date to OrderInfo[iRow].sValue[iOrderDateColumnId]

            Set pDataSource of hoDataSource to OrderInfo
        End_Procedure

        // At the start remove all the data
        Procedure OnStartProcess Handle hoForAll
            Handle hoDataSource

            Get phoDataSource to hoDataSource
            Send Reset of hoDataSource
        End_Procedure

        // Tell the grid to update itself
        Procedure OnEndProcess Handle hoForAll
            Handle hoDataSource
            tDataSourceRow[] OrderInfo

            Get phoDataSource to hoDataSource
            Get DataSource of hoDataSource to OrderInfo
            Send InitializeData OrderInfo
        End_Procedure
    End_Object

    Object oAdd365DaysButton is a Button
        Set Label to "Add 365 Days"
        Set Size to 14 60
        Set Location to 244 64
        Set peAnchors to anTopBottomLeft

        Procedure OnClick
            Send DoStartProcess Of oChangeAllOrders
            Send DoStartProcess Of (oForAllOrders (oAfterGrid))
        End_Procedure

        Object oChangeAllOrders Is A cForAll
            Set piMainTable to OrderHeader.File_number
            Set piOrdering To Index.3
            Set pbUseAsQueue To True
            Set pbInitConstraintCounters To True
            Send DoAddConstraintInfo File_Field OrderHeader.Order_Date Ge 03/01/2017 // March, 1 2017
            Send DoAddConstraintInfo File_Field OrderHeader.Order_Date Lt 01/01/2018

            // For each found record change the orderdate by adding 365 days
            Procedure OnRecordFound Handle hoForAll RowId riRecord
                Reread
                Move (OrderHeader.Order_Date + 365) to OrderHeader.Order_Date
                SaveRecord OrderHeader
                Unlock
            End_Procedure
        End_Object
    End_Object

    Object oRemove365DaysButton is a Button
        Set Label to "Remove 365 Days"
        Set Size to 14 70
        Set Location to 244 180
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send DoStartProcess Of oChangeAllOrders
            Send DoStartProcess Of (oForAllOrders (oAfterGrid))
        End_Procedure

        Object oChangeAllOrders Is A cForAll
            Set piMainTable to OrderHeader.File_number
            Set piOrdering To Index.3
            Set pbUseAsQueue To True
            Set pbInitConstraintCounters To True
            Send DoAddConstraintInfo File_Field OrderHeader.Order_Date Ge 03/01/2017 // March 1st 2017
            Send DoAddConstraintInfo File_Field OrderHeader.Order_Date Lt 01/01/2018

            // For each found record change the orderdate by adding 365 days
            Procedure OnRecordFound Handle hoForAll RowId riRecord
                Reread
                Move (OrderHeader.Order_date - 365) to OrderHeader.Order_date
                SaveRecord OrderHeader
                Unlock
            End_Procedure
        End_Object
    End_Object

    Object oExplanationTextBox is a TextBox
        Set Auto_Size_State to False
        Set Size to 33 205
        Set Location to 8 9
        Set Label to "In this view the buttons will change the order date values of all orders that are between March 1 2017 and January 1 2018. Browse down in the lists to see the real results"
        Set Justification_Mode to JMode_Left
        Set FontWeight to 600
    End_Object
Cd_End_Object
