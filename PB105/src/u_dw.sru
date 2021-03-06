$PBExportHeader$u_dw.sru
forward
global type u_dw from datawindow
end type
end forward

global type u_dw from datawindow
integer width = 686
integer height = 400
string title = "none"
boolean livescroll = true
borderstyle borderstyle = stylelowered!
event type integer ue_cut ( )
event type integer ue_copy ( )
event type integer ue_paste ( )
event type integer ue_selectall ( )
event type long ue_insertrow ( )
event type long ue_addrow ( )
event type integer ue_deleterow ( )
event ue_prepopupmenuproperty ( ref m_dw_popup am_dw_popup )
event ue_prepopupmenu ( ref m_dw_popup am_dw_popup )
end type
global u_dw u_dw

type variables

Protected:

// When TRUE, the popup menu is enabled.
Boolean	ib_popup_menu_enabled = True


end variables
forward prototypes
public function integer of_getparentwindow (ref window aw_parent)
public function integer of_setpopupmenu (boolean ab_switch)
end prototypes

event type integer ue_cut();
// ue_Cut() event.

Return This.Cut()
end event

event type integer ue_copy();
// ue_Copy() event.

Return This.Copy()
end event

event type integer ue_paste();
// ue_Paste() event.

Return This.Paste()
end event

event type integer ue_selectall();
// ue_SelectAll() event.

Return This.SelectText(1,32767)
end event

event type long ue_insertrow();
// ue_InsertRow() event.

long	ll_current_row, ll_new_row

// Get current row
ll_current_row = This.GetRow()
If ll_current_row < 0 Then ll_current_row = 0

ll_new_row = This.InsertRow(ll_current_row)
This.ScrollToRow( ll_new_row)

Return ll_new_row
end event

event type long ue_addrow();
// ue_AddRow() event.
Long ll_row

ll_row = This.InsertRow(0)
This.ScrollToRow( ll_row)

Return ll_row

end event

event type integer ue_deleterow();
// ue_DeleteRow() event.

Integer li_rc

li_rc = This.DeleteRow(0)
If li_rc > 0 Then
	li_rc = 0
Else
	li_rc = -1
End If

Return li_rc
end event

event ue_prepopupmenuproperty(ref m_dw_popup am_dw_popup);
// ue_PrePopupMenuProperty event.

// Allows the popup menu items to be dynamically enabled/disabled, hidden/shown
// depending on current conditions, user privileges, etc. prior to its display.

Return
end event

public function integer of_getparentwindow (ref window aw_parent);
//	Public Function:	of_GetParentWindow(Ref Window aw_Parent)

// Dynamically obtains a reference to this control's parent window.

// Returns:  Integer  -1 = An error occurred, 1 = Success

PowerObject	lpo_parent

lpo_parent = This.GetParent()

// Traverse up the parent object hierarchy until a window is found.
Do While IsValid(lpo_parent)
	If lpo_parent.TypeOf() <> Window! Then
		lpo_parent = lpo_parent.GetParent()
	Else
		Exit
	End If
Loop

// Any luck?
If IsNull(lpo_parent) Or Not IsValid(lpo_parent) Then
	SetNull(aw_parent)
	Return -1
End If

aw_parent = lpo_parent
Return 1
end function

public function integer of_setpopupmenu (boolean ab_switch);
// Public Function of_SetPopupMenu(Boolean ab_Switch) returns Integer

// Enables/disables the DataWindow control's popup menu.

If IsNull(ab_switch) Then Return 0

This.ib_popup_menu_enabled = ab_switch
Return 1

end function

on u_dw.create
end on

on u_dw.destroy
end on

event rbuttondown;
// RButtonDown event.

// Creates, configures, displays and destroys the popup menu.

Boolean lb_have_frame_window, lb_desired, lb_read_only, lb_edit_style_attribute
Integer li_tab_sequence
Long    ll_get_row
String  ls_edit_style, ls_value, ls_protect, ls_column_name, ls_current_column_name, ls_dwo_type, ls_expression
window  lw_parent, lw_frame, lw_sheet, lw_child_parent
m_dw_popup lm_dw_popup

// Can the popup menu be used?
If Not This.ib_popup_menu_enabled Or IsNull(dwo) Then Return 1

// There is no popup menu support for OLE, Graph and TableBlob DWObjects.
ls_dwo_type = dwo.Type
If ls_dwo_type = "ole" Or ls_dwo_type = "graph" Or ls_dwo_type = "tableblob" Then Return 1

// Popup menu cannot be used when the DW is in print preview mode.
If This.Object.DataWindow.Print.Preview = "yes" Then Return 1

// The PopMenu PowerScript function requires the X,Y offset from the upper-left corner
// of the parent window, so we need a reference to this DW's parent window. If this app
// is running in an MDI frame window, we'll need a reference to the frame window.
This.of_GetParentWindow(lw_parent)

If IsValid(lw_parent) Then
	// See if an MDI frame window exists...
	lw_frame = lw_parent
	
	// Check the DW control's parent window to see if it is an MDI frame.
	// If it isn't, try to obtain a  reference to the window's parent window.
	Do While IsValid(lw_frame)
		If lw_frame.WindowType = MDI! Or lw_frame.WindowType = MDIHelp! Then
			// We have a reference to the MDI frame window.
			lb_have_frame_window = True
			Exit
		Else
			lw_frame = lw_frame.ParentWindow()
		End If
	Loop
	
	// Any luck obtaining a frame window reference?
	If lb_have_frame_window Then
		// Yes - Use it as the reference point for the popup menu for Sheet windows or Child windows.
		If lw_parent.WindowType = Child! Then
			lw_parent = lw_frame
		Else
			lw_sheet = lw_frame.GetFirstSheet()
			If IsValid(lw_sheet) Then
				Do
					// Use frame reference for popup menu if the parentwindow is a sheet window.
					If lw_sheet = lw_parent Then
						lw_parent = lw_frame
						Exit
					End If
					lw_sheet = lw_frame.GetNextSheet(lw_sheet)
				Loop Until IsNull(lw_sheet) Or Not IsValid(lw_sheet)
			End If
		End If
	Else
		// This is an SDI application.
		// Use the control's parent window as the reference point for the popup menu, except if it is a child window.
		If lw_parent.WindowType = Child! Then
			lw_child_parent = lw_parent.ParentWindow()
			If IsValid(lw_child_parent) Then
				lw_parent = lw_child_parent
			End If
		End If
	End If
Else
	// The popup menu cannot be used.
	Return 1
End If

// Create the popup menu object and register this DataWindow control as the popup menu's parent object.
lm_dw_popup = Create m_dw_popup
lm_dw_popup.of_SetParent(This)

// Let's configure row-related menu items (Insert/Add/Delete)...
ll_get_row = This.GetRow()

// Is the entire DataWindow in read/only mode?
ls_value = Lower(Trim(This.Describe("DataWindow.ReadOnly")))
If ls_value = "yes" Then
	lb_read_only = True
Else
	lb_read_only = False
End If

// Can the popup menu's Insert Row, Add Row & Delete Row menu items be enabled?
Choose Case ls_dwo_type
	Case "datawindow", "column", "compute", "text", "report", &
		"bitmap", "line", "ellipse", "rectangle", "roundrectangle"
	
	// Row operations are based on read/only status.
	lm_dw_popup.m_popup.m_insert.Enabled = Not lb_read_only
	lm_dw_popup.m_popup.m_add.Enabled    = Not lb_read_only
	lm_dw_popup.m_popup.m_delete.Enabled = Not lb_read_only
	
	// Menu item enablement for current row
	If Not lb_read_only Then
		lb_desired = False
		If ll_get_row > 0 Then lb_desired = True
		lm_dw_popup.m_popup.m_delete.Enabled = lb_desired
		lm_dw_popup.m_popup.m_insert.Enabled = lb_desired
	End If
	
Case Else
	// Unable to enable row-related menu items.
	lm_dw_popup.m_popup.m_insert.Enabled = False
	lm_dw_popup.m_popup.m_delete.Enabled = False
	lm_dw_popup.m_popup.m_add.Enabled    = False
End Choose

// If there is a current column, see if it is editable or protected.
ls_current_column_name = This.GetColumnName()

If ls_dwo_type = "column" Then
	// This is a column DWObject... look at the column's edit style and Protect property.
	ls_edit_style  = dwo.Edit.Style
	ls_column_name = dwo.Name
	ls_protect     = dwo.Protect
	
	If Not IsNumber(ls_protect) Then
		// The Protect property value is NOT a number, so it must be an expression.
		// Evaluate the expression based on the row number passed in to this event.
		ls_expression = Right(ls_protect,Len(ls_protect) - Pos(ls_protect,"~t"))
		ls_expression = "Evaluate(~"" + ls_expression + "," + String(row) + ")"
		ls_protect = This.Describe(ls_expression)
	End If
	
	// Obtain the column's tab (order) sequence.
	ls_value = dwo.TabSequence
	If IsNumber(ls_value) Then
		li_tab_sequence = Integer(ls_value)
	End If
End If

// Enable data transfer operations only for editable column edit styles.
lm_dw_popup.m_popup.m_copy.Enabled      = False
lm_dw_popup.m_popup.m_cut.Enabled       = False
lm_dw_popup.m_popup.m_paste.Enabled     = False
lm_dw_popup.m_popup.m_selectall.Enabled = False

// Check if the column is editable... the specifics depend on the edit style.
If ls_dwo_type = "column" And Not lb_read_only Then
	Choose Case ls_edit_style
		Case "edit"
			ls_value = dwo.Edit.DisplayOnly
		Case "editmask"
			ls_value = dwo.EditMask.Readonly
		Case "ddlb"
			ls_value = dwo.DDLB.AllowEdit
		Case "dddw"
			ls_value = dwo.DDDW.AllowEdit
		Case Else
			ls_value = ""
	End Choose
	
	If IsNull(ls_value) Or ls_value = "" Then ls_value = "no"
	
	ls_value = Lower(Trim(ls_value))
	If ls_value = "yes" Then
		lb_edit_style_attribute = True
	Else
		lb_edit_style_attribute = False
	End If
End If

// Is this an editable column?
If ls_dwo_type = "column" And Not lb_read_only Then
	If dwo.BitmapName = "no" And ls_edit_style <> "checkbox" And ls_edit_style <> "radiobuttons" Then
		
		If Len(This.SelectedText()) > 0 And ll_get_row = row And ls_current_column_name = ls_column_name Then
			// Is a Copy operation allowed?
			lm_dw_popup.m_popup.m_copy.Enabled = True
			
			// Is a Cut operation allowed?
			If li_tab_sequence > 0 And ls_protect = "0" Then
				lb_desired = False
				Choose Case ls_edit_style
					Case "edit", "editmask"
						lb_desired = Not lb_edit_style_attribute
					Case "ddlb", "dddw"
						lb_desired = lb_edit_style_attribute
				End Choose
				lm_dw_popup.m_popup.m_cut.Enabled = lb_desired
			End If
		End If
		
		If li_tab_sequence > 0 And ls_protect = "0" Then
			// Is a Paste operation allowed?
			If Len(Clipboard()) > 0 Then
				lb_desired = False
				Choose Case ls_edit_style
					Case "edit", "editmask"
						lb_desired = Not lb_edit_style_attribute
					Case "ddlb", "dddw"
						lb_desired = lb_edit_style_attribute
				End Choose
				lm_dw_popup.m_popup.m_paste.Enabled = lb_desired
			End If
			
			// Is a Select All operation allowed?
			If Len(This.GetText()) > 0 And ll_get_row = row And ls_current_column_name = ls_column_name Then
				Choose Case ls_edit_style
					Case "ddlb", "dddw"
						lb_desired = lb_edit_style_attribute
					Case Else
						lb_desired = True
				End Choose
				lm_dw_popup.m_popup.m_selectall.Enabled = lb_desired
			End If
		End If
		
	End If
End If

// Allow the descendant DataWindow to reconfigure any/all popup menu items...
This.Event ue_PrePopupMenuProperty(lm_dw_popup)

// Allow for any other changes to the popup menu before it is displayed...
This.Event ue_PrePopupMenu(lm_dw_popup)

// Display the popup menu...
lm_dw_popup.m_popup.PopMenu(lw_parent.PointerX() + 5, lw_parent.PointerY() + 10)

Destroy lm_dw_popup

// Issue a return code of 1 so that PB knows we have handled the RButtonDown event.
Return 1

end event

