$PBExportHeader$w_main.srw
forward
global type w_main from window
end type
type cb_popup from commandbutton within w_main
end type
type dw_1 from u_dw within w_main
end type
type cb_close from commandbutton within w_main
end type
end forward

global type w_main from window
integer width = 2784
integer height = 1812
boolean titlebar = true
string title = "Popup Menu"
boolean controlmenu = true
long backcolor = 67108864
string icon = "AppIcon!"
boolean center = true
cb_popup cb_popup
dw_1 dw_1
cb_close cb_close
end type
global w_main w_main

on w_main.create
this.cb_popup=create cb_popup
this.dw_1=create dw_1
this.cb_close=create cb_close
this.Control[]={this.cb_popup,&
this.dw_1,&
this.cb_close}
end on

on w_main.destroy
destroy(this.cb_popup)
destroy(this.dw_1)
destroy(this.cb_close)
end on

type cb_popup from commandbutton within w_main
integer x = 9
integer y = 1596
integer width = 590
integer height = 112
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Popup Menu Off"
end type

event clicked;
// Clicked event.

If Lower(Right(This.Text,3)) = "off" Then
	dw_1.of_SetPopupMenu(False)
	This.Text = "Popup Menu On"
Else
	dw_1.of_SetPopupMenu(True)
	This.Text = "Popup Menu Off"
End If

Return 0
end event

type dw_1 from u_dw within w_main
integer x = 14
integer y = 16
integer width = 2738
integer height = 1556
integer taborder = 10
string dataobject = "d_customer"
boolean hscrollbar = true
boolean vscrollbar = true
end type

event constructor;call super::constructor;
// Constructor event.


end event

type cb_close from commandbutton within w_main
integer x = 2446
integer y = 1596
integer width = 306
integer height = 112
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "&Close"
end type

event clicked;
// Clicked event

Close(Parent)
end event

