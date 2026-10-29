#tag DesktopWindow
Begin DesktopWindow Window1
   Backdrop        =   0
   BackgroundColor =   &cFFFFFF
   Composite       =   False
   DefaultLocation =   2
   FullScreen      =   False
   HasBackgroundColor=   False
   HasCloseButton  =   True
   HasFullScreenButton=   True
   HasMaximizeButton=   True
   HasMinimizeButton=   True
   HasTitleBar     =   True
   Height          =   740
   ImplicitInstance=   True
   MacProcID       =   0
   MaximumHeight   =   32000
   MaximumWidth    =   32000
   MenuBar         =   743659519
   MenuBarVisible  =   False
   MinimumHeight   =   600
   MinimumWidth    =   900
   Resizeable      =   True
   Title           =   "MarkdownArea Demo"
   Type            =   0
   Visible         =   True
   Width           =   1080
   Begin DesktopTabPanel Tabs
      AllowAutoDeactivate=   True
      Bold            =   False
      Enabled         =   True
      FontName        =   "System"
      FontSize        =   0.0
      FontUnit        =   0
      Height          =   708
      Index           =   -2147483648
      Italic          =   False
      Left            =   20
      LockBottom      =   True
      LockedInPosition=   False
      LockLeft        =   True
      LockRight       =   True
      LockTop         =   True
      Panels          =   ""
      Scope           =   2
      SmallTabs       =   False
      TabDefinition   =   "✏️ Playground\r🔒 Read-only\r📝 Plain text\r📊 Tables\r📦 Container"
      TabIndex        =   0
      TabPanelIndex   =   0
      TabStop         =   True
      Tooltip         =   ""
      Top             =   12
      Transparent     =   False
      Underline       =   False
      Value           =   0
      Visible         =   True
      Width           =   1040
      Begin MarkdownArea Editor
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
         Height          =   616
         HideSelection   =   True
         HorizontalScrollPosition=   0
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   True
         LockTop         =   True
         LineHeight      =   0.0
         LineSpacing     =   1.3000000000000000444089
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
         TabIndex        =   0
         TableAlignment  =   0
         TableFullWidth  =   False
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   ""
         TextAlignment   =   0
         TextColor       =   &c00000000
         ToolbarRevealDistance=   20
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         UnicodeMode     =   1
         ValidationMask  =   ""
         VerticalScrollPosition=   0
         Visible         =   True
         Width           =   740
      End
      Begin DesktopLabel StatusLabel
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   True
         LockTop         =   False
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   1
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   ""
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   680
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   740
      End
      Begin DesktopLabel ViewHeader
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   2
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "View"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopCheckBox RenderCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Render Markdown"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   3
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "RenderMarkdown: show the text rendered or as plain text"
         Top             =   80
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   240
      End
      Begin DesktopCheckBox ToolbarCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Formatting toolbar"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   4
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "HasToolbar: the bar appears when the mouse comes near the top edge"
         Top             =   104
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   240
      End
      Begin DesktopCheckBox ReadOnlyCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Read-only"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   5
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "ReadOnly: select and copy, but no editing"
         Top             =   128
         Transparent     =   False
         Underline       =   False
         Value           =   False
         Visible         =   True
         VisualState     =   0
         Width           =   240
      End
      Begin DesktopCheckBox ViewButtonCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "View button when read-only"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   818
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   6
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "ReadOnlyRenderToggle: lets readers switch the view"
         Top             =   152
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   222
      End
      Begin DesktopCheckBox BorderCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Border"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   7
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "HasBorder"
         Top             =   176
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   240
      End
      Begin DesktopCheckBox ScrollbarCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Scroll bar"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   8
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "HasVerticalScrollbar"
         Top             =   200
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   240
      End
      Begin DesktopLabel TextHeader
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   9
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Text"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   234
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopLabel AlignLabel
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   10
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Alignment"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   260
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   76
      End
      Begin DesktopPopupMenu AlignPopup
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         InitialValue    =   "Left\rCenter\rRight"
         Italic          =   False
         Left            =   880
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         SelectedRowIndex=   0
         TabIndex        =   11
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "TextAlignment"
         Top             =   259
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   160
      End
      Begin DesktopLabel FontLabel
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   12
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Font"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   290
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   76
      End
      Begin DesktopPopupMenu FontPopup
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         InitialValue    =   ""
         Italic          =   False
         Left            =   880
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         SelectedRowIndex=   -1
         TabIndex        =   13
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "FontName"
         Top             =   289
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   160
      End
      Begin DesktopLabel SizeLabel
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   14
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Size"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   320
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   76
      End
      Begin DesktopSlider SizeSlider
         AllowAutoDeactivate=   True
         AllowLiveScrolling=   True
         Enabled         =   True
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Left            =   880
         LineStep        =   1
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         MaximumValue    =   28
         MinimumValue    =   9
         PageStep        =   2
         Scope           =   2
         TabIndex        =   15
         TabPanelIndex   =   1
         TabStop         =   True
         TickMarkStyle   =   0
         Tooltip         =   "FontSize"
         Top             =   319
         Transparent     =   False
         Value           =   13
         Visible         =   True
         Width           =   114
      End
      Begin DesktopLabel SizeValue
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   998
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   16
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "13 pt"
         TextAlignment   =   3
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   320
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   42
      End
      Begin DesktopLabel SpacingLabel
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   17
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Spacing"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   350
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   76
      End
      Begin DesktopSlider SpacingSlider
         AllowAutoDeactivate=   True
         AllowLiveScrolling=   True
         Enabled         =   True
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Left            =   880
         LineStep        =   1
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         MaximumValue    =   25
         MinimumValue    =   10
         PageStep        =   2
         Scope           =   2
         TabIndex        =   18
         TabPanelIndex   =   1
         TabStop         =   True
         TickMarkStyle   =   0
         Tooltip         =   "LineSpacing"
         Top             =   349
         Transparent     =   False
         Value           =   13
         Visible         =   True
         Width           =   114
      End
      Begin DesktopLabel SpacingValue
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   998
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   19
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "1.3×"
         TextAlignment   =   3
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   350
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   42
      End
      Begin DesktopLabel TablesHeader
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   20
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Tables"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   386
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopLabel PlacementLabel
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   21
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Placement"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   412
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   76
      End
      Begin DesktopPopupMenu TablePopup
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         InitialValue    =   "Left\rCenter\rRight"
         Italic          =   False
         Left            =   880
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         SelectedRowIndex=   0
         TabIndex        =   22
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "TableAlignment"
         Top             =   411
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   160
      End
      Begin DesktopCheckBox FullWidthCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Stretch to full width"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   23
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "TableFullWidth"
         Top             =   442
         Transparent     =   False
         Underline       =   False
         Value           =   False
         Visible         =   True
         VisualState     =   0
         Width           =   240
      End
      Begin DesktopLabel ThemeHeader
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   24
         TabPanelIndex   =   1
         TabStop         =   True
         Text            =   "Theme"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   476
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopPopupMenu ThemePopup
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         InitialValue    =   "Automatic\rPaper\rOcean\rMint\rMidnight\rTerminal"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         SelectedRowIndex=   0
         TabIndex        =   25
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "BackgroundColor and TextColor"
         Top             =   502
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopButton SurpriseButton
         AllowAutoDeactivate=   True
         Bold            =   False
         Cancel          =   False
         Caption         =   "🎲 Surprise me"
         Default         =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         MacButtonStyle  =   0
         Scope           =   2
         TabIndex        =   26
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "Rolls a random look"
         Top             =   542
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopButton PrintButton
         AllowAutoDeactivate=   True
         Bold            =   False
         Cancel          =   False
         Caption         =   "Print…"
         Default         =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         MacButtonStyle  =   0
         Scope           =   2
         TabIndex        =   27
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "StyledTextPrinter, from the MarkdownPrinting module"
         Top             =   574
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   116
      End
      Begin DesktopButton ResetButton
         AllowAutoDeactivate=   True
         Bold            =   False
         Cancel          =   False
         Caption         =   "Reset"
         Default         =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   924
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         MacButtonStyle  =   0
         Scope           =   2
         TabIndex        =   28
         TabPanelIndex   =   1
         TabStop         =   True
         Tooltip         =   "Back to the defaults"
         Top             =   574
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   116
      End
      Begin MarkdownArea ReadOnlyArea
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
         Height          =   644
         HideSelection   =   True
         HorizontalScrollPosition=   0
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   True
         LockTop         =   True
         LineHeight      =   0.0
         LineSpacing     =   1.3000000000000000444089
         Markdown        =   ""
         MaximumCharactersAllowed=   0
         MultiLine       =   True
         ReadOnly        =   True
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
         TabIndex        =   0
         TableAlignment  =   0
         TableFullWidth  =   False
         TabPanelIndex   =   2
         TabStop         =   True
         Text            =   ""
         TextAlignment   =   0
         TextColor       =   &c00000000
         ToolbarRevealDistance=   20
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         UnicodeMode     =   1
         ValidationMask  =   ""
         VerticalScrollPosition=   0
         Visible         =   True
         Width           =   740
      End
      Begin DesktopLabel ReadOnlyHeader
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   1
         TabPanelIndex   =   2
         TabStop         =   True
         Text            =   "Read-only"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopLabel ReadOnlyInfo
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   120
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   True
         Scope           =   2
         Selectable      =   False
         TabIndex        =   2
         TabPanelIndex   =   2
         TabStop         =   True
         Text            =   "Readers can select and copy text and Cmd/Ctrl-click links, but not type. Move the mouse over the document: the view button in the top right corner switches between rendered Markdown and plain text."
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   80
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopCheckBox LockCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "🔒 Read-only"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   3
         TabPanelIndex   =   2
         TabStop         =   True
         Tooltip         =   "ReadOnly"
         Top             =   210
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   240
      End
      Begin DesktopCheckBox SwitchCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Readers can switch the view"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   818
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   4
         TabPanelIndex   =   2
         TabStop         =   True
         Tooltip         =   "ReadOnlyRenderToggle"
         Top             =   234
         Transparent     =   False
         Underline       =   False
         Value           =   True
         Visible         =   True
         VisualState     =   1
         Width           =   222
      End
      Begin DesktopLabel PlainLabel
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   False
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   0
         TabPanelIndex   =   3
         TabStop         =   True
         Text            =   "📝 Plain text editor: RenderMarkdown and HasToolbar off"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   490
      End
      Begin DesktopLabel PreviewLabel
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   550
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   False
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   1
         TabPanelIndex   =   3
         TabStop         =   True
         Text            =   "✨ Live preview: rendered and read-only"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   490
      End
      Begin MarkdownArea PlainArea
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
         HasToolbar      =   False
         HasVerticalScrollbar=   True
         Height          =   616
         HideSelection   =   True
         HorizontalScrollPosition=   0
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   False
         LockTop         =   True
         LineHeight      =   0.0
         LineSpacing     =   1.3000000000000000444089
         Markdown        =   ""
         MaximumCharactersAllowed=   0
         MultiLine       =   True
         ReadOnly        =   False
         ReadOnlyRenderToggle=   True
         RenderMarkdown  =   False
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
         TabPanelIndex   =   3
         TabStop         =   True
         Text            =   ""
         TextAlignment   =   0
         TextColor       =   &c00000000
         ToolbarRevealDistance=   20
         Tooltip         =   ""
         Top             =   84
         Transparent     =   False
         Underline       =   False
         UnicodeMode     =   1
         ValidationMask  =   ""
         VerticalScrollPosition=   0
         Visible         =   True
         Width           =   490
      End
      Begin MarkdownArea PreviewArea
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
         HasToolbar      =   False
         HasVerticalScrollbar=   True
         Height          =   616
         HideSelection   =   True
         HorizontalScrollPosition=   0
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   550
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   False
         LockTop         =   True
         LineHeight      =   0.0
         LineSpacing     =   1.3000000000000000444089
         Markdown        =   ""
         MaximumCharactersAllowed=   0
         MultiLine       =   True
         ReadOnly        =   True
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
         TabIndex        =   3
         TableAlignment  =   0
         TableFullWidth  =   False
         TabPanelIndex   =   3
         TabStop         =   True
         Text            =   ""
         TextAlignment   =   0
         TextColor       =   &c00000000
         ToolbarRevealDistance=   20
         Tooltip         =   ""
         Top             =   84
         Transparent     =   False
         Underline       =   False
         UnicodeMode     =   1
         ValidationMask  =   ""
         VerticalScrollPosition=   0
         Visible         =   True
         Width           =   490
      End
      Begin MarkdownArea TablesArea
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
         Height          =   644
         HideSelection   =   True
         HorizontalScrollPosition=   0
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   True
         LockTop         =   True
         LineHeight      =   0.0
         LineSpacing     =   1.3000000000000000444089
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
         TabIndex        =   0
         TableAlignment  =   1
         TableFullWidth  =   False
         TabPanelIndex   =   4
         TabStop         =   True
         Text            =   ""
         TextAlignment   =   0
         TextColor       =   &c00000000
         ToolbarRevealDistance=   20
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         UnicodeMode     =   1
         ValidationMask  =   ""
         VerticalScrollPosition=   0
         Visible         =   True
         Width           =   740
      End
      Begin DesktopLabel TableDemoHeader
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   1
         TabPanelIndex   =   4
         TabStop         =   True
         Text            =   "Placement"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopRadioGroup PlacementRadios
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   72
         Horizontal      =   False
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         InitialValue    =   "Left\rCenter\rRight"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         SelectedIndex   =   1
         TabIndex        =   2
         TabPanelIndex   =   4
         TabStop         =   True
         Tooltip         =   ""
         Top             =   82
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopCheckBox TablesFullWidthCheck
         AllowAutoDeactivate=   True
         Bold            =   False
         Caption         =   "Stretch to full width"
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   3
         TabPanelIndex   =   4
         TabStop         =   True
         Tooltip         =   "TableFullWidth"
         Top             =   164
         Transparent     =   False
         Underline       =   False
         Value           =   False
         Visible         =   True
         VisualState     =   0
         Width           =   240
      End
      Begin DesktopLabel TableInfo
         AllowAutoDeactivate=   True
         Bold            =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   60
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         Multiline       =   True
         Scope           =   2
         Selectable      =   False
         TabIndex        =   4
         TabPanelIndex   =   4
         TabStop         =   True
         Text            =   "Tables narrower than the editor are placed by TableAlignment. Long cells wrap inside their column."
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   198
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopButton ShuffleButton
         AllowAutoDeactivate=   True
         Bold            =   False
         Cancel          =   False
         Caption         =   "🏆 Shuffle the scores"
         Default         =   False
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   22
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   800
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   False
         LockRight       =   True
         LockTop         =   True
         MacButtonStyle  =   0
         Scope           =   2
         TabIndex        =   5
         TabPanelIndex   =   4
         TabStop         =   True
         Tooltip         =   "Plays another round"
         Top             =   268
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   240
      End
      Begin DesktopLabel ContainerLabel
         AllowAutoDeactivate=   True
         Bold            =   True
         Enabled         =   True
         FontName        =   "System"
         FontSize        =   0.0
         FontUnit        =   0
         Height          =   20
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Italic          =   False
         Left            =   40
         LockBottom      =   False
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   True
         LockTop         =   True
         Multiline       =   False
         Scope           =   2
         Selectable      =   False
         TabIndex        =   0
         TabPanelIndex   =   5
         TabStop         =   True
         Text            =   "📦 A MarkdownArea inside a DesktopContainer (MarkdownContainer)"
         TextAlignment   =   0
         TextColor       =   &c000000
         Tooltip         =   ""
         Top             =   56
         Transparent     =   False
         Underline       =   False
         Visible         =   True
         Width           =   1000
      End
      Begin MarkdownContainer ContainerDemo
         AllowAutoDeactivate=   True
         AllowFocus      =   False
         AllowFocusRing  =   False
         AllowTabs       =   True
         Backdrop        =   0
         BackgroundColor =   &cFFFFFF
         Composited      =   False
         Enabled         =   True
         HasBackgroundColor=   False
         Height          =   616
         Index           =   -2147483648
         InitialParent   =   "Tabs"
         Left            =   40
         LockBottom      =   True
         LockedInPosition=   False
         LockLeft        =   True
         LockRight       =   True
         LockTop         =   True
         Scope           =   2
         TabIndex        =   1
         TabPanelIndex   =   5
         TabStop         =   True
         Tooltip         =   ""
         Top             =   84
         Transparent     =   False
         Visible         =   True
         Width           =   1000
      End
   End
   Begin Timer SyncTimer
      Index           =   -2147483648
      LockedInPosition=   False
      Period          =   250
      RunMode         =   2
      Scope           =   2
      TabPanelIndex   =   0
   End
End
#tag EndDesktopWindow

#tag WindowCode
	#tag Event
		Sub Opening()
		  StatusLabel.TextColor = Color.DisabledTextColor
		  FillFontPopup

		  ReadOnlyArea.Markdown = ReleaseNotesMarkdown
		  PlainArea.Text = NoteMarkdown
		  PreviewArea.Markdown = NoteMarkdown
		  TablesArea.Markdown = TablesMarkdown

		  ResetPlayground
		  LayoutPlainTab
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resized()
		  LayoutPlainTab
		End Sub
	#tag EndEvent

	#tag Event
		Sub Resizing()
		  LayoutPlainTab
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function FilePrint() As Boolean Handles FilePrint.Action
		  PrintArea(CurrentArea)
		  Return True
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h21
		Private Function AlignmentFromIndex(index As Integer) As TextAlignments
		  Select Case index
		  Case 1
		    Return TextAlignments.Center
		  Case 2
		    Return TextAlignments.Right
		  Else
		    Return TextAlignments.Left
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function AlignmentIndex(value As TextAlignments) As Integer
		  Select Case value
		  Case TextAlignments.Center
		    Return 1
		  Case TextAlignments.Right
		    Return 2
		  Else
		    Return 0
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyTheme(index As Integer)
		  // Each theme is a background and a text color; "Automatic" follows light and dark mode
		  Var background, foreground As Color
		  Select Case index
		  Case 1 // Paper
		    background = &cFBF6E9
		    foreground = &c3B2F2F
		  Case 2 // Ocean
		    background = &cE6F3FA
		    foreground = &c0B3954
		  Case 3 // Mint
		    background = &cEAF7EF
		    foreground = &c1D4D33
		  Case 4 // Midnight
		    background = &c161A2E
		    foreground = &cDCE1F5
		  Case 5 // Terminal
		    background = &c0C0C0C
		    foreground = &c3CFF7A
		  Else
		    Editor.HasBackgroundColor = False
		    // &c000000 makes MarkdownArea use the system text color again
		    Editor.TextColor = &c000000
		    Return
		  End Select

		  Editor.BackgroundColor = background
		  Editor.HasBackgroundColor = True
		  Editor.TextColor = foreground
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CurrentArea() As MarkdownArea
		  // The MarkdownArea on the tab that is showing
		  Select Case Tabs.SelectedPanelIndex
		  Case 1
		    Return ReadOnlyArea
		  Case 2
		    Return PlainArea
		  Case 3
		    Return TablesArea
		  Case 4
		    Return ContainerDemo.Area
		  Else
		    Return Editor
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DefaultFontSize() As Integer
		  // What a FontSize of 0 stands for in MarkdownArea
		  #If TargetMacOS Then
		    Return 13
		  #Else
		    Return 12
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FillFontPopup()
		  // A few fonts that come with each system
		  Var fonts() As String = Array("System")
		  #If TargetMacOS Then
		    fonts.Add("Georgia")
		    fonts.Add("Avenir Next")
		    fonts.Add("Helvetica Neue")
		    fonts.Add("Menlo")
		    fonts.Add("Chalkboard SE")
		  #ElseIf TargetWindows Then
		    fonts.Add("Georgia")
		    fonts.Add("Segoe UI")
		    fonts.Add("Calibri")
		    fonts.Add("Consolas")
		    fonts.Add("Comic Sans MS")
		  #Else
		    fonts.Add("Serif")
		    fonts.Add("Sans")
		    fonts.Add("Monospace")
		  #EndIf

		  FontPopup.RemoveAllRows
		  For Each fontName As String In fonts
		    FontPopup.AddRow(fontName)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LayoutPlainTab()
		  // The plain text editor and its preview share the tab's width half and half
		  Const kGap As Integer = 20
		  Var left As Integer = Tabs.Left + 20
		  Var half As Integer = (Tabs.Width - 40 - kGap) \ 2

		  PlainLabel.Left = left
		  PlainLabel.Width = half
		  PlainArea.Left = left
		  PlainArea.Width = half

		  PreviewLabel.Left = left + half + kGap
		  PreviewLabel.Width = half
		  PreviewArea.Left = left + half + kGap
		  PreviewArea.Width = half
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NoteMarkdown() As String
		  Var lines() As String
		  lines.Add("# Shopping list")
		  lines.Add("This editor has **RenderMarkdown** and **HasToolbar** turned off, so it works like a plain DesktopTextArea. The preview on the right renders the same text while you type.")
		  lines.Add("")
		  lines.Add("- [ ] Coffee ☕")
		  lines.Add("- [ ] *Fresh* bread 🥖")
		  lines.Add("- [x] ~~Milk~~")
		  lines.Add("")
		  lines.Add("> Edit me on the left!")
		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PlaygroundMarkdown() As String
		  Var lines() As String
		  lines.Add("# Welcome to MarkdownArea ✨")
		  lines.Add("Type **Markdown** here. Every line is rendered *instantly*, except the line with the caret, which shows its raw Markdown.")
		  lines.Add("")
		  lines.Add("> 💡 Flip the switches on the right, or press **🎲 Surprise me** for a random look.")
		  lines.Add("")
		  lines.Add("## Inline styles")
		  lines.Add("Use **bold**, *italic*, ***both***, ~~strikethrough~~, `inline code` and [links](https://xojo.com). Cmd/Ctrl-click a link to open it.")
		  lines.Add("")
		  lines.Add("## Lists")
		  lines.Add("- Bullets with __bold__ text")
		  lines.Add("- Long items wrap neatly and line up with the text of the item, not with its bullet")
		  lines.Add("1. Numbered item")
		  lines.Add("2. Another one")
		  lines.Add("- [x] Write a Markdown editor in pure Xojo")
		  lines.Add("- [ ] Take over the world")
		  lines.Add("")
		  lines.Add("## Tables")
		  lines.Add("| Element | Markdown | Rendered as |")
		  lines.Add("|:--------|:--------:|------------:|")
		  lines.Add("| Heading | `# Title` | **Large bold** text |")
		  lines.Add("| Emphasis | `*italic*` | *Slanted* text |")
		  lines.Add("| Link | `[text](url)` | [Underlined](https://xojo.com) text |")
		  lines.Add("| Long cell | `plain text` | Text that is too long for its column wraps inside the cell |")
		  lines.Add("")
		  lines.Add("## Images")
		  lines.Add("![A sample picture](https://data.mactechnews.de/391762.jpg)")
		  lines.Add("")
		  lines.Add("## Code")
		  lines.Add("```")
		  lines.Add("Var greeting As String = ""Hello, Markdown!""")
		  lines.Add("MessageBox(greeting)")
		  lines.Add("```")
		  lines.Add("")
		  lines.Add("---")
		  lines.Add("Move the mouse to the top edge for the formatting toolbar, or press **Cmd/Ctrl+B**, **I** and **K**.")
		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PrintArea(area As MarkdownArea)
		  // Prints the rendered Markdown with a margin of half an inch on every side
		  Const kMargin As Integer = 36

		  Var settings As New PrinterSetup
		  Var g As Graphics = settings.ShowPrinterDialog(Self)
		  If g = Nil Then Return

		  Var printer As MarkdownTextPrinter = area.StyledTextPrinter(g, g.Width - (2 * kMargin))
		  Do
		    printer.DrawBlock(kMargin, kMargin, g.Height - (2 * kMargin))
		    If printer.EOF Then Exit Do
		    g.NextPage
		  Loop
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReleaseNotesMarkdown() As String
		  Var lines() As String
		  lines.Add("# Release notes 🚀")
		  lines.Add("*Version 2.0, shown in a read-only MarkdownArea*")
		  lines.Add("")
		  lines.Add("This document can't be changed. You can still select and copy text, and Cmd/Ctrl-click [links](https://xojo.com).")
		  lines.Add("")
		  lines.Add("> 👀 Move the mouse over the document. The small button in the top right corner switches between rendered Markdown and plain text.")
		  lines.Add("")
		  lines.Add("## New")
		  lines.Add("- **Printing** on macOS, Windows and Linux")
		  lines.Add("- Centered and full-width **tables**")
		  lines.Add("- A read-only mode with its own view button")
		  lines.Add("")
		  lines.Add("## Fixed")
		  lines.Add("- [x] Spaces between words on Windows")
		  lines.Add("- [x] Scrolling one line per wheel step")
		  lines.Add("- [ ] Nothing left to fix 🎉 (yet)")
		  lines.Add("")
		  lines.Add("| Platform | Supported |")
		  lines.Add("|:---------|:---------:|")
		  lines.Add("| macOS | ✅ |")
		  lines.Add("| Windows | ✅ |")
		  lines.Add("| Linux | ✅ |")
		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResetPlayground()
		  mUpdating = True
		  Editor.Markdown = PlaygroundMarkdown
		  Editor.RenderMarkdown = True
		  Editor.ReadOnly = False
		  Editor.ReadOnlyRenderToggle = True
		  Editor.HasToolbar = True
		  Editor.HasBorder = True
		  Editor.HasVerticalScrollbar = True
		  Editor.TextAlignment = TextAlignments.Left
		  Editor.FontName = "System"
		  Editor.FontSize = 0
		  Editor.LineSpacing = 1.3
		  Editor.TableAlignment = MarkdownArea.TableAlignments.Left
		  Editor.TableFullWidth = False
		  ThemePopup.SelectedRowIndex = 0
		  ApplyTheme(0)
		  SyncPlaygroundControls
		  mUpdating = False
		  UpdateStatus
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ScoreboardMarkdown() As String
		  // Five teams with random points, best first
		  Var teams() As String = Array("🦆 Rubber Ducks", "🐙 Octo Coders", "🚀 Rocket Science", "🐢 Turtle Power", "🍕 Pizza Party")
		  Var points() As Integer
		  For i As Integer = 0 To teams.LastIndex
		    points.Add(System.Random.InRange(10, 99))
		  Next
		  points.SortWith(teams)

		  Var ranks() As String = Array("🥇", "🥈", "🥉", "4", "5")
		  Var lines() As String
		  lines.Add("| Rank | Team | Points |")
		  lines.Add("|:----:|:-----|-------:|")
		  For i As Integer = 0 To teams.LastIndex
		    Var team As Integer = teams.LastIndex - i
		    lines.Add("| " + ranks(i) + " | " + teams(team) + " | " + points(team).ToString + " |")
		  Next
		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Surprise()
		  // A random font, size, spacing, alignment and theme
		  Var r As Random = System.Random
		  mUpdating = True
		  Editor.TextAlignment = AlignmentFromIndex(r.InRange(0, 2))
		  Editor.FontName = FontPopup.RowTextAt(r.InRange(0, FontPopup.LastRowIndex))
		  Editor.FontSize = r.InRange(11, 20)
		  Editor.LineSpacing = r.InRange(11, 20) / 10
		  Editor.TableAlignment = TableAlignmentFromIndex(r.InRange(0, 2))
		  Editor.TableFullWidth = r.InRange(0, 3) = 0

		  // Never the same theme twice in a row
		  Var theme As Integer = ThemePopup.SelectedRowIndex
		  While theme = ThemePopup.SelectedRowIndex
		    theme = r.InRange(1, ThemePopup.LastRowIndex)
		  Wend
		  ThemePopup.SelectedRowIndex = theme
		  ApplyTheme(theme)

		  SyncPlaygroundControls
		  mUpdating = False
		  UpdateStatus
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SyncPlaygroundControls()
		  // Shows the Playground editor's settings in the controls next to it
		  Var wasUpdating As Boolean = mUpdating
		  mUpdating = True

		  RenderCheck.Value = Editor.RenderMarkdown
		  ToolbarCheck.Value = Editor.HasToolbar
		  ReadOnlyCheck.Value = Editor.ReadOnly
		  ViewButtonCheck.Value = Editor.ReadOnlyRenderToggle
		  ViewButtonCheck.Enabled = Editor.ReadOnly
		  BorderCheck.Value = Editor.HasBorder
		  ScrollbarCheck.Value = Editor.HasVerticalScrollbar

		  AlignPopup.SelectedRowIndex = AlignmentIndex(Editor.TextAlignment)
		  FontPopup.SelectedRowIndex = 0
		  For i As Integer = 0 To FontPopup.LastRowIndex
		    If FontPopup.RowTextAt(i) = Editor.FontName Then FontPopup.SelectedRowIndex = i
		  Next

		  If Editor.FontSize > 0 Then
		    SizeSlider.Value = Editor.FontSize
		  Else
		    SizeSlider.Value = DefaultFontSize
		  End If
		  SizeValue.Text = SizeSlider.Value.ToString + " pt"
		  SpacingSlider.Value = Round(Editor.LineSpacing * 10)
		  SpacingValue.Text = Format(SpacingSlider.Value / 10, "0.0") + "×"

		  TablePopup.SelectedRowIndex = TableAlignmentIndex(Editor.TableAlignment)
		  FullWidthCheck.Value = Editor.TableFullWidth

		  mUpdating = wasUpdating
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TableAlignmentFromIndex(index As Integer) As MarkdownArea.TableAlignments
		  Select Case index
		  Case 1
		    Return MarkdownArea.TableAlignments.Center
		  Case 2
		    Return MarkdownArea.TableAlignments.Right
		  Else
		    Return MarkdownArea.TableAlignments.Left
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TableAlignmentIndex(value As MarkdownArea.TableAlignments) As Integer
		  Select Case value
		  Case MarkdownArea.TableAlignments.Center
		    Return 1
		  Case MarkdownArea.TableAlignments.Right
		    Return 2
		  Else
		    Return 0
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function TablesMarkdown() As String
		  Var lines() As String
		  lines.Add("# Tables 📊")
		  lines.Add("Tables narrower than the editor are **centered** here. Pick another placement on the right, or stretch them to the full width.")
		  lines.Add("")
		  lines.Add("## 🏆 Scoreboard")
		  lines.Add(ScoreboardMarkdown)
		  lines.Add("")
		  lines.Add("## Column alignment")
		  lines.Add("| Left | Center | Right |")
		  lines.Add("|:-----|:------:|------:|")
		  lines.Add("| Apples | 🍎 | 1.20 |")
		  lines.Add("| Bananas | 🍌 | 0.89 |")
		  lines.Add("| Cherries | 🍒 | 4.50 |")
		  lines.Add("")
		  lines.Add("## Long cells wrap")
		  lines.Add("| Feature | What it does |")
		  lines.Add("|:--------|:-------------|")
		  lines.Add("| Live rendering | Every line is rendered while you type, except the line with the caret, which shows its raw Markdown so you can edit it |")
		  lines.Add("| Printing | Prints the rendered document page by page, on macOS, Windows and Linux |")
		  lines.Add("| Read-only mode | Readers can select, copy and follow links, and switch between rendered Markdown and plain text |")
		  Return String.FromArray(lines, EndOfLine)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateStatus()
		  // A status line under the Playground editor
		  Var value As String = Editor.Text
		  Var words As Integer
		  For Each word As String In value.ReplaceLineEndings(" ").Split(" ")
		    If word.Trim <> "" Then words = words + 1
		  Next

		  Var parts() As String
		  If Editor.RenderMarkdown Then
		    parts.Add("✨ Rendered")
		  Else
		    parts.Add("📄 Plain text")
		  End If
		  If Editor.ReadOnly Then parts.Add("🔒 Read-only")
		  parts.Add(words.ToString + " words")
		  parts.Add(value.Length.ToString + " characters")
		  Var lineNumber As Integer = Editor.LineNumber(Editor.SelectionStart) + 1
		  parts.Add("Line " + lineNumber.ToString)
		  If Editor.SelectionLength > 0 Then parts.Add(Editor.SelectionLength.ToString + " selected")
		  StatusLabel.Text = String.FromArray(parts, "   ·   ")
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21, Description = 54727565207768696C652074686520636F6E74726F6C73206172652066696C6C656420696E20636F64652C20736F207468656972206576656E747320646F206E6F74206368616E67652074686520656469746F722E
		Private mUpdating As Boolean
	#tag EndProperty


#tag EndWindowCode

#tag Events Editor
	#tag Event
		Sub TextChanged()
		  UpdateStatus
		End Sub
	#tag EndEvent
	#tag Event
		Sub SelectionChanged()
		  UpdateStatus
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events RenderCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.RenderMarkdown = Me.Value
		  UpdateStatus
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ToolbarCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.HasToolbar = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ReadOnlyCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.ReadOnly = Me.Value
		  ViewButtonCheck.Enabled = Me.Value
		  UpdateStatus
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ViewButtonCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.ReadOnlyRenderToggle = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events BorderCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.HasBorder = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ScrollbarCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.HasVerticalScrollbar = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events AlignPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  If mUpdating Then Return
		  Editor.TextAlignment = AlignmentFromIndex(Me.SelectedRowIndex)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events FontPopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  If mUpdating Or Me.SelectedRowIndex < 0 Then Return
		  Editor.FontName = Me.RowTextAt(Me.SelectedRowIndex)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SizeSlider
	#tag Event
		Sub ValueChanged()
		  SizeValue.Text = Me.Value.ToString + " pt"
		  If mUpdating Then Return
		  Editor.FontSize = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SpacingSlider
	#tag Event
		Sub ValueChanged()
		  SpacingValue.Text = Format(Me.Value / 10, "0.0") + "×"
		  If mUpdating Then Return
		  Editor.LineSpacing = Me.Value / 10
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events TablePopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  If mUpdating Then Return
		  Editor.TableAlignment = TableAlignmentFromIndex(Me.SelectedRowIndex)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events FullWidthCheck
	#tag Event
		Sub ValueChanged()
		  If mUpdating Then Return
		  Editor.TableFullWidth = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ThemePopup
	#tag Event
		Sub SelectionChanged(item As DesktopMenuItem)
		  If mUpdating Then Return
		  ApplyTheme(Me.SelectedRowIndex)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SurpriseButton
	#tag Event
		Sub Pressed()
		  Surprise
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PrintButton
	#tag Event
		Sub Pressed()
		  PrintArea(Editor)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ResetButton
	#tag Event
		Sub Pressed()
		  ResetPlayground
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events LockCheck
	#tag Event
		Sub ValueChanged()
		  ReadOnlyArea.ReadOnly = Me.Value
		  SwitchCheck.Enabled = Me.Value
		  If Me.Value Then
		    Me.Caption = "🔒 Read-only"
		  Else
		    Me.Caption = "🔓 Read-only (try typing!)"
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SwitchCheck
	#tag Event
		Sub ValueChanged()
		  ReadOnlyArea.ReadOnlyRenderToggle = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlainArea
	#tag Event
		Sub TextChanged()
		  PreviewArea.Markdown = Me.Text
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events PlacementRadios
	#tag Event
		Sub SelectionChanged(button As DesktopRadioButton)
		  TablesArea.TableAlignment = TableAlignmentFromIndex(Me.SelectedIndex)
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events TablesFullWidthCheck
	#tag Event
		Sub ValueChanged()
		  TablesArea.TableFullWidth = Me.Value
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events ShuffleButton
	#tag Event
		Sub Pressed()
		  // A new round: keep the scroll position while the scores change
		  Var scroll As Integer = TablesArea.VerticalScrollPosition
		  TablesArea.Markdown = TablesMarkdown
		  TablesArea.VerticalScrollPosition = scroll
		End Sub
	#tag EndEvent
#tag EndEvents
#tag Events SyncTimer
	#tag Event
		Sub Action()
		  // The editor's own view button and toolbar can switch the view; keep the checkbox in step
		  If mUpdating Then Return
		  If RenderCheck.Value <> Editor.RenderMarkdown Then
		    SyncPlaygroundControls
		    UpdateStatus
		  End If
		End Sub
	#tag EndEvent
#tag EndEvents
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
