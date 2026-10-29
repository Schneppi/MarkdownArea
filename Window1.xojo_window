#tag DesktopWindow
Begin DesktopWindow Window1
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   False
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   HasTitleBar     =   True
   Height          =   480
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   743659519
   MenuBarVisible  =   False
   MinimumHeight   =   64
   MinimumWidth    =   64
   Resizeable      =   True
   Title           =   "Untitled"
   Type            =   0
   Visible         =   True
   Width           =   640
   Begin MarkdownArea Body
      AllowAutoDeactivate=   True
      AllowFocus      =   True
      AllowFocusRing  =   True
      AllowSpellChecking=   False
      AllowStyledText =   True
      AllowTabs       =   True
      Backdrop        =   0
      BackgroundColor =   &cFFFFFF00
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Format          =   ""
      FormattedText   =   ""
      HasBackgroundColor=   False
      HasBorder       =   True
      HasHorizontalScrollbar=   False
      HasToolbar      =   True
      HasVerticalScrollbar=   True
      Height          =   440
      HideSelection   =   True
      HorizontalScrollPosition=   0
      Index           =   -2147483648
      InitialParent   =   ""
      Italic          =   False
      Left            =   20
      LineHeight      =   0.0
      LineSpacing     =   1.3000000000000000444089
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Markdown        =   ""
      MaximumCharactersAllowed=   0
      MultiLine       =   True
      ReadOnly        =   False
      ReadOnlyRenderToggle=   True
      RenderMarkdown  =   True
      Scope           =   2
      SelectedText    =   ""
      SelectionAlignment=   0
      SelectionBold   =   False
      SelectionFontName=   ""
      SelectionFontSize=   0.0
      SelectionItalic =   False
      SelectionLength =   0
      SelectionPlain  =   False
      SelectionStart  =   0
      SelectionTextColor=   &c00000000
      SelectionUnderline=   False
      TabIndex        =   2
      TableAlignment  =   0
      TableFullWidth  =   False
      TabPanelIndex   =   0
      TabStop         =   True
      Text            =   ""
      TextAlignment   =   0
      TextColor       =   &c00000000
      ToolbarRevealDistance=   20
      Tooltip         =   ""
      Top             =   20
      Transparent     =   False
      Underline       =   False
      UnicodeMode     =   1
      ValidationMask  =   ""
      VerticalScrollPosition=   0
      Visible         =   True
      Width           =   600
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  Var sample() As String
		  sample.Add("# MarkdownArea")
		  sample.Add("Type **Markdown** here. Every line is rendered *instantly*, except the line with the caret.")
		  sample.Add("")
		  sample.Add("## Inline styles")
		  sample.Add("Use **bold**, *italic*, ***both***, ~~strikethrough~~, `inline code` and [links](https://xojo.com).")
		  sample.Add("")
		  sample.Add("## Tables")
		  sample.Add("| Element | Markdown | Rendered as |")
		  sample.Add("|:--------|:--------:|------------:|")
		  sample.Add("| Heading | `# Title` | **Large bold** text |")
		  sample.Add("| Emphasis | `*italic*` | *Slanted* text |")
		  sample.Add("| Link | `[text](url)` | [Underlined](https://xojo.com) text |")
		  sample.Add("| Long cell | `plain text` | Text that is too long for its column wraps inside the cell and keeps the table within the editor width |")
		  sample.Add("")
		  sample.Add( "![Eine Beschreibung des Bilds](https://data.mactechnews.de/391762.jpg)" )
		  sample.Add( "" )
		  sample.Add("### Lists")
		  sample.Add("- First item")
		  sample.Add("- Second item with __bold__ text")
		  sample.Add("1. Numbered item")
		  sample.Add("- [x] Done task")
		  sample.Add("- [ ] Open task")
		  sample.Add("")
		  sample.Add("> A block quote with _emphasis_.")
		  sample.Add("")
		  sample.Add("---")
		  sample.Add("")
		  sample.Add("```")
		  sample.Add("Var greeting As String = ""Hello""")
		  sample.Add("```")
		  Body.Markdown = String.FromArray( sample, EndOfLine )
		  
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FilePrint() As Boolean Handles FilePrint.Action
		  // Prints the rendered Markdown with a margin of half an inch on every side
		  Const kMargin As Integer = 36
		  
		  Var settings As New PrinterSetup
		  Var g As Graphics = settings.ShowPrinterDialog(Self)
		  If g = Nil Then Return True
		  
		  Var printer As MarkdownTextPrinter = Body.StyledTextPrinter(g, g.Width - (2 * kMargin))
		  Do
		    printer.DrawBlock(kMargin, kMargin, g.Height - (2 * kMargin))
		    If printer.EOF Then Exit Do
		    g.NextPage
		  Loop
		  Return True
		End Function
	#tag EndMenuHandler


#tag EndWindowCode

#tag ViewBehavior
	#tag ViewProperty
		Name="Name"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Interfaces"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Super"
		Visible=true
		Group="ID"
		InitialValue=""
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Width"
		Visible=true
		Group="Size"
		InitialValue="600"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Height"
		Visible=true
		Group="Size"
		InitialValue="400"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumWidth"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MinimumHeight"
		Visible=true
		Group="Size"
		InitialValue="64"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumWidth"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MaximumHeight"
		Visible=true
		Group="Size"
		InitialValue="32000"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Type"
		Visible=true
		Group="Frame"
		InitialValue="0"
		Type="Types"
		EditorType="Enum"
		#tag EnumValues
			"0 - Document"
			"1 - Movable Modal"
			"2 - Modal Dialog"
			"3 - Floating Window"
			"4 - Plain Box"
			"5 - Shadowed Box"
			"6 - Rounded Window"
			"7 - Global Floating Window"
			"8 - Sheet Window"
			"9 - Modeless Dialog"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Title"
		Visible=true
		Group="Frame"
		InitialValue="Untitled"
		Type="String"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasCloseButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMaximizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasMinimizeButton"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasFullScreenButton"
		Visible=true
		Group="Frame"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasTitleBar"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Resizeable"
		Visible=true
		Group="Frame"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="Composite"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MacProcID"
		Visible=false
		Group="OS X (Carbon)"
		InitialValue="0"
		Type="Integer"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="FullScreen"
		Visible=true
		Group="Behavior"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="DefaultLocation"
		Visible=true
		Group="Behavior"
		InitialValue="2"
		Type="Locations"
		EditorType="Enum"
		#tag EnumValues
			"0 - Default"
			"1 - Parent Window"
			"2 - Main Screen"
			"3 - Parent Window Screen"
			"4 - Stagger"
		#tag EndEnumValues
	#tag EndViewProperty
	#tag ViewProperty
		Name="Visible"
		Visible=true
		Group="Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="ImplicitInstance"
		Visible=true
		Group="Window Behavior"
		InitialValue="True"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="HasBackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="BackgroundColor"
		Visible=true
		Group="Background"
		InitialValue="&cFFFFFF"
		Type="ColorGroup"
		EditorType="ColorGroup"
	#tag EndViewProperty
	#tag ViewProperty
		Name="Backdrop"
		Visible=true
		Group="Background"
		InitialValue=""
		Type="Picture"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBar"
		Visible=true
		Group="Menus"
		InitialValue=""
		Type="DesktopMenuBar"
		EditorType=""
	#tag EndViewProperty
	#tag ViewProperty
		Name="MenuBarVisible"
		Visible=true
		Group="Deprecated"
		InitialValue="False"
		Type="Boolean"
		EditorType=""
	#tag EndViewProperty
#tag EndViewBehavior
