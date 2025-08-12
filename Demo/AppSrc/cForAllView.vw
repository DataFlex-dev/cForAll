Use Windows.pkg
Use cForAll.Pkg
Use dfClient.pkg

Use cCJGrid.pkg
Use cCJGridColumn.pkg
Use cTextEdit.pkg

DEFERRED_VIEW Activate_oForAllTestView FOR ;
;
Object oForAllTestView is a dbView
    // Enumerate through all the tables in the filelist to see if one
    // of the logical names matches with the passed name. Compare is case
    // insensitive.
    Function FindTableNumberByName String sTableName Returns Integer
        Integer iTable
        String sLogicalName

        Move (Uppercase (sTableName)) To sTableName

        Get_Attribute DF_FILE_NEXT_USED Of iTable To iTable
        While (iTable > 0)
            Get_Attribute DF_FILE_LOGICAL_NAME Of iTable To sLogicalName
            If (Uppercase (sLogicalName) = sTableName) Begin
                Function_Return iTable
            End

            Get_Attribute DF_FILE_NEXT_USED Of iTable To iTable
        Loop

        Function_Return 0
    End_Function

    // This function does almost do the same as FIELD_MAP but does not generate an error when
    // the field is not found and returns -1 instead.
    Function FindColumnNumberByName Integer iTable String sName Returns Integer
        Integer iColumns iStartColumn iColumn
        Boolean bIsRecnumTable
        String sColumnName

        Move (Uppercase (sName)) To sName

        Get_Attribute DF_FILE_NUMBER_FIELDS Of iTable To iColumns
        Get_Attribute DF_FILE_RECNUM_TABLE Of iTable To bIsRecnumTable
        If (Not (bIsRecnumTable)) Begin
            Move 1 To iStartColumn
        End
        For iColumn From iStartColumn To iColumns
            Get_Attribute DF_FIELD_NAME Of iTable iColumn To sColumnName
            If (Uppercase (sColumnName) = sName) Begin
                Function_Return iColumn
            End
        Loop

        Function_Return -1
    End_Function

    Set Border_Style to Border_Thick
    Set Icon to "Default.Ico"
    Set Label to "cForAll Demonstration"
    Set Location to 2 1
    Set Size to 290 491

    Object oMainTableComboForm is a ComboForm
        // The purpose of this comboform is to select a table from the filelist
        // to enumerate the data from

        Set Label to "Select the main table to read record from:"
        Set Size to 13 150
        Set Location to 5 140
        Set peAnchors to anTopLeft
        Set Form_Border to 0
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to jMode_Right
        Set Entry_State Item 0 to FALSE

        Procedure Combo_Fill_List
            Send DoLoadFileList
        End_Procedure

        Procedure DoLoadFileList
            Integer iTable
            String sLogicalName

            Send Combo_Delete_Data

            Send Combo_Add_Item "<Select Table>"

            Get_Attribute DF_FILE_NEXT_USED Of iTable To iTable
            While (iTable > 0)
                Get_Attribute DF_FILE_LOGICAL_NAME Of iTable To sLogicalName
                Send Combo_Add_Item sLogicalName

                Get_Attribute DF_FILE_NEXT_USED Of iTable To iTable
            Loop
        End_Procedure

        Procedure OnChange
            String sTableName

            Forward Send OnChange

            Get Value To sTableName
            If (Left (sTableName, 7) <> '<Select') Begin
                Send DoInitConstraintGrid Of oConstraintGrid sTableName
                Send DoInitIndexCombo Of oOrderingComboForm sTableName
            End
        End_Procedure
    End_Object

    Object oConstraintGrid is a cCJGrid
        // The purpose of this grid is to allow the user to set constraints on
        // the fly.

        Set Size to 133 477
        Set Location to 20 5
        Set peAnchors to anAll

        Object oTableColumn is a cCJGridColumn
            Set piWidth to 120
            Set psCaption to "Table"
            Set pbComboButton to True
            Set pbComboEntryState to False

            Procedure OnEndEdit String sOldTable String sNewTable
                String sColumnName
                Integer iTable iColumns iStartColumn iColumn
                Boolean bOpened bIsRecnumTable

                If (Left (sNewTable, 7) <> '<Select') Begin
                    Get FindTableNumberByName sNewTable to iTable
                    If (iTable > 0 and iTable < 4096) Begin
                        Send ComboDeleteData of oColumnColumn
                        Send ComboAddItem of oColumnColumn '<Select a Column>' -1
                        Get_Attribute DF_FILE_OPENED of iTable to bOpened
                        If (not (bOpened)) Begin
                            Open iTable
                        End
                        Get_Attribute DF_FILE_NUMBER_FIELDS of iTable to iColumns
                        Get_Attribute DF_FILE_RECNUM_TABLE of iTable to bIsRecnumTable
                        If (not (bIsRecnumTable)) Begin
                            Move 1 to iStartColumn
                        End
                        For iColumn from iStartColumn to iColumns
                            Get_Attribute DF_FIELD_NAME of iTable iColumn to sColumnName
                            Send ComboAddItem of oColumnColumn sColumnName iColumn
                        Loop
                    End
                End
            End_Procedure
        End_Object

        Object oColumnColumn is a cCJGridColumn
            Set piWidth to 120
            Set psCaption to "Column"
            Set pbComboButton to True
            Set pbComboEntryState to False
        End_Object

        Object oModeColumn is a cCJGridColumn
            Set piWidth to 50
            Set psCaption to "Mode"
            Set pbComboButton to True
            Set pbComboEntryState to False
        End_Object

        Object oValueColumn is a cCJGridColumn
            Set piWidth to 180
            Set psCaption to "Value"
        End_Object

        Procedure DoInitConstraintGrid String sTableName
            Integer iTable
            Boolean bOpened

            Get FindTableNumberByName sTableName To iTable
            Open iTable
            Get_Attribute DF_FILE_OPENED Of iTable To bOpened
            If (bOpened) Begin
                Send DoLoadFileList iTable sTableName
                Send DoLoadCompareModes
            End
        End_Procedure

        Procedure Error_Report Integer iErrNum Integer iErrLine String sErrMsg
            // Cancel all errors
        End_Procedure

        Function IsParentTable Integer iRelateFromTable Integer iParentTable Returns Boolean
            Integer iColumns iStartColumn iColumn iColumnRelatedTable
            Boolean bIsRecnumTable bIsParentTable bOpened

            Get_Attribute DF_FILE_NUMBER_FIELDS Of iRelateFromTable To iColumns
            Get_Attribute DF_FILE_RECNUM_TABLE Of iRelateFromTable To bIsRecnumTable
            If (Not (bIsRecnumTable)) Begin
                Move 1 To iStartColumn
            End
            For iColumn From iStartColumn To iColumns
                Get_Attribute DF_FIELD_RELATED_FILE Of iRelateFromTable iColumn To iColumnRelatedTable
                If (iColumnRelatedTable = iParentTable) Begin
                    Function_Return True
                End
                Else Begin
                    If (iColumnRelatedTable > 0) Begin
                        Open iColumnRelatedTable
                        Get_Attribute DF_FILE_OPENED Of iColumnRelatedTable To bOpened
                        If (bOpened) Begin
                            Get IsParentTable iColumnRelatedTable iParentTable To bIsParentTable
                            If (bIsParentTable) Begin
                                Function_Return True
                            End
                        End
                    End
                End
            Loop

            Function_Return False
        End_Function

        Procedure DoLoadFileList Integer iMainTable String sMainTableName
            Integer iTable
            String sLogicalName
            Handle hoPrevErrorHandler
            Boolean bOpenedBefore bOpened bIsParentTable

            Send ComboDeleteData of oTableColumn
            Send ComboAddItem of oTableColumn "<Select Table>" 0
            Send ComboAddItem of oTableColumn sMainTableName iMainTable

            Move Error_Object_Id To hoPrevErrorHandler
            Move Self To Error_Object_Id

            Get_Attribute DF_FILE_NEXT_USED Of iTable To iTable
            While (iTable > 0)
                Get_Attribute DF_FILE_OPENED Of iTable To bOpenedBefore
                If (Not (bOpenedBefore)) Begin
                    Open iTable
                End
                Get_Attribute DF_FILE_OPENED Of iTable To bOpened
                If (bOpened) Begin
                    Get IsParentTable iMainTable iTable To bIsParentTable
                    If (bIsParentTable) Begin
                        Get_Attribute DF_FILE_LOGICAL_NAME Of iTable To sLogicalName
                        Send ComboAddItem of oTableColumn sLogicalName iTable
                    End
                    Else Begin
                        If (Not (bOpenedBefore)) Begin
                            Close iTable
                        End
                    End
                End

                Get_Attribute DF_FILE_NEXT_USED Of iTable To iTable
            Loop

            Move hoPrevErrorHandler To Error_Object_Id
        End_Procedure

        Procedure DoLoadCompareModes
            Send ComboDeleteData of oModeColumn

            Send ComboAddItem of oModeColumn "Eq" (EQ)
            Send ComboAddItem of oModeColumn "Ne" (NE)
            Send ComboAddItem of oModeColumn "Gt" (GT)
            Send ComboAddItem of oModeColumn "Ge" (GE)
            Send ComboAddItem of oModeColumn "Lt" (LT)
            Send ComboAddItem of oModeColumn "Le" (LE)
            Send ComboAddItem of oModeColumn "Contains" 7
            Send ComboAddItem of oModeColumn "Matches" 6
        End_Procedure

        Function CompareMode String sMode Returns Integer
            Integer iPos
            tComboItemData[] ItemData

            Get ComboFindItem of oModeColumn 0 sMode to iPos
            If (iPos <> -1) Begin
                Get ComboData of oModeColumn to ItemData
                Function_Return ItemData[iPos].iData
            End

            Function_Return -1
        End_Function

        Procedure DoLoadConstraintInfo Integer hoForAll
            Integer iElements iElement iTable iColumn iMode
            Integer iTableColumnId iColumnColumnId iModeColumnId iValueColumnId
            String sTableName sColumnName sMode sCompareValue
            Handle hoDataSource
            tDataSourceRow[] GridData

            Get phoDataSource to hoDataSource
            Get DataSource of hoDataSource to GridData

            Move (SizeOfArray (GridData)) to iElements
            If (iElements > 0) Begin
                Get piColumnId of oTableColumn to iTableColumnId
                Get piColumnId of oColumnColumn to iColumnColumnId
                Get piColumnId of oModeColumn to iModeColumnId
                Get piColumnId of oValueColumn to iValueColumnId

                Decrement iElements
                For iElement from 0 to iElements
                    If (Left (GridData[iElement].sValue[iTableColumnId], 7) <> '<Select') Begin
                        Get FindTableNumberByName GridData[iElement].sValue[iTableColumnId] to iTable
                        If (iTable > 0 and iTable < 4096) Begin
                            If (Left (GridData[iElement].sValue[iColumnColumnId], 7) <> '<Select') Begin
                                Get FindColumnNumberByName iTable GridData[iElement].sValue[iColumnColumnId] to iColumn
                                If (iColumn > -1) Begin
                                    Get CompareMode GridData[iElement].sValue[iModeColumnId] to iMode
                                    If (iMode > -1) Begin
                                        Send DoAddConstraintInfo of hoForAll iTable iColumn iMode GridData[iElement].sValue[iValueColumnId]
                                    End
                                End
                            End
                        End
                    End
                Loop
            End
        End_Procedure
    End_Object

    Object oSearchDirection is a CheckBox
        Set Label to "Search backwards"
        Set Size to 13 76
        Set Location to 155 5
        Set peAnchors to anBottomLeft
    End_Object

    Object oOrderingComboForm is a ComboForm
        Set Label to "Ordering:"
        Set Size to 12 310
        Set Location to 156 120
        Set peAnchors to anBottomLeftRight
        Set Form_Border to 0
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to jMode_Right
        Set Entry_State Item 0 to FALSE
        Set Combo_Sort_State to FALSE

        Procedure DoInitIndexCombo String sTableName
            Integer iTable iLastIndex iIndex iSegments iSegment iSegmentColumn iSegmentDirection
            Boolean bOpened
            String sIndexInfo sColumnName

            Send Combo_Delete_Data
            Send Combo_Add_Item "-1: Constraint based"

            Get FindTableNumberByName sTableName To iTable

            Get_Attribute DF_FILE_OPENED Of iTable To bOpened
            If (Not (bOpened)) Begin
                Open iTable
            End
            Get_Attribute DF_FILE_OPENED Of iTable To bOpened
            If (bOpened) Begin
                Get_Attribute DF_FILE_LAST_INDEX_NUMBER Of iTable To iLastIndex
                For iIndex From 1 To iLastIndex
                    Get_Attribute DF_INDEX_NUMBER_SEGMENTS Of iTable iIndex To iSegments
                    If (iSegments > 0) Begin
                        Move (String (iIndex) + ': ') To sIndexInfo
                        For iSegment From 1 To iSegments
                            Get_Attribute DF_INDEX_SEGMENT_FIELD Of iTable iIndex iSegment To iSegmentColumn
                            Get_Attribute DF_INDEX_SEGMENT_DIRECTION Of iTable iIndex iSegment To iSegmentDirection
                            Get_Attribute DF_FIELD_NAME Of iTable iSegmentColumn To sColumnName
                            If (iSegmentDirection = DF_DESCENDING) Begin
                                Move ('-' + sColumnName) To sColumnName
                            End
                            If (iSegment > 1) Begin
                                Move (sIndexInfo + ', ') To sIndexInfo
                            End
                            Move (sIndexInfo + sColumnName) To sIndexInfo
                        Loop
                        Send Combo_Add_Item sIndexInfo
                    End
                Loop
            End

            Set Value To "-1: Constraint based"
        End_Procedure
    End_Object

    Object oStartButton is a Button
        Set Label to "&Start"
        Set Location to 156 432
        Set peAnchors to anBottomRight

        Procedure ShowData Handle hoForAll RowId riRecord
            Integer iTable iColumns iStartColumn iColumn
            Boolean bIsRecnumTable
            String sTableName sColumnName sFieldValue

            Get piMainTable Of hoForAll To iTable
            Get_Attribute DF_FILE_NUMBER_FIELDS Of iTable To iColumns
            Get_Attribute DF_FILE_RECNUM_TABLE Of iTable To bIsRecnumTable
            If (Not (bIsRecnumTable)) Begin
                Move 1 To iStartColumn
            End

            Send Delete_Data of oResults

            Send AppendTextLn of oResults ("Data from record:" * SerializeRowId (riRecord))

            For iColumn From iStartColumn To iColumns
                Get_Attribute DF_FIELD_NAME Of iTable iColumn To sColumnName
                Get_Field_Value iTable iColumn To sFieldValue
                Send AppendTextLn of oResults (sColumnName + ': ' + sFieldValue)
            Loop

            Send AppendTextLn of oResults (Repeat ('=', 50))
        End_Procedure

        Procedure OnStartProcess Handle hoForAll
            // We redirect the messages for the ForAll object. This means
            // that we can either set the message id to 0 of we need
            // to add this empty handler here.
        End_Procedure

        Procedure OnEndProcess Handle hoForAll
            // We redirect the messages for the ForAll object. This means
            // that we can either set the message id to 0 of we need
            // to add this empty handler here.
        End_Procedure

        Procedure OnPreFindRecords Handle hoForAll
            Integer iTable
            String sTableName

            Get piMainTable Of hoForAll To iTable
            Get_Attribute DF_FILE_LOGICAL_NAME Of iTable To sTableName

            Send AppendTextLn of oResults ("Data from table: " * String (iTable) + ' (' + sTableName + ')')
        End_Procedure

        Procedure OnPostFindRecords Handle hoForAll
            Send AppendTextLn of oResults (Repeat ('*', 20) * "Statistics" * Repeat ('*', 20))
            Send AppendTextLn of oResults ("Number of records found: " + String (Constrain_Found_Count))
            Send AppendTextLn of oResults ("Number of records tested: " + String (Constrain_Tests_Count))
            Send AppendTextLn of oResults (Repeat ('*', 20) * "Finished" * Repeat ('*', 20))
        End_Procedure

        // fires when the button is clicked
        Procedure OnClick
            String sTableName sOrdering
            Integer iTable iOrdering
            Handle hoForAll
            Boolean bOpened bSearchBackwards

            Get Value Of oMainTableComboForm To sTableName
            Get FindTableNumberByName sTableName To iTable
            If (iTable > 0 And iTable < 4096) Begin
                Get_Attribute DF_FILE_OPENED Of iTable To bOpened
                If (Not (bOpened)) Begin
                    Open iTable
                End

                Get Create U_cForAll To hoForAll
                If (hoForAll > 0) Begin
                    Set piMainTable Of hoForAll To iTable
                    Set phmOnRecordFound of hoForAll to (Refproc (ShowData))
                    Set phoMessageDestination Of hoForAll To Self
                    Get Value Of oOrderingComboForm To sOrdering
                    Move (Left (sOrdering, Pos (':', sOrdering) - 1)) To iOrdering
                    Set piOrdering Of hoForAll To iOrdering
                    Get Checked_State Of oSearchDirection To bSearchBackwards
                    If (bSearchBackwards) Begin
                        Set pbSearchDirection Of hoForAll To DOWNWARD_DIRECTION
                    End
                    Set pbInitConstraintCounters Of hoForAll To True
                    Send DoLoadConstraintInfo Of oConstraintGrid hoForAll
                    Send DoStartProcess Of hoForAll
                    Send Destroy Of hoForAll
                End
            End
        End_Procedure
    End_Object

    Object oResults is a cTextEdit
        Set Size to 113 476
        Set Location to 172 6
        Set peAnchors to anBottomLeftRight
    End_Object

    On_key Key_Alt+Key_S Send KeyAction Of oStartButton
Cd_End_Object
