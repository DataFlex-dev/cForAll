Use Windows.pkg
Use cForAll.Pkg
Use dfClient.pkg
Use cTextEdit.pkg

Open Customer

DEFERRED_VIEW Activate_oConstrainAsView FOR ;
;
Object oConstrainAsView is a dbView
    Set Icon to "Default.Ico"
    Set Label to "Constrain As"
    Set Location to 1 1
    Set Size to 217 413

    Object oConstrainExpressionTextEdit is a cTextEdit
        Set Label to "Constain Customer Records as:"
        Set Size to 84 405
        Set Location to 15 5
        Set Label_Justification_Mode to JMode_Top
        Set Label_Col_Offset to 0
        Set Label_Row_Offset to 1

        // This routine inserts a sample formula to the editor object
        Procedure OnSetFocus
            Forward Send OnSetFocus

            Send Delete_Data
            Send AppendTextLn ("'customer.state = " + '"FL"' + "'")
        End_Procedure
    End_Object

    Object oResultsTextEdit is a cTextEdit
        Set Label to "Results:"
        Set Size to 84 405
        Set Location to 114 5
        Set Read_Only_State to TRUE
        Set Label_Justification_Mode to JMode_Top
        Set Label_Col_Offset to 0
        Set Label_Row_Offset to 1
    End_Object

    Object oRunForAllButton is a Button
        Set Label to "Find Records"
        Set Location to 200 360

        Procedure DoShowCustomer Handle hoForAll RowId riCustomer
            Send AppendTextLn Of oResultsTextEdit (Customer.Name + ' ' + Customer.State)
        End_Procedure

        Procedure OnStartProcess Handle hoForAll
            Set Read_Only_State Of oResultsTextEdit To False
            Send Delete_Data Of oResultsTextEdit
        End_Procedure

        Procedure OnEndProcess Handle hoForAll
            Set Read_Only_State Of oResultsTextEdit To True
        End_Procedure

        Procedure OnClick
            String sExpression
            Handle hoForAll

            Get Value Of oConstrainExpressionTextEdit To sExpression

            Get Create (RefClass (cForAll)) to hoForAll
            If (hoForAll > 0) Begin
                Set piMainTable Of hoForAll To Customer.File_Number
                Send DoAddConstraintAsInfo Of hoForAll Customer.File_Number sExpression
                Set phoMessageDestination Of hoForAll To Self
                Set phmOnRecordFound Of hoForAll To Msg_DoShowCustomer
                Set phmOnPreFindRecords Of hoForAll To 0
                Set phmOnPostFindRecords Of hoForAll To 0
                Send DoStartProcess Of hoForAll
                Send Destroy Of hoForAll
            End
        End_Procedure
    End_Object
Cd_End_Object
