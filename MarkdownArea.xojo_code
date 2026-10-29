#tag Class
Protected Class MarkdownArea
Inherits DesktopCanvas
	#tag Event
		Sub Closing()
		  If mBlinkTimer <> Nil Then
		    mBlinkTimer.RunMode = Timer.RunModes.Off
		    RemoveHandler mBlinkTimer.Action, WeakAddressOf BlinkTimerAction
		    mBlinkTimer = Nil
		  End If
		  If mClickTimer <> Nil Then
		    mClickTimer.RunMode = Timer.RunModes.Off
		    RemoveHandler mClickTimer.Action, WeakAddressOf ClickTimerAction
		    mClickTimer = Nil
		  End If
		  If mHoverTimer <> Nil Then
		    mHoverTimer.RunMode = Timer.RunModes.Off
		    RemoveHandler mHoverTimer.Action, WeakAddressOf HoverTimerAction
		    mHoverTimer = Nil
		  End If
		  If mDownloads <> Nil Then
		    For Each key As Variant In mDownloads.Keys
		      Var connection As URLConnection = key
		      RemoveHandler connection.ContentReceived, WeakAddressOf ImageDownloaded
		      RemoveHandler connection.Error, WeakAddressOf ImageDownloadFailed
		      connection.Disconnect
		    Next
		    mDownloads = Nil
		  End If
		  RaiseEvent Closing
		End Sub
	#tag EndEvent

	#tag Event
		Function ConstructContextualMenu(base As DesktopMenuItem, x As Integer, y As Integer) As Boolean
		  // The application adds its items first; returning True means it built the whole menu itself
		  If RaiseEvent ConstructContextualMenu(base, x, y) Then Return True
		  If base.Count > 0 Then base.AddMenu(New DesktopMenuItem(DesktopMenuItem.TextSeparator))
		  
		  Var cutItem As New DesktopMenuItem(kLangCut, kMenuTagCut)
		  cutItem.Enabled = HasSelection And Not mReadOnly
		  base.AddMenu(cutItem)
		  
		  Var copyItem As New DesktopMenuItem(kLangCopy, kMenuTagCopy)
		  copyItem.Enabled = HasSelection
		  base.AddMenu(copyItem)
		  
		  Var pasteItem As New DesktopMenuItem(kLangPaste, kMenuTagPaste)
		  pasteItem.Enabled = Not mReadOnly
		  base.AddMenu(pasteItem)
		  
		  base.AddMenu(New DesktopMenuItem(DesktopMenuItem.TextSeparator))
		  base.AddMenu(New DesktopMenuItem(kLangSelectAll, kMenuTagSelectAll))
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Function ContextualMenuItemSelected(selectedItem As DesktopMenuItem) As Boolean
		  Select Case selectedItem.Tag.StringValue
		  Case kMenuTagCut
		    Cut
		  Case kMenuTagCopy
		    Copy
		  Case kMenuTagPaste
		    Paste
		  Case kMenuTagSelectAll
		    SelectAll
		  Else
		    // Items the application added itself
		    Return RaiseEvent ContextualMenuItemSelected(selectedItem)
		  End Select
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub FocusLost()
		  mHasFocus = False
		  mMouseSelecting = False
		  StopClickFreeze
		  // Without focus there is no caret line, so every line is rendered
		  UpdateCurrentLine
		  Refresh(False)
		  RaiseEvent FocusLost
		End Sub
	#tag EndEvent

	#tag Event
		Sub FocusReceived()
		  mHasFocus = True
		  // A click into the editor raises FocusReceived before MouseDown (seen inside a DesktopContainer).
		  // Showing the caret line raw right away would move the text before MouseDown looks up the clicked
		  // position, so the click would land on a line above or below. Freeze the layout like after a click;
		  // MouseDown takes the freeze over, and focus from the keyboard ends it shortly (see ClickTimerAction).
		  If mClickTimer <> Nil Then
		    mClickFreeze = True
		    mClickTimer.Period = kFocusFreezePeriod
		    mClickTimer.RunMode = Timer.RunModes.Single
		  Else
		    UpdateCurrentLine
		  End If
		  ResetBlink
		  Refresh(False)
		  RaiseEvent FocusReceived
		End Sub
	#tag EndEvent

	#tag Event
		Function KeyDown(key As String) As Boolean
		  // Typing right after a click must happen on the raw caret line
		  EndClickFreeze
		  If RaiseEvent KeyDown(key) Then Return True
		  
		  Var shift As Boolean = Keyboard.ShiftKey
		  Var command, wordModifier As Boolean
		  #If TargetMacOS Then
		    // macOS: Command is the shortcut and line modifier, Option moves by word
		    command = Keyboard.CommandKey
		    wordModifier = Keyboard.OptionKey
		  #Else
		    // Windows/Linux: Control is both the shortcut and the word modifier
		    command = Keyboard.ControlKey
		    wordModifier = command
		  #EndIf
		  
		  Select Case key.Asc
		  Case 28 // Left arrow
		    If command And TargetMacOS Then
		      MoveToRowEdge(False, shift)
		    Else
		      MoveHorizontal(-1, wordModifier, shift)
		    End If
		    Return True
		  Case 29 // Right arrow
		    If command And TargetMacOS Then
		      MoveToRowEdge(True, shift)
		    Else
		      MoveHorizontal(1, wordModifier, shift)
		    End If
		    Return True
		  Case 30 // Up arrow
		    If command Then
		      MoveCaret(0, 0, shift)
		    Else
		      MoveVertical(-1, shift)
		    End If
		    Return True
		  Case 31 // Down arrow
		    If command Then
		      MoveCaret(mLines.LastIndex, mLines(mLines.LastIndex).Length, shift)
		    Else
		      MoveVertical(1, shift)
		    End If
		    Return True
		  Case 1 // Home
		    #If TargetMacOS Then
		      // macOS text views scroll to the top on Home without moving the caret
		      mScrollY = 0
		      Refresh(False)
		    #Else
		      If command Then
		        MoveCaret(0, 0, shift)
		      Else
		        MoveToRowEdge(False, shift)
		      End If
		    #EndIf
		    Return True
		  Case 4 // End
		    #If TargetMacOS Then
		      // macOS text views scroll to the bottom on End without moving the caret
		      mScrollY = mContentHeight
		      ClampScroll
		      Refresh(False)
		    #Else
		      If command Then
		        MoveCaret(mLines.LastIndex, mLines(mLines.LastIndex).Length, shift)
		      Else
		        MoveToRowEdge(True, shift)
		      End If
		    #EndIf
		    Return True
		  Case 11 // Page up
		    MoveVertical(-RowsPerPage, shift)
		    Return True
		  Case 12 // Page down
		    MoveVertical(RowsPerPage, shift)
		    Return True
		  Case 8 // Backspace
		    DeleteBackward(wordModifier, command And TargetMacOS)
		    Return True
		  Case 127 // Forward delete
		    DeleteForward(wordModifier)
		    Return True
		  Case 13, 3 // Return, Enter
		    If MultiLine Then InsertTyped(Chr(10))
		    Return True
		  Case 9 // Tab (only arrives here when AllowTabs is True)
		    InsertTyped(Chr(9))
		    Return True
		  Case 27 // Escape
		    Return False
		  End Select
		  
		  If command Then
		    // Fallback for shortcuts the menu bar did not handle
		    Select Case key.Uppercase
		    Case "A"
		      SelectAll
		    Case "C"
		      Copy
		    Case "X"
		      Cut
		    Case "V"
		      Paste
		    Case "Z"
		      If shift Then
		        Redo
		      Else
		        Undo
		      End If
		    Case "B"
		      ApplyToolbarAction(kToolBold)
		    Case "I"
		      ApplyToolbarAction(kToolItalic)
		    Case "K"
		      ApplyToolbarAction(kToolLink)
		    Else
		      Return False
		    End Select
		    Return True
		  End If
		  
		  If key.Asc >= 32 Then
		    InsertTyped(key)
		    Return True
		  End If
		  Return False
		End Function
	#tag EndEvent

	#tag Event
		Function MouseDown(x As Integer, y As Integer) As Boolean
		  // Clicks on the toolbar belong to the toolbar; the button acts when the mouse is released on it.
		  // The hover state is refreshed first in case no MouseMove arrived before this click.
		  UpdateToolbarHover(x, y)
		  If mToolbarVisible And ToolbarContains(x, y) Then
		    mMouseHandledByApp = False
		    mToolbarPressed = ToolbarItemAt(x, y)
		    If mToolbarPressed < 0 Then mToolbarPressed = kToolbarSwallow
		    Refresh(False)
		    Return True
		  End If
		  
		  // The application gets the click first; returning True takes it over completely
		  mMouseHandledByApp = RaiseEvent MouseDown(x, y)
		  If mMouseHandledByApp Then Return True
		  
		  If IsContextualClick Then
		    // A right click keeps a selection it lands in, otherwise it moves the caret there first.
		    // It must return False, or Xojo does not raise ConstructContextualMenu.
		    Var clickLine, clickCol As Integer
		    PositionFromPoint(x, y, clickLine, clickCol)
		    If Not mHasFocus Then Self.SetFocus
		    If Not PositionIsSelected(clickLine, clickCol) Then MoveCaret(clickLine, clickCol, False)
		    Return False
		  End If
		  
		  // Scroll bar: a click above or below the thumb scrolls one page, the thumb itself is dragged
		  If mContentHeight > Height And x >= Width - kScrollbarHitWidth Then
		    Var thumbHeight As Double = ThumbHeight
		    Var thumbY As Double = 2 + (Height - 4 - thumbHeight) * mScrollY / (mContentHeight - Height)
		    If y < thumbY Or y >= thumbY + thumbHeight Then
		      If y < thumbY Then
		        mScrollY = mScrollY - Height
		      Else
		        mScrollY = mScrollY + Height
		      End If
		      ClampScroll
		      Refresh(False)
		      Return True
		    End If
		    mDraggingScrollbar = True
		    mDragStartY = y
		    mDragStartScroll = mScrollY
		    Return True
		  End If
		  
		  // Cmd+click (macOS) / Ctrl+click (Windows, Linux) on a link opens it instead of placing the caret
		  If LinkModifierDown(False) Then
		    Var url As String = LinkAt(x, y)
		    If url <> "" Then
		      OpenLink(url)
		      Return True
		    End If
		  End If
		  
		  // Every click of a double or triple click must land on the same layout. So the caret line
		  // keeps its current rendering until the double-click time has passed (see ClickTimerAction).
		  Var lineIndex, col As Integer
		  PositionFromPoint(x, y, lineIndex, col)
		  mClickFreeze = True
		  If mClickTimer <> Nil Then mClickTimer.RunMode = Timer.RunModes.Off
		  If Not mHasFocus Then Self.SetFocus
		  
		  Var now As Integer = System.Ticks
		  If now - mLastClickTicks <= DoubleClickTicks And Abs(x - mLastClickX) <= 4 And Abs(y - mLastClickY) <= 4 Then
		    mClickCount = mClickCount + 1
		  Else
		    mClickCount = 1
		  End If
		  mLastClickTicks = now
		  mLastClickX = x
		  mLastClickY = y
		  
		  Select Case mClickCount
		  Case 1
		    MoveCaret(lineIndex, col, Keyboard.ShiftKey)
		  Case 2
		    SelectWordAt(lineIndex, col)
		  Else
		    SelectLine(lineIndex)
		  End Select
		  
		  // Dragging after a double or triple click extends from this word or line
		  GetSelection(mOriginStartLine, mOriginStartCol, mOriginEndLine, mOriginEndCol)
		  mMouseSelecting = True
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub MouseDrag(x As Integer, y As Integer)
		  If mToolbarPressed <> -1 Then
		    // Show the pressed button as pressed only while the mouse is still on it
		    Var over As Integer = ToolbarItemAt(x, y)
		    If (over = mToolbarPressed) <> (mToolbarHoverItem = mToolbarPressed) Then SetToolbarState(True, over)
		    Return
		  End If
		  
		  RaiseEvent MouseDrag(x, y)
		  If mMouseHandledByApp Then Return
		  
		  If mDraggingScrollbar Then
		    Var track As Double = Height - 4
		    Var thumbHeight As Double = ThumbHeight
		    mScrollY = mDragStartScroll + (y - mDragStartY) * (mContentHeight - Height) / Max(1, track - thumbHeight)
		    ClampScroll
		    Refresh(False)
		    Return
		  End If
		  
		  If Not mMouseSelecting Then Return
		  
		  // Auto-scroll while dragging past the top or bottom edge
		  If y < 0 Then
		    mScrollY = mScrollY + y
		    ClampScroll
		  ElseIf y > Height Then
		    mScrollY = mScrollY + (y - Height)
		    ClampScroll
		  End If
		  
		  Var lineIndex, col As Integer
		  PositionFromPoint(x, y, lineIndex, col)
		  If mClickCount >= 2 Then
		    // macOS keeps sending MouseDrag while the button is held after a double click,
		    // so a word or line selection must never shrink below the unit that was clicked
		    ExtendUnitSelection(lineIndex, col)
		  ElseIf lineIndex <> mCaretLine Or col <> mCaretCol Then
		    MoveCaret(lineIndex, col, True)
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseEnter()
		  // Watch the modifier key while the mouse is over the editor, so the hand cursor
		  // also appears when Cmd/Ctrl is pressed without moving the mouse
		  If mHoverTimer <> Nil Then mHoverTimer.RunMode = Timer.RunModes.Multiple
		  RaiseEvent MouseEnter
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseExit()
		  If mHoverTimer <> Nil Then mHoverTimer.RunMode = Timer.RunModes.Off
		  If mToolbarPressed < 0 Then SetToolbarState(False, -1)
		  SetCursorKind(kCursorText)
		  RaiseEvent MouseExit
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseMove(x As Integer, y As Integer)
		  mMouseX = x
		  mMouseY = y
		  UpdateToolbarHover(x, y)
		  UpdateMouseCursor
		  RaiseEvent MouseMove(x, y)
		End Sub
	#tag EndEvent

	#tag Event
		Sub MouseUp(x As Integer, y As Integer)
		  If mToolbarPressed <> -1 Then
		    Var pressed As Integer = mToolbarPressed
		    mToolbarPressed = -1
		    If pressed >= 0 And ToolbarItemAt(x, y) = pressed Then
		      If Not mHasFocus Then Self.SetFocus
		      Var items() As Integer = ToolbarItems
		      ApplyToolbarAction(items(pressed))
		    End If
		    UpdateToolbarHover(x, y)
		    Refresh(False)
		    Return
		  End If
		  
		  If mMouseHandledByApp Then
		    mMouseHandledByApp = False
		    RaiseEvent MouseUp(x, y)
		    Return
		  End If
		  
		  mDraggingScrollbar = False
		  If mMouseSelecting Then
		    // The caret line is frozen while drag-selecting so text does not jump under the mouse
		    mMouseSelecting = False
		    CaretMoved
		  End If
		  
		  // Switch the clicked line to raw only once no further click of a double click can follow
		  If mClickFreeze And mClickTimer <> Nil Then
		    mClickTimer.Period = Max(1, DoubleClickTicks * 1000 / 60)
		    mClickTimer.RunMode = Timer.RunModes.Single
		  End If
		  
		  RaiseEvent MouseUp(x, y)
		End Sub
	#tag EndEvent

	#tag Event
		Function MouseWheel(x As Integer, y As Integer, deltaX As Integer, deltaY As Integer) As Boolean
		  // Returning True from the application's handler stops the editor from scrolling
		  If RaiseEvent MouseWheel(x, y, deltaX, deltaY) Then Return True
		  
		  If mContentHeight <= Height Then Return False
		  mScrollY = mScrollY + deltaY * WheelStep
		  ClampScroll
		  Refresh(False)
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Sub Opening()
		  Self.MouseCursor = System.Cursors.IBeam
		  
		  mBlinkTimer = New Timer
		  mBlinkTimer.Period = kBlinkPeriod
		  mBlinkTimer.RunMode = Timer.RunModes.Multiple
		  AddHandler mBlinkTimer.Action, WeakAddressOf BlinkTimerAction
		  
		  mClickTimer = New Timer
		  mClickTimer.RunMode = Timer.RunModes.Off
		  AddHandler mClickTimer.Action, WeakAddressOf ClickTimerAction
		  
		  mHoverTimer = New Timer
		  mHoverTimer.Period = kHoverPeriod
		  mHoverTimer.RunMode = Timer.RunModes.Off
		  AddHandler mHoverTimer.Action, WeakAddressOf HoverTimerAction
		  
		  RaiseEvent Opening
		End Sub
	#tag EndEvent

	#tag Event
		Sub Paint(g As Graphics, areas() As Rect)
		  // Text is laid out with the Graphics it is drawn with. On Windows a picture can measure text
		  // narrower than the editor draws it (e.g. inside a DesktopContainer), so words overlap and
		  // lose their spaces. A layout made outside Paint is therefore made again here.
		  mPaintGraphics = g
		  If Not mLayoutMeasuredInPaint Then mLayoutDirty = True
		  EnsureLayout
		  
		  g.DrawingColor = EffectiveBackgroundColor
		  g.FillRectangle(0, 0, g.Width, g.Height)
		  
		  If mRows.Count > 0 Then
		    Var scroll As Double = mScrollY
		    Var viewBottom As Double = scroll + Height
		    Var left As Double = kPadding
		    Var right As Double = Width - kPadding - kScrollbarReserve
		    Var firstRow As Integer = RowAtY(scroll)
		    
		    // Block decorations: code backgrounds, quote bars, horizontal rules
		    For i As Integer = mRows(firstRow).Line To mLines.LastIndex
		      If mLineTop(i) > viewBottom Then Exit For
		      DrawLineDecoration(g, i, left, right, mLineTop(i) - scroll)
		    Next
		    
		    // Selection
		    Var sl, sc, el, ec As Integer
		    GetSelection(sl, sc, el, ec)
		    Var selecting As Boolean = sl <> el Or sc <> ec
		    If selecting Then
		      g.DrawingColor = SelectionColor
		      For r As Integer = firstRow To mRows.LastIndex
		        Var row As MDRow = mRows(r)
		        If row.Top > viewBottom Or row.Line > el Then Exit For
		        If row.Line < sl Then Continue
		        
		        // Rendered table rows are highlighted as a whole
		        If IsTableKind(mLineKinds(row.Line)) Then
		          If LineIsSelected(row.Line, sl, sc, el, ec) Then
		            Var tableX, tableWidth As Double
		            TableBounds(mLineTable(row.Line), tableX, tableWidth)
		            g.FillRectangle(left + tableX, row.Top - scroll, tableWidth, row.Height)
		          End If
		          Continue
		        End If
		        
		        Var c1 As Integer = row.StartCol
		        Var c2 As Integer = row.EndCol
		        If row.Line = sl Then c1 = Max(c1, sc)
		        If row.Line = el Then c2 = Min(c2, ec)
		        // The line break of a fully crossed line is shown as a small extra block
		        Var includesBreak As Boolean = r = mLineLastRow(row.Line) And row.Line < el
		        If c1 > c2 Or (c1 = c2 And Not includesBreak) Then Continue
		        
		        Var x1 As Double = left + XForCol(r, c1)
		        Var x2 As Double = left + XForCol(r, c2)
		        If includesBreak Then x2 = x2 + kLineBreakWidth
		        g.FillRectangle(x1, row.Top - scroll, x2 - x1, row.Height)
		      Next
		    End If
		    
		    // Text
		    For r As Integer = firstRow To mRows.LastIndex
		      Var row As MDRow = mRows(r)
		      If row.Top > viewBottom Then Exit For
		      For f As Integer = row.FirstFragment To row.LastFragment
		        Var frag As MDFragment = mFragments(f)
		        If (frag.Flags And kFlagImage) <> 0 Then
		          DrawImage(g, frag, row, left, row.Top - scroll, selecting And FragmentIsSelected(frag, sl, sc, el, ec))
		        ElseIf (frag.Flags And kFlagHidden) = 0 Then
		          DrawFragment(g, frag, row, left, row.Top - scroll)
		        End If
		      Next
		    Next
		    
		    // Caret
		    If mHasFocus And mCaretVisible And Not selecting Then
		      Var cx, cy, ch As Double
		      CaretRect(cx, cy, ch)
		      g.DrawingColor = EffectiveTextColor
		      g.FillRectangle(left + cx, cy - scroll, kCaretWidth, ch)
		    End If
		    
		    // Overlay scroll thumb
		    If mHasVerticalScrollbar And mContentHeight > Height Then
		      Var thumbHeight As Double = ThumbHeight
		      Var thumbY As Double = 2 + (Height - 4 - thumbHeight) * mScrollY / (mContentHeight - Height)
		      g.DrawingColor = Color.RGB(128, 128, 128, 110)
		      g.FillRoundRectangle(Width - 9, thumbY, 6, thumbHeight, 6, 6)
		    End If
		  End If
		  
		  If mHasBorder Then
		    g.DrawingColor = BorderColor
		    g.DrawRectangle(0, 0, g.Width, g.Height)
		  End If
		  
		  // The application can draw on top of the editor
		  RaiseEvent Paint(g, areas)
		  
		  If mToolbarVisible And ToolbarAllowed Then DrawToolbar(g)
		  mPaintGraphics = Nil
		End Sub
	#tag EndEvent


	#tag MenuHandler
		Function EditClear() As Boolean Handles EditClear.Action
		  If HasSelection Then ReplaceSelection("", kEditOther)
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditCopy() As Boolean Handles EditCopy.Action
		  Copy
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditCut() As Boolean Handles EditCut.Action
		  Cut
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditPaste() As Boolean Handles EditPaste.Action
		  Paste
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditSelectAll() As Boolean Handles EditSelectAll.Action
		  SelectAll
		  Return True
		End Function
	#tag EndMenuHandler

	#tag MenuHandler
		Function EditUndo() As Boolean Handles EditUndo.Action
		  Undo
		  Return True
		End Function
	#tag EndMenuHandler


	#tag Method, Flags = &h21
		Private Sub AddFlags(flags() As Integer, start As Integer, length As Integer, value As Integer)
		  For i As Integer = Max(0, start) To Min(flags.LastIndex, start + length - 1)
		    flags(i) = flags(i) Or value
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AddFragment(lineIndex As Integer, startCol As Integer, endCol As Integer, x As Double, width As Double, flags As Integer, scale As Double, dy As Double = 0)
		  Var frag As MDFragment
		  frag.Line = lineIndex
		  frag.StartCol = startCol
		  frag.EndCol = endCol
		  frag.X = x
		  frag.Width = width
		  frag.Flags = flags
		  frag.Scale = scale
		  // Vertical offset inside the row; only table cells wrap onto several lines within one row
		  frag.DY = dy
		  mFragments.Add(frag)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 417070656E647320746578742061742074686520656E64206F662074686520646F63756D656E742E
		Sub AddText(value As String)
		  mAnchorLine = mLines.LastIndex
		  mAnchorCol = mLines(mAnchorLine).Length
		  mCaretLine = mAnchorLine
		  mCaretCol = mAnchorCol
		  ReplaceSelection(value, kEditOther)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AlignCellLine(firstFragment As Integer, freeSpace As Double, align As Integer)
		  // Shifts the fragments of one line inside a table cell for center/right alignment
		  If align = kAlignLeft Or freeSpace <= 0 Then Return
		  Var shift As Double = freeSpace
		  If align = kAlignCenter Then shift = freeSpace / 2
		  For i As Integer = firstFragment To mFragments.LastIndex
		    Var frag As MDFragment = mFragments(i)
		    frag.X = frag.X + shift
		    mFragments(i) = frag
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AlignRows(g As Graphics, lineIndex As Integer, maxWidth As Double)
		  // TextAlignment: moves each row of a laid-out line to the center or the right edge.
		  // The spaces a row ends with (where it wrapped) don't count, so the visible text lines up.
		  If mTextAlignment <> TextAlignments.Center And mTextAlignment <> TextAlignments.Right Then Return
		  Var line As String = mLines(lineIndex)
		  
		  For r As Integer = mLineFirstRow(lineIndex) To mLineLastRow(lineIndex)
		    Var row As MDRow = mRows(r)
		    Var right As Double = row.StartX
		    For f As Integer = row.FirstFragment To row.LastFragment
		      Var frag As MDFragment = mFragments(f)
		      If (frag.Flags And kFlagHidden) <> 0 Then Continue
		      right = frag.X + frag.Width
		      // Leave out trailing spaces of a text fragment
		      If (frag.Flags And kSymbolFlags) = 0 And frag.EndCol > frag.StartCol Then
		        Var piece As String = line.Middle(frag.StartCol, frag.EndCol - frag.StartCol)
		        Var trimmed As String = piece.TrimRight
		        If trimmed.Length < piece.Length Then
		          ApplyFont(g, frag.Flags, frag.Scale)
		          right = frag.X + g.TextWidth(trimmed)
		        End If
		      End If
		    Next
		    
		    Var shift As Double = maxWidth - right
		    If mTextAlignment = TextAlignments.Center Then shift = shift / 2
		    If shift <= 0 Then Continue
		    
		    row.StartX = row.StartX + shift
		    mRows(r) = row
		    For f As Integer = row.FirstFragment To row.LastFragment
		      Var frag As MDFragment = mFragments(f)
		      frag.X = frag.X + shift
		      mFragments(f) = frag
		    Next
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AnalyzeBlocks()
		  // Marks fenced code blocks: the fence lines themselves and the lines between them
		  mBlockKinds.ResizeTo(mLines.LastIndex)
		  Var inFence As Boolean
		  For i As Integer = 0 To mLines.LastIndex
		    Var trimmed As String = mLines(i).TrimLeft
		    If trimmed.BeginsWith("```") Or trimmed.BeginsWith("~~~") Then
		      mBlockKinds(i) = kKindFence
		      inFence = Not inFence
		    ElseIf inFence Then
		      mBlockKinds(i) = kKindCode
		    Else
		      mBlockKinds(i) = kKindNormal
		    End If
		  Next
		  
		  AnalyzeTables
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub AnalyzeTables()
		  // A table is a header line, a delimiter line like |---|:--:| and the "|" lines below it
		  Var lastLine As Integer = mLines.LastIndex
		  mLineTable.ResizeTo(lastLine)
		  For i As Integer = 0 To lastLine
		    mLineTable(i) = -1
		  Next
		  mTableStart.ResizeTo(-1)
		  mTableEnd.ResizeTo(-1)
		  mTableFirstColumn.ResizeTo(-1)
		  mTableColumnCount.ResizeTo(-1)
		  mTableAlign.ResizeTo(-1)
		  mTableColumnX.ResizeTo(-1)
		  mTableColumnW.ResizeTo(-1)
		  
		  Var i As Integer = 0
		  While i < lastLine
		    If mBlockKinds(i) = kKindNormal And mBlockKinds(i + 1) = kKindNormal And mLines(i).IndexOf("|") >= 0 Then
		      Var aligns() As Integer
		      Var starts() As Integer
		      Var ends() As Integer
		      SplitTableCells(mLines(i), starts, ends)
		      If ParseTableDelimiter(mLines(i + 1), aligns) And starts.Count = aligns.Count Then
		        Var table As Integer = mTableStart.Count
		        mTableStart.Add(i)
		        mTableFirstColumn.Add(mTableAlign.Count)
		        mTableColumnCount.Add(aligns.Count)
		        For Each align As Integer In aligns
		          mTableAlign.Add(align)
		          mTableColumnX.Add(0)
		          mTableColumnW.Add(0)
		        Next
		        
		        mBlockKinds(i) = kKindTableHeader
		        mLineTable(i) = table
		        mBlockKinds(i + 1) = kKindTableDelimiter
		        mLineTable(i + 1) = table
		        Var j As Integer = i + 2
		        While j <= lastLine And mBlockKinds(j) = kKindNormal And mLines(j).IndexOf("|") >= 0
		          mBlockKinds(j) = kKindTableRow
		          mLineTable(j) = table
		          j = j + 1
		        Wend
		        mTableEnd.Add(j - 1)
		        i = j
		        Continue
		      End If
		    End If
		    i = i + 1
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyCodeBlock()
		  // Fences the selected lines, or inserts an empty code block
		  If mReadOnly Then Return
		  If Not HasSelection Then
		    InsertBlock("```" + Chr(10) + Chr(10) + "```", 1, 0, 0)
		    Return
		  End If
		  
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  If el > sl And ec = 0 Then el = el - 1
		  Var lines() As String
		  For i As Integer = sl To el
		    lines.Add(mLines(i))
		  Next
		  SelectRange(sl, 0, el, mLines(el).Length)
		  ReplaceSelection("```" + Chr(10) + String.FromArray(lines, Chr(10)) + Chr(10) + "```", kEditOther)
		  SelectRange(sl + 1, 0, el + 1, mLines(el + 1).Length)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyEmphasisFlags(line As String, flags() As Integer, consumed() As Boolean, offset As Integer, pattern As String, styleFlags As Integer)
		  // Group 1 of the pattern must capture the opening marker; the closing marker has the same length.
		  Var rx As RegEx = CachedRegEx(pattern)
		  Var match As RegExMatch = rx.Search(line)
		  
		  While match <> Nil
		    Var s As Integer = MatchStart(match, line, 0)
		    Var total As Integer = match.SubExpressionString(0).Length
		    Var markerLength As Integer = match.SubExpressionString(1).Length
		    Var closeStart As Integer = s + total - markerLength
		    
		    If s >= offset And RangeIsFree(consumed, s, markerLength) And RangeIsFree(consumed, closeStart, markerLength) Then
		      AddFlags(flags, s, markerLength, kFlagHidden)
		      AddFlags(flags, closeStart, markerLength, kFlagHidden)
		      AddFlags(flags, s + markerLength, total - (2 * markerLength), styleFlags)
		      MarkConsumed(consumed, s, markerLength)
		      MarkConsumed(consumed, closeStart, markerLength)
		    End If
		    
		    match = rx.Search
		  Wend
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyFont(g As Graphics, flags As Integer, scale As Double)
		  If (flags And kFlagCode) <> 0 Then
		    g.FontName = CodeFontName
		    g.FontSize = BaseFontSize * scale * kCodeFontScale
		  Else
		    g.FontName = mFontName
		    g.FontSize = BaseFontSize * scale
		  End If
		  g.Bold = mBold Or (flags And kFlagBold) <> 0
		  g.Italic = mItalic Or (flags And kFlagItalic) <> 0
		  g.Underline = mUnderline
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyInlineFlags(line As String, flags() As Integer, offset As Integer)
		  // Inline Markdown: code spans, links, bold, italic and strikethrough, starting at offset
		  Var n As Integer = line.Length
		  If n <= offset Then Return
		  
		  // Characters already claimed by a code span or a hidden marker
		  Var consumed() As Boolean
		  consumed.ResizeTo(n - 1)
		  
		  Var rx As RegEx
		  Var match As RegExMatch
		  
		  // Code spans: `code`
		  rx = CachedRegEx("(`+)(.+?)\1")
		  match = rx.Search(line)
		  While match <> Nil
		    Var s As Integer = MatchStart(match, line, 0)
		    Var total As Integer = match.SubExpressionString(0).Length
		    If s >= offset And RangeIsFree(consumed, s, total) Then
		      Var markerLength As Integer = match.SubExpressionString(1).Length
		      AddFlags(flags, s, markerLength, kFlagHidden)
		      AddFlags(flags, s + total - markerLength, markerLength, kFlagHidden)
		      AddFlags(flags, s + markerLength, total - (2 * markerLength), kFlagCode)
		      MarkConsumed(consumed, s, total)
		    End If
		    match = rx.Search
		  Wend
		  
		  // Links and images: [text](url) / ![alt](url)
		  rx = CachedRegEx("(!?\[)([^\]]+)\]\(([^)\s]*)\)")
		  match = rx.Search(line)
		  While match <> Nil
		    Var s As Integer = MatchStart(match, line, 0)
		    Var total As Integer = match.SubExpressionString(0).Length
		    If s >= offset And RangeIsFree(consumed, s, total) Then
		      Var prefixLength As Integer = match.SubExpressionString(1).Length
		      Var textLength As Integer = match.SubExpressionString(2).Length
		      Var tailStart As Integer = s + prefixLength + textLength
		      Var tailLength As Integer = total - prefixLength - textLength
		      AddFlags(flags, s, prefixLength, kFlagHidden)
		      AddFlags(flags, tailStart, tailLength, kFlagHidden)
		      AddFlags(flags, s + prefixLength, textLength, kFlagLink)
		      MarkConsumed(consumed, s, prefixLength)
		      MarkConsumed(consumed, tailStart, tailLength)
		    End If
		    match = rx.Search
		  Wend
		  
		  // Emphasis, longest markers first so ***x*** is not mistaken for **x** or *x*
		  ApplyEmphasisFlags(line, flags, consumed, offset, "(\*\*\*|___)(?=\S)(.+?)(?<=\S)\1", kFlagBold Or kFlagItalic)
		  ApplyEmphasisFlags(line, flags, consumed, offset, "(\*\*|__)(?=\S)(.+?)(?<=\S)\1", kFlagBold)
		  ApplyEmphasisFlags(line, flags, consumed, offset, "(?<!\*)(\*)(?![\s\*])(.+?)(?<![\s\*])\*(?!\*)", kFlagItalic)
		  ApplyEmphasisFlags(line, flags, consumed, offset, "(?<![_\w])(_)(?![\s_])(.+?)(?<![\s_])_(?![_\w])", kFlagItalic)
		  ApplyEmphasisFlags(line, flags, consumed, offset, "(~~)(?=\S)(.+?)(?<=\S)~~", kFlagStrike)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyLinePrefix(action As Integer)
		  // Headings, lists and quotes for every selected line. Applying the same format again removes it.
		  If mReadOnly Then Return
		  Var hadSelection As Boolean = HasSelection
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  If el > sl And ec = 0 Then el = el - 1
		  
		  Var removing As Boolean = True
		  For i As Integer = sl To el
		    If LinePrefixKind(mLines(i)) <> action Then
		      removing = False
		      Exit For
		    End If
		  Next
		  
		  Var rx As RegEx = CachedRegEx(LinePrefixPattern)
		  Var newLines() As String
		  Var number As Integer = 1
		  // The selection stays on the same text; it only moves along with the changed prefix
		  Var anchorLine As Integer = mAnchorLine
		  Var anchorCol As Integer = mAnchorCol
		  Var caretLine As Integer = mCaretLine
		  Var caretCol As Integer = mCaretCol
		  For i As Integer = sl To el
		    Var line As String = mLines(i)
		    Var match As RegExMatch = rx.Search(line)
		    Var indent As String = match.SubExpressionString(1)
		    Var oldPrefixLength As Integer = match.SubExpressionString(0).Length
		    Var prefix As String
		    If Not removing Then
		      prefix = PrefixForAction(action, number)
		      number = number + 1
		    End If
		    newLines.Add(indent + prefix + line.Middle(oldPrefixLength))
		    Var newPrefixEnd As Integer = indent.Length + prefix.Length
		    If i = anchorLine Then anchorCol = newPrefixEnd + Max(0, anchorCol - oldPrefixLength)
		    If i = caretLine Then caretCol = newPrefixEnd + Max(0, caretCol - oldPrefixLength)
		  Next
		  
		  SelectRange(sl, 0, el, mLines(el).Length)
		  ReplaceSelection(String.FromArray(newLines, Chr(10)), kEditOther)
		  If hadSelection Then
		    SelectRange(anchorLine, anchorCol, caretLine, caretCol)
		  Else
		    MoveCaret(caretLine, caretCol, False)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ApplyToolbarAction(action As Integer)
		  If action = kToolPlainText Then
		    RenderMarkdown = Not mRenderMarkdown
		    // The button's tooltip names the other view now
		    If mToolbarTooltipActive Then Self.Tooltip = ToolbarTooltip(kToolPlainText)
		    Return
		  End If
		  If mReadOnly Then Return
		  Select Case action
		  Case kToolBold
		    ToggleInlineMarker("**")
		  Case kToolItalic
		    ToggleInlineMarker("*")
		  Case kToolStrike
		    ToggleInlineMarker("~~")
		  Case kToolCode
		    ToggleInlineMarker("`")
		  Case kToolH1, kToolH2, kToolH3, kToolBullet, kToolNumbered, kToolTask, kToolQuote
		    ApplyLinePrefix(action)
		  Case kToolLink
		    InsertLink
		  Case kToolImage
		    InsertLink(True)
		  Case kToolCodeBlock
		    ApplyCodeBlock
		  Case kToolTable
		    Var table() As String
		    table.Add("| Column 1 | Column 2 | Column 3 |")
		    table.Add("|----------|----------|----------|")
		    table.Add("| Cell     | Cell     | Cell     |")
		    InsertBlock(String.FromArray(table, Chr(10)), 0, 2, 8)
		  Case kToolRule
		    InsertBlock("---" + Chr(10), 1, 0, 0)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseFontSize() As Double
		  If mFontSize > 0 Then Return mFontSize
		  
		  // A FontSize of 0 means "system default"; headings need a concrete size to scale from.
		  #If TargetMacOS Then
		    Return 13
		  #Else
		    Return 12
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function BaseRowHeight() As Double
		  Var g As Graphics = MeasureGraphics
		  ApplyFont(g, 0, 1.0)
		  Return Ceiling(g.TextHeight * mLineSpacing)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub BlinkTimerAction(sender As Timer)
		  #Pragma Unused sender
		  If Not mHasFocus Then Return
		  
		  mCaretVisible = Not mCaretVisible
		  Var x, y, h As Double
		  CaretRect(x, y, h)
		  Refresh(Floor(kPadding + x) - 2, Floor(y - mScrollY) - 1, 6, Ceiling(h) + 2, False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CachedRegEx(pattern As String) As RegEx
		  If mRegExCache = Nil Then mRegExCache = New Dictionary
		  If mRegExCache.HasKey(pattern) Then Return mRegExCache.Value(pattern)
		  
		  Var rx As New RegEx
		  rx.SearchPattern = pattern
		  mRegExCache.Value(pattern) = rx
		  Return rx
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CaretMoved()
		  UpdateCurrentLine
		  EnsureCaretVisible
		  ResetBlink
		  Refresh(False)
		  NotifySelectionChanged
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub CaretRect(ByRef x As Double, ByRef y As Double, ByRef h As Double)
		  // Caret position in document coordinates (x relative to the content's left edge)
		  EnsureLayout
		  Var r As Integer = RowForPosition(mCaretLine, mCaretCol)
		  Var row As MDRow = mRows(r)
		  x = XForCol(r, mCaretCol)
		  y = row.Top + 2
		  h = row.Height - 4
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636861726163746572206F6666736574206E65617265737420746F2074686520676976656E20706F696E742E
		Function CharacterPosition(x As Double, y As Double) As Integer
		  Var lineIndex, col As Integer
		  PositionFromPoint(x, y, lineIndex, col)
		  Return OffsetOf(lineIndex, col)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636861726163746572206F6666736574206F662074686520666972737420636861726163746572206F662074686520676976656E206C696E65206F66207468652072617720746578742E
		Function CharacterPosition(lineNumber As Integer) As Integer
		  // Lines are the lines of the raw Markdown text, not wrapped rows
		  Var lineIndex As Integer = Max(0, Min(lineNumber, mLines.LastIndex))
		  Return OffsetOf(lineIndex, 0)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ClampScroll()
		  mScrollY = Max(0, Min(mScrollY, mContentHeight - Height))
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ClickTimerAction(sender As Timer)
		  #Pragma Unused sender
		  // A click is complete once the button is up; a held button means a drag is still going on
		  If mMouseSelecting Then Return
		  EndClickFreeze
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function CodeFontName() As String
		  #If TargetMacOS Then
		    Return "Menlo"
		  #ElseIf TargetWindows Then
		    Return "Consolas"
		  #Else
		    Return "Monospace"
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ColForX(rowIndex As Integer, x As Double, yInRow As Double = -1) As Integer
		  // Column on the given row closest to x (relative to the content's left edge).
		  // yInRow picks the line inside a table cell that wraps; -1 ignores it.
		  Var row As MDRow = mRows(rowIndex)
		  Var g As Graphics = MeasureGraphics
		  Var isTable As Boolean = IsTableKind(mLineKinds(row.Line))
		  Var y As Double = Max(kCellPaddingV, Min(yInRow, row.Height - kCellPaddingV - 1))
		  
		  For f As Integer = row.FirstFragment To row.LastFragment
		    Var frag As MDFragment = mFragments(f)
		    If isTable And yInRow >= 0 And (y < frag.DY Or y >= frag.DY + row.SubHeight) Then Continue
		    If x >= frag.X + frag.Width Then Continue
		    
		    If (frag.Flags And kFlagHidden) <> 0 Then Return frag.StartCol
		    If (frag.Flags And kSymbolFlags) <> 0 Then
		      If x < frag.X + frag.Width / 2 Then Return frag.StartCol
		      Return frag.EndCol
		    End If
		    
		    ApplyFont(g, frag.Flags, frag.Scale)
		    Var line As String = mLines(frag.Line)
		    Var previous As Double
		    For k As Integer = 1 To frag.EndCol - frag.StartCol
		      Var w As Double = g.TextWidth(line.Middle(frag.StartCol, k))
		      If x < frag.X + (previous + w) / 2 Then Return frag.StartCol + k - 1
		      previous = w
		    Next
		    Return frag.EndCol
		  Next
		  
		  // Past the end of the row. A wrapped row ends with the space that caused the wrap;
		  // stop before it so the caret stays on this row.
		  If rowIndex < mLineLastRow(row.Line) And row.EndCol > row.StartCol Then Return row.EndCol - 1
		  Return row.EndCol
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ColorForFlags(flags As Integer) As Color
		  If (flags And kFlagOnAccent) <> 0 Then Return &cFFFFFF
		  If (flags And kFlagLink) <> 0 Then Return AccentColor
		  If (flags And kFlagCode) <> 0 Then Return CodeColor
		  If (flags And kFlagMuted) <> 0 Then Return MutedColor
		  If (flags And kFlagAccent) <> 0 Then Return AccentColor
		  Return EffectiveTextColor
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ComparePositions(line1 As Integer, col1 As Integer, line2 As Integer, col2 As Integer) As Integer
		  If line1 <> line2 Then Return If(line1 < line2, -1, 1)
		  If col1 <> col2 Then Return If(col1 < col2, -1, 1)
		  Return 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ComputeTableColumns(g As Graphics, table As Integer, maxWidth As Double)
		  // Natural column widths from the widest cell, shrunk to fit the editor when necessary
		  Var first As Integer = mTableFirstColumn(table)
		  Var count As Integer = mTableColumnCount(table)
		  Var widths() As Double
		  widths.ResizeTo(count - 1)
		  
		  For lineIndex As Integer = mTableStart(table) To mTableEnd(table)
		    If mBlockKinds(lineIndex) = kKindTableDelimiter Then Continue
		    Var flags() As Integer
		    flags.ResizeTo(mLines(lineIndex).Length - 1)
		    TableLineFlags(lineIndex, flags)
		    Var starts() As Integer
		    Var ends() As Integer
		    SplitTableCells(mLines(lineIndex), starts, ends)
		    For c As Integer = 0 To Min(count, starts.Count) - 1
		      widths(c) = Max(widths(c), MeasureRange(g, lineIndex, flags, starts(c), ends(c)))
		    Next
		  Next
		  
		  Var total As Double
		  For c As Integer = 0 To count - 1
		    widths(c) = Max(kMinimumColumnWidth, Ceiling(widths(c)) + (2 * kCellPadding))
		    total = total + widths(c)
		  Next
		  
		  If total > maxWidth Then
		    // Narrow columns keep their width; the wide ones share the rest in proportion to their size
		    Var fair As Double = maxWidth / count
		    Var fixedTotal, flexTotal As Double
		    For c As Integer = 0 To count - 1
		      If widths(c) <= fair Then
		        fixedTotal = fixedTotal + widths(c)
		      Else
		        flexTotal = flexTotal + widths(c)
		      End If
		    Next
		    Var flexSpace As Double = Max(0, maxWidth - fixedTotal)
		    For c As Integer = 0 To count - 1
		      If widths(c) > fair Then widths(c) = Max(kMinimumColumnWidth, Floor(widths(c) * flexSpace / flexTotal))
		    Next
		  ElseIf mTableFullWidth And total < maxWidth Then
		    // TableFullWidth: the columns share the spare room in proportion to their size;
		    // the last one takes what rounding leaves, so the table ends exactly at the right edge
		    Var used As Double
		    For c As Integer = 0 To count - 2
		      widths(c) = Floor(widths(c) * maxWidth / total)
		      used = used + widths(c)
		    Next
		    widths(count - 1) = Floor(maxWidth) - used
		  End If
		  
		  // Tables narrower than the editor are placed according to TableAlignment
		  Var tableWidth As Double
		  For c As Integer = 0 To count - 1
		    tableWidth = tableWidth + widths(c)
		  Next
		  Var x As Double = 0
		  Select Case mTableAlignment
		  Case TableAlignments.Center
		    x = Max(0, Floor((maxWidth - tableWidth) / 2))
		  Case TableAlignments.Right
		    x = Max(0, maxWidth - tableWidth)
		  End Select
		  
		  For c As Integer = 0 To count - 1
		    mTableColumnX(first + c) = x
		    mTableColumnW(first + c) = widths(c)
		    x = x + widths(c)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 4372656174657320616E20656D707479204D61726B646F776E417265612E
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  // The document always has at least one (empty) line
		  mLines.Add("")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ContentWidth() As Double
		  If mPrintWidth > 0 Then Return mPrintWidth
		  Return Width - (2 * kPadding) - kScrollbarReserve
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 436F70696573207468652073656C656374656420726177204D61726B646F776E207465787420746F2074686520636C6970626F6172642E
		Sub Copy()
		  If Not HasSelection Then Return
		  
		  Var board As New Clipboard
		  board.Text = SelectedText
		  board.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 436F70696573207468652073656C656374656420726177204D61726B646F776E207465787420746F2074686520636C6970626F61726420616E642072656D6F7665732069742E20446F6573206E6F7468696E67207768696C6520526561644F6E6C7920697320547275652E
		Sub Cut()
		  If Not HasSelection Or mReadOnly Then Return
		  Copy
		  ReplaceSelection("", kEditOther)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DeleteBackward(byWord As Boolean, toRowStart As Boolean)
		  If mReadOnly Then Return
		  
		  If Not HasSelection Then
		    Var lineIndex As Integer = mCaretLine
		    Var col As Integer = mCaretCol
		    If toRowStart Then
		      EnsureLayout
		      col = mRows(RowForPosition(mCaretLine, mCaretCol)).StartCol
		      If col = mCaretCol Then StepPosition(-1, False, lineIndex, col)
		    Else
		      StepPosition(-1, byWord, lineIndex, col)
		    End If
		    If lineIndex = mCaretLine And col = mCaretCol Then Return
		    mAnchorLine = lineIndex
		    mAnchorCol = col
		  End If
		  
		  ReplaceSelection("", kEditDelete)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DeleteForward(byWord As Boolean)
		  If mReadOnly Then Return
		  
		  If Not HasSelection Then
		    Var lineIndex As Integer = mCaretLine
		    Var col As Integer = mCaretCol
		    StepPosition(1, byWord, lineIndex, col)
		    If lineIndex = mCaretLine And col = mCaretCol Then Return
		    mAnchorLine = lineIndex
		    mAnchorCol = col
		  End If
		  
		  ReplaceSelection("", kEditDelete)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function DoubleClickTicks() As Integer
		  // The user's double-click speed, in ticks (1/60 s)
		  If mDoubleClickTicks > 0 Then Return mDoubleClickTicks
		  
		  #If TargetMacOS Then
		    // NSEvent.doubleClickInterval holds the system setting in seconds
		    Declare Function NSClassFromString Lib "Foundation" (className As CFStringRef) As Ptr
		    Declare Function doubleClickInterval Lib "AppKit" Selector "doubleClickInterval" (classRef As Ptr) As Double
		    mDoubleClickTicks = Round(doubleClickInterval(NSClassFromString("NSEvent")) * 60)
		  #ElseIf TargetWindows Then
		    // GetDoubleClickTime returns the system setting in milliseconds
		    Declare Function GetDoubleClickTime Lib "User32" () As UInt32
		    mDoubleClickTicks = Round(GetDoubleClickTime * 60 / 1000)
		  #EndIf
		  
		  If mDoubleClickTicks <= 0 Then mDoubleClickTicks = kDoubleClickTicks
		  Return mDoubleClickTicks
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawCenteredText(g As Graphics, value As String, cx As Double, cy As Double, fontName As String, size As Double, isBold As Boolean, isItalic As Boolean)
		  g.FontName = fontName
		  g.FontSize = size
		  g.Bold = isBold
		  g.Italic = isItalic
		  g.Underline = False
		  g.DrawText(value, cx - g.TextWidth(value) / 2, cy + g.FontAscent / 2 - 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawFragment(g As Graphics, frag As MDFragment, row As MDRow, left As Double, rowTop As Double)
		  Var x As Double = left + frag.X
		  Var baseline As Double = rowTop + frag.DY + row.Baseline
		  ApplyFont(g, frag.Flags, frag.Scale)
		  
		  If (frag.Flags And kFlagBullet) <> 0 Then
		    g.DrawingColor = AccentColor
		    g.DrawText("•", x, baseline)
		    Return
		  End If
		  
		  If (frag.Flags And (kFlagTaskOpen Or kFlagTaskDone)) <> 0 Then
		    Var size As Double = Round(g.FontAscent * 0.9)
		    Var boxY As Double = baseline - size + 1
		    g.DrawingColor = AccentColor
		    If (frag.Flags And kFlagTaskDone) <> 0 Then
		      g.FillRoundRectangle(x, boxY, size, size, 4, 4)
		      g.DrawingColor = EffectiveBackgroundColor
		      g.PenSize = 1.5
		      g.DrawLine(x + size * 0.25, boxY + size * 0.52, x + size * 0.43, boxY + size * 0.72)
		      g.DrawLine(x + size * 0.43, boxY + size * 0.72, x + size * 0.77, boxY + size * 0.3)
		      g.PenSize = 1
		    Else
		      g.DrawRoundRectangle(x, boxY, size, size, 4, 4)
		    End If
		    Return
		  End If
		  
		  // Inline code gets its own background; code blocks already have one
		  Var kind As Integer = mLineKinds(frag.Line)
		  If (frag.Flags And kFlagCode) <> 0 And (frag.Flags And kFlagOnAccent) = 0 And kind <> kKindCode And kind <> kKindFence Then
		    g.DrawingColor = CodeBackgroundColor
		    g.FillRectangle(x, rowTop + frag.DY + (row.SubHeight - g.TextHeight) / 2, frag.Width, g.TextHeight)
		  End If
		  
		  Var color As Color = ColorForFlags(frag.Flags)
		  g.DrawingColor = color
		  g.DrawText(mLines(frag.Line).Middle(frag.StartCol, frag.EndCol - frag.StartCol), x, baseline)
		  
		  If (frag.Flags And kFlagLink) <> 0 Then
		    g.FillRectangle(x, baseline + 2, frag.Width, 1)
		  End If
		  If (frag.Flags And kFlagStrike) <> 0 Then
		    g.FillRectangle(x, baseline - Round(g.FontAscent * 0.32), frag.Width, 1)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawImage(g As Graphics, frag As MDFragment, row As MDRow, left As Double, rowTop As Double, selected As Boolean)
		  Var picture As Picture = mLineImages(frag.Line)
		  If picture = Nil Then Return
		  
		  Var x As Double = left + frag.X
		  Var y As Double = rowTop + kImageMargin
		  Var h As Double = row.Height - (2 * kImageMargin)
		  g.DrawPicture(picture, x, y, frag.Width, h, 0, 0, picture.Width, picture.Height)
		  
		  // Pictures would hide the selection drawn underneath, so tint them instead
		  If selected Then
		    Var tint As Color = SelectionColor
		    g.DrawingColor = Color.RGB(tint.Red, tint.Green, tint.Blue, 110)
		    g.FillRectangle(x, y, frag.Width, h)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawLineDecoration(g As Graphics, lineIndex As Integer, left As Double, right As Double, y As Double)
		  // Block decorations: code backgrounds, quote bars, horizontal rules and table chrome
		  Var h As Double = mLineBottom(lineIndex) - mLineTop(lineIndex)
		  Select Case mLineKinds(lineIndex)
		  Case kKindCode, kKindFence
		    g.DrawingColor = CodeBackgroundColor
		    g.FillRectangle(left, y, right - left, h)
		  Case kKindQuote
		    g.DrawingColor = MutedColor
		    g.FillRectangle(left + 2, y, 3, h)
		  Case kKindRule
		    g.DrawingColor = MutedColor
		    g.FillRectangle(left, Round(y + h / 2), right - left, 1)
		  Case kKindTableHeader, kKindTableRow
		    DrawTableRowChrome(g, lineIndex, left, y, h)
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawTableRowChrome(g As Graphics, lineIndex As Integer, left As Double, y As Double, h As Double)
		  // Header background, zebra stripes and cell borders of one rendered table row
		  Var table As Integer = mLineTable(lineIndex)
		  Var first As Integer = mTableFirstColumn(table)
		  Var count As Integer = mTableColumnCount(table)
		  Var tableX, tableWidth As Double
		  TableBounds(table, tableX, tableWidth)
		  tableX = left + tableX
		  Var isHeader As Boolean = mLineKinds(lineIndex) = kKindTableHeader
		  
		  If isHeader Then
		    g.DrawingColor = TableHeaderColor
		    g.FillRectangle(tableX, y, tableWidth, h)
		  ElseIf (lineIndex - mTableStart(table)) Mod 2 = 1 Then
		    // Every second body row gets a subtle stripe
		    g.DrawingColor = TableStripeColor
		    g.FillRectangle(tableX, y, tableWidth, h)
		  End If
		  
		  If isHeader Then
		    g.DrawingColor = TableHeaderBorderColor
		  Else
		    g.DrawingColor = TableBorderColor
		  End If
		  For c As Integer = 1 To count - 1
		    g.FillRectangle(left + mTableColumnX(first + c), y, 1, h)
		  Next
		  
		  g.DrawingColor = TableBorderColor
		  g.FillRectangle(tableX, y, 1, h)
		  g.FillRectangle(tableX + tableWidth - 1, y, 1, h)
		  // Each row draws its bottom edge; a top edge is only needed where no rendered row sits above,
		  // e.g. below the raw caret line (the collapsed |---| line counts as part of the header)
		  Var above As Integer = lineIndex - 1
		  If above >= 0 And mLineKinds(above) = kKindTableDelimiter Then above = above - 1
		  If isHeader Or above < 0 Or Not IsTableKind(mLineKinds(above)) Then g.FillRectangle(tableX, y, tableWidth, 1)
		  g.FillRectangle(tableX, y + h - 1, tableWidth, 1)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawToolbar(g As Graphics)
		  // A floating bar centered at the top of the editor
		  LayoutToolbar
		  If mToolbarVisibleCount = 0 Then Return
		  If mReadOnly Then
		    DrawViewButton(g)
		    Return
		  End If
		  
		  Var top As Double = kToolbarMargin
		  Var left As Double = mToolbarLeft
		  Var w As Double = mToolbarWidth
		  Var h As Double = kToolbarHeight
		  
		  // Soft shadow, body and outline
		  g.DrawingColor = Color.RGB(0, 0, 0, 225)
		  g.FillRoundRectangle(left, top + 2, w, h, 12, 12)
		  g.DrawingColor = ToolbarBackgroundColor
		  g.FillRoundRectangle(left, top, w, h, 12, 12)
		  g.DrawingColor = TableBorderColor
		  g.DrawRoundRectangle(left, top, w, h, 12, 12)
		  
		  Var items() As Integer = ToolbarItems
		  For i As Integer = 0 To mToolbarVisibleCount - 1
		    Var x As Double = mToolbarX(i)
		    If items(i) < 0 Then
		      g.DrawingColor = TableBorderColor
		      g.FillRectangle(x + (kToolbarSeparatorWidth / 2), top + 8, 1, h - 16)
		      Continue
		    End If
		    
		    If i = mToolbarHoverItem Then
		      If i = mToolbarPressed Then
		        g.DrawingColor = ToolbarPressedColor
		      Else
		        g.DrawingColor = ToolbarHoverColor
		      End If
		      g.FillRoundRectangle(x, top + 3, kToolbarButtonWidth, h - 6, 7, 7)
		    End If
		    DrawToolbarIcon(g, items(i), x + kToolbarButtonWidth / 2, top + h / 2)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawToolbarIcon(g As Graphics, action As Integer, cx As Double, cy As Double)
		  Var ink As Color = EffectiveTextColor
		  g.DrawingColor = ink
		  g.PenSize = 1.5
		  
		  Select Case action
		  Case kToolBold
		    DrawCenteredText(g, "B", cx, cy, "System", 15, True, False)
		  Case kToolItalic
		    DrawCenteredText(g, "I", cx, cy, "Georgia", 16, False, True)
		  Case kToolStrike
		    DrawCenteredText(g, "S", cx, cy, "System", 15, False, False)
		    g.FillRectangle(cx - 6, cy - 0.5, 12, 1.5)
		  Case kToolCode
		    DrawCenteredText(g, "</>", cx, cy, CodeFontName, 10, True, False)
		  Case kToolH1
		    DrawCenteredText(g, "H1", cx, cy, "System", 12, True, False)
		  Case kToolH2
		    DrawCenteredText(g, "H2", cx, cy, "System", 12, True, False)
		  Case kToolH3
		    DrawCenteredText(g, "H3", cx, cy, "System", 12, True, False)
		  Case kToolBullet
		    For r As Integer = -1 To 1
		      g.FillOval(cx - 8, cy + r * 4.5 - 1.5, 3, 3)
		      g.FillRectangle(cx - 3, cy + r * 4.5 - 0.75, 11, 1.5)
		    Next
		  Case kToolNumbered
		    For r As Integer = -1 To 1
		      DrawCenteredText(g, Str(r + 2), cx - 6, cy + r * 5, "System", 6.5, True, False)
		      g.FillRectangle(cx - 2.5, cy + r * 5 - 0.75, 10.5, 1.5)
		    Next
		  Case kToolTask
		    g.DrawRoundRectangle(cx - 6.5, cy - 6.5, 13, 13, 4, 4)
		    g.DrawLine(cx - 3.5, cy, cx - 1, cy + 2.5)
		    g.DrawLine(cx - 1, cy + 2.5, cx + 3.5, cy - 2.5)
		  Case kToolQuote
		    g.FillRectangle(cx - 8, cy - 6, 2, 12)
		    g.FillRectangle(cx - 3, cy - 4.5, 11, 1.5)
		    g.FillRectangle(cx - 3, cy - 0.75, 8, 1.5)
		    g.FillRectangle(cx - 3, cy + 3, 11, 1.5)
		  Case kToolLink
		    g.DrawRoundRectangle(cx - 8.5, cy - 3.5, 10, 7, 7, 7)
		    g.DrawRoundRectangle(cx - 1.5, cy - 3.5, 10, 7, 7, 7)
		  Case kToolImage
		    // A framed landscape: a sun over a mountain
		    g.PenSize = 1.25
		    g.DrawRoundRectangle(cx - 8, cy - 6, 16, 12, 3, 3)
		    g.FillOval(cx + 1.5, cy - 4, 3.5, 3.5)
		    Var mountain As New GraphicsPath
		    mountain.MoveToPoint(cx - 6, cy + 4)
		    mountain.AddLineToPoint(cx - 2, cy - 1.5)
		    mountain.AddLineToPoint(cx + 1, cy + 2)
		    mountain.AddLineToPoint(cx + 3, cy)
		    mountain.AddLineToPoint(cx + 6, cy + 4)
		    g.FillPath(mountain, True)
		  Case kToolCodeBlock
		    DrawCenteredText(g, "{ }", cx, cy, CodeFontName, 11, True, False)
		  Case kToolTable
		    g.DrawingColor = TableHeaderColor
		    g.FillRectangle(cx - 7.5, cy - 6, 15, 4)
		    g.DrawingColor = ink
		    g.PenSize = 1
		    g.DrawRectangle(cx - 7.5, cy - 6, 15, 12)
		    g.FillRectangle(cx - 7.5, cy - 2, 15, 1)
		    g.FillRectangle(cx - 7.5, cy + 2, 15, 1)
		    g.FillRectangle(cx - 0.5, cy - 6, 1, 12)
		  Case kToolPlainText
		    DrawViewIcon(g, cx, cy)
		  Case kToolRule
		    g.FillRectangle(cx - 8, cy - 0.75, 16, 1.5)
		    g.FillRectangle(cx - 8, cy - 5, 1.5, 3)
		    g.FillRectangle(cx + 6.5, cy - 5, 1.5, 3)
		  End Select
		  
		  g.PenSize = 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawViewButton(g As Graphics)
		  // The read-only view toggle: a compact button, outlined and with a soft shadow so it stands out over the text.
		  // Its icon shows the current view: M and an eye for rendered Markdown, T and an eye for plain text.
		  Var x As Double = mToolbarX(0)
		  Var y As Double = kToolbarMargin
		  Var w As Double = kViewButtonWidth
		  Var h As Double = kViewButtonHeight
		  
		  g.DrawingColor = Color.RGB(0, 0, 0, 215)
		  g.FillRoundRectangle(x, y + 1.5, w, h, 7, 7)
		  
		  If mToolbarHoverItem = 0 And mToolbarPressed = 0 Then
		    g.DrawingColor = ToolbarPressedColor
		  ElseIf mToolbarHoverItem = 0 Then
		    g.DrawingColor = ToolbarHoverColor
		  Else
		    g.DrawingColor = ToolbarBackgroundColor
		  End If
		  g.FillRoundRectangle(x, y, w, h, 7, 7)
		  g.DrawingColor = TableBorderColor
		  g.PenSize = 1
		  g.DrawRoundRectangle(x, y, w, h, 7, 7)
		  
		  DrawViewIcon(g, x + w / 2, y + h / 2)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub DrawViewIcon(g As Graphics, cx As Double, cy As Double)
		  // The view toggle's icon, in the toolbar and on the read-only button alike:
		  // M and an eye for rendered Markdown, T and an eye for plain text
		  g.DrawingColor = EffectiveTextColor
		  Var letter As String = "T"
		  If mRenderMarkdown Then letter = "M"
		  DrawCenteredText(g, letter, cx - 6, cy, "System", 11, True, False)
		  
		  // Eye: an almond outline with a pupil
		  Var ex As Double = cx + 5
		  g.PenSize = 1.25
		  g.DrawOval(ex - 5, cy - 3, 10, 6)
		  g.FillOval(ex - 1.5, cy - 1.5, 3, 3)
		  g.PenSize = 1
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EndClickFreeze()
		  // Lets the clicked line switch to raw Markdown now
		  If Not mClickFreeze Then Return
		  StopClickFreeze
		  UpdateCurrentLine
		  If mLayoutDirty Then
		    EnsureCaretVisible
		    Refresh(False)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureCaretVisible()
		  EnsureLayout
		  Var row As MDRow = mRows(RowForPosition(mCaretLine, mCaretCol))
		  If row.Top - kPadding < mScrollY Then
		    mScrollY = row.Top - kPadding
		  ElseIf row.Top + row.Height + kPadding > mScrollY + Height Then
		    mScrollY = row.Top + row.Height + kPadding - Height
		  End If
		  ClampScroll
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub EnsureLayout()
		  If mLayoutDirty Or mLayoutWidth <> Width Then Layout
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ExtendUnitSelection(lineIndex As Integer, col As Integer)
		  // Grows a double/triple-click selection word- or line-wise, always keeping the original unit
		  Var unitStartLine, unitStartCol, unitEndLine, unitEndCol As Integer
		  If mClickCount = 2 Then
		    unitStartLine = lineIndex
		    unitEndLine = lineIndex
		    WordBounds(lineIndex, col, unitStartCol, unitEndCol)
		  Else
		    LineBounds(lineIndex, unitStartLine, unitStartCol, unitEndLine, unitEndCol)
		  End If
		  
		  Var anchorLine, anchorCol, caretLine, caretCol As Integer
		  If ComparePositions(unitStartLine, unitStartCol, mOriginStartLine, mOriginStartCol) < 0 Then
		    anchorLine = mOriginEndLine
		    anchorCol = mOriginEndCol
		    caretLine = unitStartLine
		    caretCol = unitStartCol
		  Else
		    anchorLine = mOriginStartLine
		    anchorCol = mOriginStartCol
		    If ComparePositions(unitEndLine, unitEndCol, mOriginEndLine, mOriginEndCol) > 0 Then
		      caretLine = unitEndLine
		      caretCol = unitEndCol
		    Else
		      caretLine = mOriginEndLine
		      caretCol = mOriginEndCol
		    End If
		  End If
		  
		  If anchorLine = mAnchorLine And anchorCol = mAnchorCol And caretLine = mCaretLine And caretCol = mCaretCol Then Return
		  mAnchorLine = anchorLine
		  mAnchorCol = anchorCol
		  mCaretLine = caretLine
		  mCaretCol = caretCol
		  mDesiredX = -1
		  CaretMoved
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FinishDownload(connection As URLConnection) As String
		  // Returns the image source the connection was loading, and forgets the connection
		  If mDownloads = Nil Or Not mDownloads.HasKey(connection) Then Return ""
		  Var source As String = mDownloads.Value(connection)
		  mDownloads.Remove(connection)
		  RemoveHandler connection.ContentReceived, WeakAddressOf ImageDownloaded
		  RemoveHandler connection.Error, WeakAddressOf ImageDownloadFailed
		  Return source
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub FinishRow(endCol As Integer)
		  Var row As MDRow = mRows(mRows.LastIndex)
		  row.EndCol = endCol
		  row.LastFragment = mFragments.LastIndex
		  mRows(mRows.LastIndex) = row
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function FragmentIsSelected(frag As MDFragment, sl As Integer, sc As Integer, el As Integer, ec As Integer) As Boolean
		  If frag.Line < sl Or frag.Line > el Then Return False
		  Var selStart As Integer = 0
		  If frag.Line = sl Then selStart = sc
		  Var selEnd As Integer = frag.EndCol + 1
		  If frag.Line = el Then selEnd = ec
		  Return selStart < frag.EndCol And selEnd > frag.StartCol
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub GetSelection(ByRef startLine As Integer, ByRef startCol As Integer, ByRef endLine As Integer, ByRef endCol As Integer)
		  If mAnchorLine < mCaretLine Or (mAnchorLine = mCaretLine And mAnchorCol <= mCaretCol) Then
		    startLine = mAnchorLine
		    startCol = mAnchorCol
		    endLine = mCaretLine
		    endCol = mCaretCol
		  Else
		    startLine = mCaretLine
		    startCol = mCaretCol
		    endLine = mAnchorLine
		    endCol = mAnchorCol
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HasSelection() As Boolean
		  Return mAnchorLine <> mCaretLine Or mAnchorCol <> mCaretCol
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function HeadingScale(level As Integer) As Double
		  Select Case level
		  Case 1
		    Return 1.9
		  Case 2
		    Return 1.55
		  Case 3
		    Return 1.3
		  Case 4
		    Return 1.15
		  Case 5
		    Return 1.05
		  Else
		    Return 1.0
		  End Select
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub HoverTimerAction(sender As Timer)
		  #Pragma Unused sender
		  UpdateMouseCursor
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ImageDownloaded(sender As URLConnection, url As String, httpStatus As Integer, content As String)
		  #Pragma Unused url
		  Var source As String = FinishDownload(sender)
		  If source = "" Or httpStatus < 200 Or httpStatus > 299 Then Return
		  
		  Var picture As Picture
		  Try
		    picture = Picture.FromData(content)
		  Catch err As RuntimeException
		    picture = Nil
		  End Try
		  If picture = Nil Then Return
		  
		  If mImageCache = Nil Then mImageCache = New Dictionary
		  mImageCache.Value(ImageKey(source)) = picture
		  mLayoutDirty = True
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ImageDownloadFailed(sender As URLConnection, e As RuntimeException)
		  #Pragma Unused e
		  // The cache keeps Nil for this source, so the alt text stays visible and no retry happens
		  Call FinishDownload(sender)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ImageFor(source As String) As Picture
		  // Returns the picture for an image source, or Nil while it is loading or if it failed
		  If mImageCache = Nil Then mImageCache = New Dictionary
		  Var key As String = ImageKey(source)
		  If mImageCache.HasKey(key) Then Return mImageCache.Value(key)
		  mImageCache.Value(key) = Nil
		  
		  // The host application can supply pictures itself, e.g. from a database or its resources
		  Var picture As Picture = RaiseEvent ImageRequested(source)
		  
		  If picture = Nil Then
		    Var lowerSource As String = source.Lowercase
		    If lowerSource.BeginsWith("http://") Or lowerSource.BeginsWith("https://") Then
		      StartImageDownload(source)
		      Return Nil
		    ElseIf lowerSource.BeginsWith("data:") Then
		      picture = PictureFromDataURI(source)
		    Else
		      picture = PictureFromFile(source)
		    End If
		  End If
		  
		  mImageCache.Value(key) = picture
		  Return picture
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ImageKey(source As String) As String
		  // Dictionary string keys ignore case, but image URLs and paths do not
		  Return EncodeHex(source)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertBlock(block As String, selectLineOffset As Integer, selectCol As Integer, selectLength As Integer)
		  // Inserts a block (table, rule, code block) on its own line(s) at the caret line,
		  // then selects the given part of it so the user can type over it
		  Var lineIndex As Integer = mCaretLine
		  Var firstBlockLine As Integer
		  If mLines(lineIndex).Trim = "" Then
		    SelectRange(lineIndex, 0, lineIndex, mLines(lineIndex).Length)
		    ReplaceSelection(block, kEditOther)
		    firstBlockLine = lineIndex
		  Else
		    // Markdown blocks need an empty line between them and the text above
		    SelectRange(lineIndex, mLines(lineIndex).Length, lineIndex, mLines(lineIndex).Length)
		    ReplaceSelection(Chr(10) + Chr(10) + block, kEditOther)
		    firstBlockLine = lineIndex + 2
		  End If
		  SelectRange(firstBlockLine + selectLineOffset, selectCol, firstBlockLine + selectLineOffset, selectCol + selectLength)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E732074686520636861726163746572206F6666736574206E65617265737420746F2074686520676976656E20706F696E742E
		Function InsertionPosition(x As Integer, y As Integer) As Integer
		  Return CharacterPosition(CType(x, Double), CType(y, Double))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertLink(isImage As Boolean = False)
		  // [selection](https://) with the URL selected, or [Link](https://) with "Link" selected.
		  // An image is the same with a leading "!": ![selection](https://) or ![Image](https://)
		  If mReadOnly Then Return
		  Var prefix As String = "["
		  Var placeholder As String = "Link"
		  If isImage Then
		    prefix = "!["
		    placeholder = "Image"
		  End If
		  
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  If sl = el And sc < ec Then
		    Var label As String = mLines(sl).Middle(sc, ec - sc)
		    ReplaceSelection(prefix + label + "](https://)", kEditOther)
		    Var urlStart As Integer = sc + prefix.Length + label.Length + 2
		    SelectRange(sl, urlStart, sl, urlStart + 8)
		  Else
		    SelectRange(mCaretLine, mCaretCol, mCaretLine, mCaretCol)
		    Var lineIndex As Integer = mCaretLine
		    Var col As Integer = mCaretCol
		    ReplaceSelection(prefix + placeholder + "](https://)", kEditOther)
		    SelectRange(lineIndex, col + prefix.Length, lineIndex, col + prefix.Length + placeholder.Length)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub InsertTyped(value As String)
		  If mReadOnly Then Return
		  
		  // Replacing a selection is its own undo step, never merged into the typing before it
		  If HasSelection Then mLastEditKind = kEditOther
		  ReplaceSelection(value, kEditTyping)
		  // Undo works word by word: a space or line break ends the current typing group
		  If value = " " Or value = Chr(10) Then mLastEditKind = kEditOther
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsSpace(character As String) As Boolean
		  Return character = " " Or character = Chr(9)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsTableKind(kind As Integer) As Boolean
		  Return kind = kKindTableHeader Or kind = kKindTableRow
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function IsWordCharacter(character As String) As Boolean
		  If character = "" Then Return False
		  Var code As Integer = character.Asc
		  // Letters, digits, underscore and any non-ASCII character count as word characters
		  Return (code >= 48 And code <= 57) Or (code >= 65 And code <= 90) Or (code >= 97 And code <= 122) Or code = 95 Or code > 127
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub Layout()
		  // Rebuilds rows and fragments for the whole document.
		  // Every line except the caret line is laid out with its Markdown rendered.
		  Var g As Graphics = MeasureGraphics
		  mLayoutMeasuredInPaint = mPaintGraphics <> Nil
		  mFragments.ResizeTo(-1)
		  mRows.ResizeTo(-1)
		  AnalyzeBlocks
		  
		  Var lastLine As Integer = mLines.LastIndex
		  mLineKinds.ResizeTo(lastLine)
		  mLineFirstRow.ResizeTo(lastLine)
		  mLineLastRow.ResizeTo(lastLine)
		  mLineTop.ResizeTo(lastLine)
		  mLineBottom.ResizeTo(lastLine)
		  mLineImages.ResizeTo(lastLine)
		  
		  Var maxWidth As Double = Max(kMinimumContentWidth, ContentWidth)
		  Var headingGap As Double = BaseRowHeight * 0.4
		  Var y As Double = kPadding
		  
		  For i As Integer = 0 To lastLine
		    Var flags() As Integer
		    Var scale, indent As Double
		    Var contentCol As Integer
		    Var rendered As Boolean = mRenderMarkdown And i <> mCurrentLine
		    mLineImages(i) = Nil
		    Var kind As Integer = ParseLine(i, rendered, flags, scale, indent, contentCol)
		    
		    mLineKinds(i) = kind
		    If kind = kKindHeading And i > 0 Then y = y + headingGap
		    
		    Var table As Integer = mLineTable(i)
		    If table >= 0 And i = mTableStart(table) Then
		      // Columns are measured over all rows (including the caret line) so they stay put while editing
		      ComputeTableColumns(g, table, maxWidth)
		      If i > 0 Then y = y + headingGap
		    ElseIf table < 0 And i > 0 And mLineTable(i - 1) >= 0 Then
		      y = y + headingGap
		    End If
		    
		    mLineTop(i) = y
		    If kind = kKindImage Then
		      y = LayoutImageLine(i, maxWidth, y)
		    ElseIf kind = kKindTableHeader Or kind = kKindTableRow Then
		      y = LayoutTableLine(g, i, flags, y)
		    ElseIf kind = kKindTableDelimiter Then
		      y = LayoutCollapsedLine(i, y)
		    Else
		      y = LayoutLine(g, i, flags, scale, indent, contentCol, maxWidth, y)
		      If kind <> kKindCode And kind <> kKindFence And kind <> kKindRule Then AlignRows(g, i, maxWidth)
		    End If
		    mLineBottom(i) = y
		  Next
		  
		  mContentHeight = y + kPadding
		  mLayoutWidth = Width
		  mLayoutDirty = False
		  ClampScroll
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LayoutCell(g As Graphics, lineIndex As Integer, chars() As String, flags() As Integer, startCol As Integer, endCol As Integer, cellX As Double, cellWidth As Double, align As Integer, lineHeight As Double) As Integer
		  // Word-wraps one table cell inside its column. Returns the number of lines it needs.
		  Var line As String = mLines(lineIndex)
		  Var subLine As Integer = 0
		  Var x As Double = 0
		  Var visibleRight As Double = 0
		  Var lineFirstFragment As Integer = mFragments.Count
		  
		  Var p As Integer = startCol
		  While p < endCol
		    Var f As Integer = flags(p)
		    Var spanEnd As Integer = p + 1
		    While spanEnd < endCol And flags(spanEnd) = f
		      spanEnd = spanEnd + 1
		    Wend
		    
		    If (f And kFlagHidden) <> 0 Then
		      AddFragment(lineIndex, p, spanEnd, cellX + x, 0, f, 1.0, kCellPaddingV + subLine * lineHeight)
		    Else
		      ApplyFont(g, f, 1.0)
		      Var q As Integer = p
		      While q < spanEnd
		        // A piece is a word plus the spaces after it
		        Var e As Integer = q
		        While e < spanEnd And Not IsSpace(chars(e))
		          e = e + 1
		        Wend
		        While e < spanEnd And IsSpace(chars(e))
		          e = e + 1
		        Wend
		        
		        Var piece As String = line.Middle(q, e - q)
		        Var w As Double = g.TextWidth(piece)
		        Var visibleWidth As Double = w
		        If IsSpace(chars(e - 1)) Then visibleWidth = g.TextWidth(piece.TrimRight)
		        
		        If x + visibleWidth > cellWidth And x > 0 Then
		          AlignCellLine(lineFirstFragment, cellWidth - visibleRight, align)
		          subLine = subLine + 1
		          x = 0
		          visibleRight = 0
		          lineFirstFragment = mFragments.Count
		        End If
		        
		        If x + visibleWidth > cellWidth Then
		          // A word wider than the column: break it between characters
		          Var k As Integer = q
		          While k < e
		            Var m As Integer = k + 1
		            While m < e And x + g.TextWidth(line.Middle(k, m + 1 - k)) <= cellWidth
		              m = m + 1
		            Wend
		            Var chunkWidth As Double = g.TextWidth(line.Middle(k, m - k))
		            AddFragment(lineIndex, k, m, cellX + x, chunkWidth, f, 1.0, kCellPaddingV + subLine * lineHeight)
		            x = x + chunkWidth
		            visibleRight = x
		            k = m
		            If k < e Then
		              AlignCellLine(lineFirstFragment, cellWidth - visibleRight, align)
		              subLine = subLine + 1
		              x = 0
		              visibleRight = 0
		              lineFirstFragment = mFragments.Count
		            End If
		          Wend
		        Else
		          AddFragment(lineIndex, q, e, cellX + x, w, f, 1.0, kCellPaddingV + subLine * lineHeight)
		          visibleRight = x + visibleWidth
		          x = x + w
		        End If
		        q = e
		      Wend
		    End If
		    
		    p = spanEnd
		  Wend
		  
		  AlignCellLine(lineFirstFragment, cellWidth - visibleRight, align)
		  Return subLine + 1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LayoutCollapsedLine(lineIndex As Integer, top As Double) As Double
		  // A line that is rendered as nothing, e.g. the |---| line of a table
		  Var n As Integer = mLines(lineIndex).Length
		  mLineFirstRow(lineIndex) = mRows.Count
		  StartRow(lineIndex, top, 0, 0, 0, 0)
		  AddFragment(lineIndex, 0, n, 0, 0, kFlagHidden, 1.0)
		  FinishRow(n)
		  mLineLastRow(lineIndex) = mRows.LastIndex
		  Return top
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LayoutImageLine(lineIndex As Integer, maxWidth As Double, top As Double) As Double
		  // One row holding the picture, scaled down to the available width with its aspect ratio kept
		  Var picture As Picture = mLineImages(lineIndex)
		  Var w As Double = picture.Width
		  Var h As Double = picture.Height
		  If w > maxWidth Then
		    h = h * maxWidth / w
		    w = maxWidth
		  End If
		  // On paper a picture also has to fit on one page
		  If mPrintHeight > 0 And h + (2 * kImageMargin) > mPrintHeight Then
		    Var fitted As Double = Max(1, mPrintHeight - (2 * kImageMargin))
		    w = w * fitted / h
		    h = fitted
		  End If
		  
		  Var n As Integer = mLines(lineIndex).Length
		  mLineFirstRow(lineIndex) = mRows.Count
		  StartRow(lineIndex, top, h + (2 * kImageMargin), 0, 0, 0)
		  AddFragment(lineIndex, 0, n, 0, w, kFlagImage, 1.0)
		  FinishRow(n)
		  mLineLastRow(lineIndex) = mRows.LastIndex
		  Return top + h + (2 * kImageMargin)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LayoutLine(g As Graphics, lineIndex As Integer, flags() As Integer, scale As Double, indent As Double, contentCol As Integer, maxWidth As Double, top As Double) As Double
		  // Word-wraps one line into rows of fragments. Returns the bottom of the line.
		  Var line As String = mLines(lineIndex)
		  Var n As Integer = line.Length
		  
		  ApplyFont(g, 0, scale)
		  Var textHeight As Double = g.TextHeight
		  Var rowHeight As Double = Ceiling(textHeight * mLineSpacing)
		  Var baseline As Double = (rowHeight - textHeight) / 2 + g.FontAscent
		  
		  Var x As Double = indent
		  Var rowStartX As Double = indent
		  Var hanging As Double = indent
		  Var y As Double = top
		  
		  mLineFirstRow(lineIndex) = mRows.Count
		  StartRow(lineIndex, y, rowHeight, baseline, 0, indent)
		  
		  Var chars() As String
		  If n > 0 Then chars = line.Split("")
		  
		  Var p As Integer
		  While p < n
		    // A span is a run of characters sharing the same style
		    Var f As Integer = flags(p)
		    Var spanEnd As Integer = p + 1
		    While spanEnd < n And flags(spanEnd) = f And spanEnd <> contentCol
		      spanEnd = spanEnd + 1
		    Wend
		    // Wrapped rows of a list item line up with the item's text, not its marker
		    If p = contentCol Then hanging = x
		    
		    If (f And kFlagHidden) <> 0 Then
		      AddFragment(lineIndex, p, spanEnd, x, 0, f, scale)
		      
		    ElseIf (f And kSymbolFlags) <> 0 Then
		      Var w As Double = SymbolWidth(g, f, scale)
		      If x + w > maxWidth And x > rowStartX Then
		        FinishRow(p)
		        y = y + rowHeight
		        x = hanging
		        rowStartX = hanging
		        StartRow(lineIndex, y, rowHeight, baseline, p, x)
		      End If
		      AddFragment(lineIndex, p, spanEnd, x, w, f, scale)
		      x = x + w
		      
		    Else
		      ApplyFont(g, f, scale)
		      Var q As Integer = p
		      While q < spanEnd
		        // A piece is a word plus the spaces after it
		        Var e As Integer = q
		        While e < spanEnd And Not IsSpace(chars(e))
		          e = e + 1
		        Wend
		        While e < spanEnd And IsSpace(chars(e))
		          e = e + 1
		        Wend
		        
		        Var piece As String = line.Middle(q, e - q)
		        Var w As Double = g.TextWidth(piece)
		        Var visibleWidth As Double = w
		        If IsSpace(chars(e - 1)) Then visibleWidth = g.TextWidth(piece.TrimRight)
		        
		        If x + visibleWidth > maxWidth And x > rowStartX Then
		          FinishRow(q)
		          y = y + rowHeight
		          x = hanging
		          rowStartX = hanging
		          StartRow(lineIndex, y, rowHeight, baseline, q, x)
		        End If
		        
		        If x + visibleWidth > maxWidth Then
		          // A single word wider than the row: break it between characters
		          Var k As Integer = q
		          While k < e
		            Var m As Integer = k + 1
		            While m < e And x + g.TextWidth(line.Middle(k, m + 1 - k)) <= maxWidth
		              m = m + 1
		            Wend
		            Var chunkWidth As Double = g.TextWidth(line.Middle(k, m - k))
		            AddFragment(lineIndex, k, m, x, chunkWidth, f, scale)
		            x = x + chunkWidth
		            k = m
		            If k < e Then
		              FinishRow(k)
		              y = y + rowHeight
		              x = hanging
		              rowStartX = hanging
		              StartRow(lineIndex, y, rowHeight, baseline, k, x)
		            End If
		          Wend
		        Else
		          AddFragment(lineIndex, q, e, x, w, f, scale)
		          x = x + w
		        End If
		        q = e
		      Wend
		    End If
		    
		    p = spanEnd
		  Wend
		  
		  FinishRow(n)
		  mLineLastRow(lineIndex) = mRows.LastIndex
		  Return y + rowHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LayoutTableLine(g As Graphics, lineIndex As Integer, flags() As Integer, top As Double) As Double
		  // One table line becomes one row; its cells sit in the table's columns and wrap inside them
		  Var line As String = mLines(lineIndex)
		  Var n As Integer = line.Length
		  Var table As Integer = mLineTable(lineIndex)
		  Var first As Integer = mTableFirstColumn(table)
		  Var count As Integer = mTableColumnCount(table)
		  
		  Var chars() As String
		  If n > 0 Then chars = line.Split("")
		  Var starts() As Integer
		  Var ends() As Integer
		  SplitTableCells(line, starts, ends)
		  
		  ApplyFont(g, 0, 1.0)
		  Var textHeight As Double = g.TextHeight
		  Var lineHeight As Double = Ceiling(textHeight * mLineSpacing)
		  Var baseline As Double = (lineHeight - textHeight) / 2 + g.FontAscent
		  
		  mLineFirstRow(lineIndex) = mRows.Count
		  StartRow(lineIndex, top, lineHeight, baseline, 0, 0)
		  
		  Var lineCount As Integer = 1
		  Var p As Integer = 0
		  For c As Integer = 0 To Min(count, starts.Count) - 1
		    Var cellX As Double = mTableColumnX(first + c) + kCellPadding
		    Var cellWidth As Double = Max(1, mTableColumnW(first + c) - (2 * kCellPadding))
		    // Pipes and spaces before the cell take no room
		    If starts(c) > p Then AddFragment(lineIndex, p, starts(c), cellX, 0, kFlagHidden, 1.0, kCellPaddingV)
		    lineCount = Max(lineCount, LayoutCell(g, lineIndex, chars, flags, starts(c), ends(c), cellX, cellWidth, mTableAlign(first + c), lineHeight))
		    p = ends(c)
		  Next
		  If n > p Then
		    // The closing pipe, and any cells beyond the header's column count
		    Var lastColumn As Integer = first + count - 1
		    AddFragment(lineIndex, p, n, mTableColumnX(lastColumn) + mTableColumnW(lastColumn), 0, kFlagHidden, 1.0, kCellPaddingV)
		  End If
		  
		  Var rowHeight As Double = lineCount * lineHeight + (2 * kCellPaddingV)
		  Var row As MDRow = mRows(mRows.LastIndex)
		  row.Height = rowHeight
		  mRows(mRows.LastIndex) = row
		  FinishRow(n)
		  mLineLastRow(lineIndex) = mRows.LastIndex
		  Return top + rowHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LayoutToolbar()
		  // Positions of the toolbar items; items that do not fit the editor's width are left out
		  Var items() As Integer = ToolbarItems
		  mToolbarX.ResizeTo(items.LastIndex)
		  Var available As Double = Width - (2 * kToolbarMargin) - kScrollbarReserve
		  
		  Var inset As Double = ToolbarInset
		  Var x As Double = inset
		  Var count As Integer = 0
		  For i As Integer = 0 To items.LastIndex
		    Var itemWidth As Double = ToolbarButtonWidth
		    If items(i) < 0 Then itemWidth = kToolbarSeparatorWidth
		    If x + itemWidth + inset > available Then Exit For
		    mToolbarX(i) = x
		    x = x + itemWidth + kToolbarGap
		    count = i + 1
		  Next
		  // Never end with a separator
		  While count > 0 And items(count - 1) < 0
		    count = count - 1
		  Wend
		  
		  mToolbarVisibleCount = count
		  If count = 0 Then
		    mToolbarWidth = 0
		  Else
		    mToolbarWidth = mToolbarX(count - 1) + ToolbarButtonWidth + inset
		  End If
		  If mReadOnly Then
		    // The read-only view toggle sits in the top right corner
		    mToolbarLeft = Max(kToolbarMargin, Width - kScrollbarReserve - kToolbarMargin - mToolbarWidth)
		  Else
		    mToolbarLeft = Max(kToolbarMargin, Floor((Width - kScrollbarReserve - mToolbarWidth) / 2))
		  End If
		  For i As Integer = 0 To count - 1
		    mToolbarX(i) = mToolbarX(i) + mToolbarLeft
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub LineBounds(lineIndex As Integer, ByRef startLine As Integer, ByRef startCol As Integer, ByRef endLine As Integer, ByRef endCol As Integer)
		  // A selected line includes its line break, like a triple click in a text area
		  startLine = lineIndex
		  startCol = 0
		  If lineIndex < mLines.LastIndex Then
		    endLine = lineIndex + 1
		    endCol = 0
		  Else
		    endLine = lineIndex
		    endCol = mLines(lineIndex).Length
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LineIsSelected(lineIndex As Integer, sl As Integer, sc As Integer, el As Integer, ec As Integer) As Boolean
		  // True when the selection covers any character of the line
		  If lineIndex < sl Or lineIndex > el Then Return False
		  If lineIndex = el And el > sl And ec = 0 Then Return False
		  If lineIndex = sl And sl < el And sc >= mLines(lineIndex).Length Then Return False
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52657475726E7320746865206C696E65206F66207468652072617720746578742074686174206120636861726163746572206F666673657420697320696E2E
		Function LineNumber(charPosition As Integer) As Integer
		  Var lineIndex, col As Integer
		  PositionOfOffset(charPosition, lineIndex, col)
		  Return lineIndex
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LinePrefixKind(line As String) As Integer
		  // Which toolbar format a line's prefix corresponds to (0 for none)
		  Var match As RegExMatch = CachedRegEx(LinePrefixPattern).Search(line)
		  Var prefix As String = match.SubExpressionString(0).Trim
		  If prefix = "" Then Return 0
		  If prefix.BeginsWith("#") Then
		    Select Case prefix.Length
		    Case 1
		      Return kToolH1
		    Case 2
		      Return kToolH2
		    Case 3
		      Return kToolH3
		    End Select
		    Return 0
		  End If
		  If prefix.IndexOf("[") >= 0 Then Return kToolTask
		  If prefix = "-" Or prefix = "*" Or prefix = "+" Then Return kToolBullet
		  If prefix = ">" Then Return kToolQuote
		  Return kToolNumbered
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LinePrefixPattern() As String
		  // Leading indentation (group 1) and a heading, task, list or quote marker
		  Return "^([ \t]*)(#{1,6}[ \t]+|[-*+][ \t]+\[[ xX]\][ \t]+|[-*+][ \t]+|\d{1,9}[.)][ \t]+|>[ \t]?)?"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LinkAt(x As Integer, y As Integer) As String
		  // URL of the link under the given point, or "" when there is none
		  EnsureLayout
		  If mRows.Count = 0 Then Return ""
		  
		  Var yDoc As Double = y + mScrollY
		  Var r As Integer = RowAtY(yDoc)
		  Var row As MDRow = mRows(r)
		  If yDoc < row.Top Or yDoc >= row.Top + row.Height Then Return ""
		  
		  Var xContent As Double = x - kPadding
		  Var yInRow As Double = yDoc - row.Top
		  Var isTable As Boolean = IsTableKind(mLineKinds(row.Line))
		  For f As Integer = row.FirstFragment To row.LastFragment
		    Var frag As MDFragment = mFragments(f)
		    If frag.Width <= 0 Then Continue
		    If isTable And (yInRow < frag.DY Or yInRow >= frag.DY + row.SubHeight) Then Continue
		    If xContent >= frag.X And xContent < frag.X + frag.Width Then
		      // Only a hit on actual text counts, not the empty space next to it
		      Var col As Integer = Max(frag.StartCol, Min(ColForX(r, xContent, yInRow), frag.EndCol - 1))
		      Return LinkURLAt(row.Line, col)
		    End If
		  Next
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LinkModifierDown(currentState As Boolean) As Boolean
		  // currentState: the key state right now (for hovering); otherwise the state when the event was generated
		  #If TargetMacOS Then
		    // macOS opens links with Cmd+click; Ctrl+click is the context menu there
		    If currentState Then Return Keyboard.AsyncCommandKey
		    Return Keyboard.CommandKey
		  #Else
		    If currentState Then Return Keyboard.AsyncControlKey
		    Return Keyboard.ControlKey
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function LinkURLAt(lineIndex As Integer, col As Integer) As String
		  // URL of the [text](url) link covering col. On a rendered line only the visible text counts,
		  // on the raw caret line the whole Markdown of the link does.
		  Var line As String = mLines(lineIndex)
		  Var rendered As Boolean = mRenderMarkdown And lineIndex <> mCurrentLine
		  Var rx As RegEx = CachedRegEx("(!?\[)([^\]]+)\]\(([^)\s]*)\)")
		  Var match As RegExMatch = rx.Search(line)
		  While match <> Nil
		    Var s As Integer = MatchStart(match, line, 0)
		    Var e As Integer = s + match.SubExpressionString(0).Length
		    If rendered And mLineKinds(lineIndex) <> kKindImage Then
		      s = s + match.SubExpressionString(1).Length
		      e = s + match.SubExpressionString(2).Length
		    End If
		    If col >= s And col < e Then Return match.SubExpressionString(3)
		    match = rx.Search
		  Wend
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MarkConsumed(consumed() As Boolean, start As Integer, length As Integer)
		  For i As Integer = Max(0, start) To Min(consumed.LastIndex, start + length - 1)
		    consumed(i) = True
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MarkerRunMatches(run As Integer, markerCharacter As String, markerLength As Integer) As Boolean
		  // Whether a run of marker characters belongs to this marker. "*" runs are shared by
		  // italic (1), bold (2) and both (3), so a run of 3 counts for either.
		  If markerCharacter = "*" Or markerCharacter = "_" Then
		    If markerLength = 1 Then Return run = 1 Or run = 3
		    Return run = 2 Or run = 3
		  End If
		  Return run >= markerLength
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MatchStart(match As RegExMatch, line As String, group As Integer) As Integer
		  // RegExMatch reports byte offsets; the editor works with character offsets.
		  Return line.LeftBytes(match.SubExpressionStartB(group)).Length
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MeasureGraphics() As Graphics
		  // While painting, measure with the Graphics being drawn on (see Paint). Outside of Paint
		  // keep a tiny picture around, made like the window's own drawing surface.
		  If mPaintGraphics <> Nil Then Return mPaintGraphics
		  If mMeasurePicture = Nil Then
		    If Self.Window <> Nil Then
		      mMeasurePicture = Self.Window.BitmapForCaching(1, 1)
		    Else
		      mMeasurePicture = New Picture(1, 1)
		    End If
		  End If
		  Return mMeasurePicture.Graphics
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function MeasureRange(g As Graphics, lineIndex As Integer, flags() As Integer, startCol As Integer, endCol As Integer) As Double
		  // Width of the visible characters in a range, each span in its own style
		  Var line As String = mLines(lineIndex)
		  Var width As Double
		  Var p As Integer = startCol
		  While p < endCol
		    Var f As Integer = flags(p)
		    Var spanEnd As Integer = p + 1
		    While spanEnd < endCol And flags(spanEnd) = f
		      spanEnd = spanEnd + 1
		    Wend
		    If (f And kFlagHidden) = 0 Then
		      ApplyFont(g, f, 1.0)
		      width = width + g.TextWidth(line.Middle(p, spanEnd - p))
		    End If
		    p = spanEnd
		  Wend
		  Return width
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MoveCaret(lineIndex As Integer, col As Integer, extend As Boolean)
		  mCaretLine = Max(0, Min(lineIndex, mLines.LastIndex))
		  mCaretCol = Max(0, Min(col, mLines(mCaretLine).Length))
		  If Not extend Then
		    mAnchorLine = mCaretLine
		    mAnchorCol = mCaretCol
		  End If
		  mDesiredX = -1
		  mLastEditKind = kEditOther
		  CaretMoved
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MoveHorizontal(direction As Integer, byWord As Boolean, extend As Boolean)
		  // Without Shift, an arrow key collapses an existing selection to its edge
		  If HasSelection And Not extend Then
		    Var sl, sc, el, ec As Integer
		    GetSelection(sl, sc, el, ec)
		    If direction < 0 Then
		      MoveCaret(sl, sc, False)
		    Else
		      MoveCaret(el, ec, False)
		    End If
		    Return
		  End If
		  
		  Var lineIndex As Integer = mCaretLine
		  Var col As Integer = mCaretCol
		  StepPosition(direction, byWord, lineIndex, col)
		  MoveCaret(lineIndex, col, extend)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MoveToRowEdge(toEnd As Boolean, extend As Boolean)
		  EnsureLayout
		  Var r As Integer = RowForPosition(mCaretLine, mCaretCol)
		  Var row As MDRow = mRows(r)
		  If toEnd Then
		    Var col As Integer = row.EndCol
		    If r < mLineLastRow(row.Line) And col > row.StartCol Then col = col - 1
		    MoveCaret(row.Line, col, extend)
		  Else
		    MoveCaret(row.Line, row.StartCol, extend)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub MoveVertical(rowDelta As Integer, extend As Boolean)
		  EnsureLayout
		  Var r As Integer = RowForPosition(mCaretLine, mCaretCol)
		  // Remember the horizontal position so repeated Up/Down keeps its column
		  If mDesiredX < 0 Then mDesiredX = XForCol(r, mCaretCol)
		  Var desired As Double = mDesiredX
		  
		  Var target As Integer = r + rowDelta
		  If target < 0 Then
		    MoveCaret(0, 0, extend)
		  ElseIf target > mRows.LastIndex Then
		    MoveCaret(mLines.LastIndex, mLines(mLines.LastIndex).Length, extend)
		  Else
		    MoveCaret(mRows(target).Line, ColForX(target, desired), extend)
		  End If
		  mDesiredX = desired
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function NormalizedText(value As String) As String
		  If value.Encoding = Nil Then
		    value = value.DefineEncoding(Encodings.UTF8)
		  ElseIf value.Encoding <> Encodings.UTF8 Then
		    value = value.ConvertEncoding(Encodings.UTF8)
		  End If
		  Return value.ReplaceLineEndings(Chr(10))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub NotifySelectionChanged()
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  Var start As Integer = OffsetOf(sl, sc)
		  Var length As Integer = OffsetOf(el, ec) - start
		  If start <> mLastSelectionStart Or length <> mLastSelectionLength Then
		    mLastSelectionStart = start
		    mLastSelectionLength = length
		    RaiseEvent SelectionChanged
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function OffsetOf(lineIndex As Integer, col As Integer) As Integer
		  // Character offset as used by SelectionStart: every line break counts as one character
		  Var offset As Integer
		  For i As Integer = 0 To lineIndex - 1
		    offset = offset + mLines(i).Length + 1
		  Next
		  Return offset + col
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub OpenLink(url As String)
		  // The application may handle the link itself
		  If RaiseEvent LinkClicked(url) Then Return
		  
		  Var lowerURL As String = url.Lowercase
		  // Anchors inside the document (#heading) are not supported
		  If url = "" Or url.BeginsWith("#") Then Return
		  
		  Try
		    If lowerURL.IndexOf("://") > 0 Or lowerURL.BeginsWith("mailto:") Or lowerURL.BeginsWith("tel:") Then
		      System.GotoURL(url)
		      Return
		    End If
		    
		    // A path to a local file opens in its default application
		    Var file As FolderItem = ResolveLocalFile(url)
		    If file <> Nil And file.Exists Then
		      file.Open
		      Return
		    End If
		    
		    If lowerURL.BeginsWith("www.") Then System.GotoURL("https://" + url)
		  Catch err As RuntimeException
		    // A link that cannot be opened is ignored
		  End Try
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseLine(lineIndex As Integer, rendered As Boolean, flags() As Integer, ByRef scale As Double, ByRef indent As Double, ByRef contentCol As Integer) As Integer
		  // Fills flags with a style per character and returns the line's block kind
		  Var line As String = mLines(lineIndex)
		  Var n As Integer = line.Length
		  flags.ResizeTo(n - 1)
		  scale = 1.0
		  indent = 0
		  contentCol = -1
		  
		  Select Case mBlockKinds(lineIndex)
		  Case kKindCode
		    // Code block lines have no Markdown syntax to reveal, so they look the same on the caret line
		    AddFlags(flags, 0, n, kFlagCode)
		    indent = kCodeInset
		    Return kKindCode
		  Case kKindFence
		    indent = kCodeInset
		    If rendered Then AddFlags(flags, 0, n, kFlagCode Or kFlagMuted)
		    Return kKindFence
		  Case kKindTableHeader, kKindTableRow
		    If Not rendered Then Return kKindNormal
		    TableLineFlags(lineIndex, flags)
		    Return mBlockKinds(lineIndex)
		  Case kKindTableDelimiter
		    // The |---|---| line only defines the columns; rendered, it takes no space
		    If Not rendered Then Return kKindNormal
		    AddFlags(flags, 0, n, kFlagHidden)
		    Return kKindTableDelimiter
		  End Select
		  
		  If Not rendered Then Return kKindNormal
		  
		  Var match As RegExMatch
		  
		  // A line holding only an image is drawn as the picture, once it has loaded.
		  // Until then (or if it cannot be loaded) the alt text is shown like a link.
		  match = CachedRegEx("^\s*!\[[^\]]*\]\(\s*<?([^)\s>]+)>?(?:\s+[""'][^""']*[""'])?\s*\)\s*$").Search(line)
		  If match <> Nil Then
		    Var picture As Picture = ImageFor(match.SubExpressionString(1))
		    If picture <> Nil And picture.Width > 0 And picture.Height > 0 Then
		      mLineImages(lineIndex) = picture
		      AddFlags(flags, 0, n, kFlagHidden)
		      Return kKindImage
		    End If
		  End If
		  
		  // Headings: # .. ######
		  match = CachedRegEx("^ {0,3}(#{1,6})(?:[ \t]+|$)").Search(line)
		  If match <> Nil Then
		    Var markerLength As Integer = match.SubExpressionString(0).Length
		    scale = HeadingScale(match.SubExpressionString(1).Length)
		    AddFlags(flags, 0, markerLength, kFlagHidden)
		    AddFlags(flags, markerLength, n - markerLength, kFlagBold)
		    ApplyInlineFlags(line, flags, markerLength)
		    Return kKindHeading
		  End If
		  
		  // Horizontal rules: --- *** ___
		  match = CachedRegEx("^ {0,3}([-*_])(?:[ \t]*\1){2,}[ \t]*$").Search(line)
		  If match <> Nil Then
		    AddFlags(flags, 0, n, kFlagHidden)
		    Return kKindRule
		  End If
		  
		  // Block quotes: > text
		  match = CachedRegEx("^ {0,3}>[ \t]?").Search(line)
		  If match <> Nil Then
		    Var markerLength As Integer = match.SubExpressionString(0).Length
		    AddFlags(flags, 0, markerLength, kFlagHidden)
		    AddFlags(flags, markerLength, n - markerLength, kFlagMuted Or kFlagItalic)
		    indent = kQuoteInset
		    ApplyInlineFlags(line, flags, markerLength)
		    Return kKindQuote
		  End If
		  
		  // List items: - * + 1. 1) with an optional task box [ ] / [x]
		  match = CachedRegEx("^([ \t]*)([-*+]|\d{1,9}[.)])[ \t]+(\[[ xX]\][ \t]+)?").Search(line)
		  If match <> Nil Then
		    Var markerStart As Integer = match.SubExpressionString(1).Length
		    Var marker As String = match.SubExpressionString(2)
		    If marker = "-" Or marker = "*" Or marker = "+" Then
		      AddFlags(flags, markerStart, 1, kFlagBullet)
		    Else
		      AddFlags(flags, markerStart, marker.Length, kFlagAccent)
		    End If
		    
		    contentCol = match.SubExpressionString(0).Length
		    If match.SubExpressionCount > 3 And match.SubExpressionString(3) <> "" Then
		      Var boxStart As Integer = MatchStart(match, line, 3)
		      If match.SubExpressionString(3).Middle(1, 1) = " " Then
		        AddFlags(flags, boxStart, 3, kFlagTaskOpen)
		      Else
		        AddFlags(flags, boxStart, 3, kFlagTaskDone)
		        AddFlags(flags, contentCol, n - contentCol, kFlagMuted)
		      End If
		    End If
		    
		    ApplyInlineFlags(line, flags, contentCol)
		    Return kKindList
		  End If
		  
		  ApplyInlineFlags(line, flags, 0)
		  Return kKindNormal
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseTableDelimiter(line As String, aligns() As Integer) As Boolean
		  // |:---|:---:|---:| defines the columns and their alignment
		  aligns.ResizeTo(-1)
		  If line.IndexOf("|") < 0 Then Return False
		  If CachedRegEx("^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$").Search(line) = Nil Then Return False
		  
		  Var trimmed As String = line.Trim
		  If trimmed.BeginsWith("|") Then trimmed = trimmed.Middle(1)
		  If trimmed.EndsWith("|") Then trimmed = trimmed.Left(trimmed.Length - 1)
		  For Each part As String In trimmed.Split("|")
		    part = part.Trim
		    Var leftColon As Boolean = part.BeginsWith(":")
		    Var rightColon As Boolean = part.EndsWith(":")
		    If leftColon And rightColon Then
		      aligns.Add(kAlignCenter)
		    ElseIf rightColon Then
		      aligns.Add(kAlignRight)
		    Else
		      aligns.Add(kAlignLeft)
		    End If
		  Next
		  Return aligns.Count > 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5265706C61636573207468652073656C656374696F6E2077697468207468652074657874206F6E2074686520636C6970626F6172642E20446F6573206E6F7468696E67207768696C6520526561644F6E6C7920697320547275652E
		Sub Paste()
		  If mReadOnly Then Return
		  
		  Var board As New Clipboard
		  If board.TextAvailable Then
		    mLastEditKind = kEditOther
		    ReplaceSelection(board.Text, kEditOther)
		  End If
		  board.Close
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PictureFromDataURI(source As String) As Picture
		  // data:image/png;base64,....
		  Var comma As Integer = source.IndexOf(",")
		  If comma < 0 Then Return Nil
		  
		  Var header As String = source.Left(comma)
		  Var payload As String = source.Middle(comma + 1)
		  Try
		    If header.IndexOf(";base64") >= 0 Then
		      payload = DecodeBase64(payload)
		    Else
		      payload = DecodeURLComponent(payload)
		    End If
		    Return Picture.FromData(payload)
		  Catch err As RuntimeException
		    Return Nil
		  End Try
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PictureFromFile(source As String) As Picture
		  Try
		    Var file As FolderItem = ResolveLocalFile(source)
		    If file <> Nil And file.Exists And Not file.IsFolder Then Return Picture.Open(file)
		  Catch err As RuntimeException
		    Return Nil
		  End Try
		  Return Nil
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PositionFromPoint(x As Double, y As Double, ByRef lineIndex As Integer, ByRef col As Integer)
		  EnsureLayout
		  Var yDoc As Double = y + mScrollY
		  Var lastRow As MDRow = mRows(mRows.LastIndex)
		  
		  // Below the text: end of the document
		  If yDoc >= lastRow.Top + lastRow.Height Then
		    lineIndex = mLines.LastIndex
		    col = mLines(lineIndex).Length
		    Return
		  End If
		  
		  Var r As Integer = RowAtY(yDoc)
		  lineIndex = mRows(r).Line
		  col = ColForX(r, x - kPadding, yDoc - mRows(r).Top)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PositionIsSelected(lineIndex As Integer, col As Integer) As Boolean
		  If Not HasSelection Then Return False
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  Return ComparePositions(lineIndex, col, sl, sc) >= 0 And ComparePositions(lineIndex, col, el, ec) <= 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub PositionOfOffset(offset As Integer, ByRef lineIndex As Integer, ByRef col As Integer)
		  Var remaining As Integer = Max(0, offset)
		  For i As Integer = 0 To mLines.LastIndex
		    Var length As Integer = mLines(i).Length
		    If remaining <= length Or i = mLines.LastIndex Then
		      lineIndex = i
		      col = Min(remaining, length)
		      Return
		    End If
		    remaining = remaining - length - 1
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function PrefixForAction(action As Integer, number As Integer) As String
		  Select Case action
		  Case kToolH1
		    Return "# "
		  Case kToolH2
		    Return "## "
		  Case kToolH3
		    Return "### "
		  Case kToolBullet
		    Return "- "
		  Case kToolNumbered
		    Return Str(number) + ". "
		  Case kToolTask
		    Return "- [ ] "
		  Case kToolQuote
		    Return "> "
		  End Select
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 55736564206279204D61726B646F776E546578745072696E7465722E
		Attributes( Hidden )  Function PrintBlock(g As Graphics, width As Double, firstRow As Integer, x As Double, y As Double, height As Double) As Integer
		  // Lays the whole document out for the printer, draws the rows from firstRow on that fit into
		  // height at x, y and returns the first row of the next block, or -1 when nothing is left.
		  Var savedGraphics As Graphics = mPaintGraphics
		  Var savedScroll As Double = mScrollY
		  Var savedLine As Integer = mCurrentLine
		  Var nextRow As Integer = -1
		  
		  Try
		    mPaintGraphics = g
		    mPrintWidth = Max(kMinimumContentWidth, width)
		    mPrintHeight = Max(1, height)
		    // There is no caret on paper, so every line is printed rendered
		    mCurrentLine = -1
		    Layout
		    
		    If firstRow >= 0 And firstRow <= mRows.LastIndex Then
		      // Whole rows only: the block ends before the first row that does not fit
		      Var blockTop As Double = mRows(firstRow).Top
		      Var lastRow As Integer = firstRow
		      While lastRow < mRows.LastIndex
		        Var candidate As MDRow = mRows(lastRow + 1)
		        If candidate.Top + candidate.Height - blockTop > height Then Exit While
		        lastRow = lastRow + 1
		      Wend
		      Var blockHeight As Double = mRows(lastRow).Top + mRows(lastRow).Height - blockTop
		      
		      // Code backgrounds and table borders of lines that go on over the page break are cut off here
		      Var pg As Graphics = g.Clip(x, y, mPrintWidth, Max(1, blockHeight))
		      For i As Integer = mRows(firstRow).Line To mRows(lastRow).Line
		        DrawLineDecoration(pg, i, 0, mPrintWidth, mLineTop(i) - blockTop)
		      Next
		      For r As Integer = firstRow To lastRow
		        Var row As MDRow = mRows(r)
		        For f As Integer = row.FirstFragment To row.LastFragment
		          Var frag As MDFragment = mFragments(f)
		          If (frag.Flags And kFlagImage) <> 0 Then
		            DrawImage(pg, frag, row, 0, row.Top - blockTop, False)
		          ElseIf (frag.Flags And kFlagHidden) = 0 Then
		            DrawFragment(pg, frag, row, 0, row.Top - blockTop)
		          End If
		        Next
		      Next
		      
		      nextRow = lastRow + 1
		      If nextRow > mRows.LastIndex Or RowsAreBlank(nextRow) Then nextRow = -1
		    End If
		  Finally
		    // Back to the editor's own layout and colors
		    mPrintWidth = 0
		    mPrintHeight = 0
		    mCurrentLine = savedLine
		    mPaintGraphics = savedGraphics
		    mScrollY = savedScroll
		    Layout
		    Refresh(False)
		  End Try
		  
		  Return nextRow
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RangeIsFree(consumed() As Boolean, start As Integer, length As Integer) As Boolean
		  For i As Integer = Max(0, start) To Min(consumed.LastIndex, start + length - 1)
		    If consumed(i) Then Return False
		  Next
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RecordUndo(editKind As Integer)
		  // Consecutive edits of the same kind (typing, deleting) form one undo step
		  If editKind <> kEditOther And editKind = mLastEditKind Then Return
		  
		  mUndoTexts.Add(String.FromArray(mLines, Chr(10)))
		  mUndoOffsets.Add(OffsetOf(mCaretLine, mCaretCol))
		  If mUndoTexts.Count > kMaxUndo Then
		    mUndoTexts.RemoveAt(0)
		    mUndoOffsets.RemoveAt(0)
		  End If
		  mRedoTexts.ResizeTo(-1)
		  mRedoOffsets.ResizeTo(-1)
		  mLastEditKind = editKind
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 52656170706C69657320746865206C617374206368616E6765207468617420556E646F20746F6F6B206261636B2E
		Sub Redo()
		  If mRedoTexts.Count = 0 Or mReadOnly Then Return
		  
		  mUndoTexts.Add(String.FromArray(mLines, Chr(10)))
		  mUndoOffsets.Add(OffsetOf(mCaretLine, mCaretCol))
		  RestoreState(mRedoTexts.Pop, mRedoOffsets.Pop)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ReplaceSelection(value As String, editKind As Integer)
		  // The single editing primitive: typing, deleting, pasting and setting SelectedText all end up here
		  If mReadOnly Then Return
		  EndClickFreeze
		  
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  
		  If MaximumCharactersAllowed > 0 Then
		    // Only insert as much as still fits; line breaks count as one character
		    value = NormalizedText(value)
		    Var totalLength As Integer = OffsetOf(mLines.LastIndex, mLines(mLines.LastIndex).Length)
		    Var remaining As Integer = MaximumCharactersAllowed - (totalLength - (OffsetOf(el, ec) - OffsetOf(sl, sc)))
		    If value.Length > remaining Then
		      value = value.Left(Max(0, remaining))
		      If value = "" And sl = el And sc = ec Then Return
		    End If
		  End If
		  
		  RecordUndo(editKind)
		  
		  Var before As String = mLines(sl).Left(sc)
		  Var after As String = mLines(el).Middle(ec)
		  For i As Integer = el DownTo sl + 1
		    mLines.RemoveAt(i)
		  Next
		  
		  Var parts() As String = NormalizedText(value).Split(Chr(10))
		  If parts.Count = 0 Then parts.Add("")
		  
		  If parts.Count = 1 Then
		    mLines(sl) = before + parts(0) + after
		    mCaretLine = sl
		    mCaretCol = sc + parts(0).Length
		  Else
		    mLines(sl) = before + parts(0)
		    For k As Integer = 1 To parts.LastIndex
		      If k = parts.LastIndex Then
		        mLines.AddAt(sl + k, parts(k) + after)
		      Else
		        mLines.AddAt(sl + k, parts(k))
		      End If
		    Next
		    mCaretLine = sl + parts.LastIndex
		    mCaretCol = parts(parts.LastIndex).Length
		  End If
		  
		  mAnchorLine = mCaretLine
		  mAnchorCol = mCaretCol
		  TextDidChange
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ResetBlink()
		  // Keep the caret solid while the user is typing or moving it
		  mCaretVisible = True
		  If mBlinkTimer <> Nil Then mBlinkTimer.Reset
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ResolveLocalFile(source As String) As FolderItem
		  // file:// URLs, absolute paths, or paths relative to BaseFolder
		  Var path As String = DecodeURLComponent(source).DefineEncoding(Encodings.UTF8)
		  
		  If source.Lowercase.BeginsWith("file://") Then Return New FolderItem(source, FolderItem.PathModes.URL)
		  
		  If path.BeginsWith("/") Or (TargetWindows And path.Middle(1, 1) = ":") Then
		    // "/..." on macOS/Linux, "C:\..." on Windows
		    Return New FolderItem(path, FolderItem.PathModes.Native)
		  End If
		  
		  If mBaseFolder = Nil Then Return Nil
		  Var file As FolderItem = mBaseFolder
		  For Each part As String In path.ReplaceAll("\", "/").Split("/")
		    If part = "" Or part = "." Then Continue
		    If part = ".." Then
		      file = file.Parent
		    Else
		      file = file.Child(part)
		    End If
		    If file = Nil Then Return Nil
		  Next
		  Return file
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RestoreState(value As String, offset As Integer)
		  mLines = value.Split(Chr(10))
		  If mLines.Count = 0 Then mLines.Add("")
		  Var lineIndex, col As Integer
		  PositionOfOffset(offset, lineIndex, col)
		  mCaretLine = lineIndex
		  mCaretCol = col
		  mAnchorLine = lineIndex
		  mAnchorCol = col
		  mLastEditKind = kEditOther
		  TextDidChange
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RowAtY(yDoc As Double) As Integer
		  // Last row whose top is at or above yDoc
		  If mRows.Count = 0 Then Return -1
		  Var low As Integer = 0
		  Var high As Integer = mRows.LastIndex
		  While low < high
		    Var middle As Integer = (low + high + 1) \ 2
		    If mRows(middle).Top <= yDoc Then
		      low = middle
		    Else
		      high = middle - 1
		    End If
		  Wend
		  Return low
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RowsAreBlank(firstRow As Integer) As Boolean
		  // True when the rows from firstRow on only hold empty lines, so no page is started for them
		  For r As Integer = firstRow To mRows.LastIndex
		    If mLines(mRows(r).Line).Trim <> "" Then Return False
		  Next
		  Return True
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RowForPosition(lineIndex As Integer, col As Integer) As Integer
		  // A column on a wrap boundary belongs to the next row
		  Var lastRow As Integer = mLineLastRow(lineIndex)
		  For r As Integer = mLineFirstRow(lineIndex) To lastRow
		    If col < mRows(r).EndCol Or r = lastRow Then Return r
		  Next
		  Return lastRow
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RowsPerPage() As Integer
		  Return Max(1, Floor((Height - (2 * kPadding)) / BaseRowHeight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function RunLength(line As String, position As Integer, direction As Integer, character As String) As Integer
		  // Number of consecutive `character`s starting at position, walking in direction (-1 or 1)
		  Var count As Integer
		  Var p As Integer = position
		  While p >= 0 And p < line.Length
		    If line.Middle(p, 1) <> character Then Exit While
		    count = count + 1
		    p = p + direction
		  Wend
		  Return count
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 53656C65637473207468652077686F6C6520746578742E
		Sub SelectAll()
		  mAnchorLine = 0
		  mAnchorCol = 0
		  mCaretLine = mLines.LastIndex
		  mCaretCol = mLines(mCaretLine).Length
		  mDesiredX = -1
		  mLastEditKind = kEditOther
		  CaretMoved
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SelectionHasMarker(marker As String) As Boolean
		  // True when the selection on one line is wrapped in the marker, either inside or just around it
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  If sl <> el Then Return False
		  Var line As String = mLines(sl)
		  Var k As Integer = marker.Length
		  Var inside As String = line.Middle(sc, ec - sc)
		  If inside.Length >= 2 * k And inside.Left(k) = marker And inside.Right(k) = marker Then Return True
		  Return sc >= k And line.Middle(sc - k, k) = marker And line.Middle(ec, k) = marker
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SelectLine(lineIndex As Integer)
		  LineBounds(lineIndex, mAnchorLine, mAnchorCol, mCaretLine, mCaretCol)
		  mDesiredX = -1
		  CaretMoved
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SelectRange(startLine As Integer, startCol As Integer, endLine As Integer, endCol As Integer)
		  mAnchorLine = Max(0, Min(startLine, mLines.LastIndex))
		  mAnchorCol = Max(0, Min(startCol, mLines(mAnchorLine).Length))
		  mCaretLine = Max(0, Min(endLine, mLines.LastIndex))
		  mCaretCol = Max(0, Min(endCol, mLines(mCaretLine).Length))
		  mDesiredX = -1
		  CaretMoved
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SelectWordAt(lineIndex As Integer, col As Integer)
		  Var startCol, endCol As Integer
		  WordBounds(lineIndex, col, startCol, endCol)
		  
		  mAnchorLine = lineIndex
		  mAnchorCol = startCol
		  mCaretLine = lineIndex
		  mCaretCol = endCol
		  mDesiredX = -1
		  CaretMoved
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetContent(value As String)
		  // Replaces the whole document; Text and Markdown differ only in how they show it
		  mLines = NormalizedText(value).Split(Chr(10))
		  If mLines.Count = 0 Then mLines.Add("")
		  mCaretLine = 0
		  mCaretCol = 0
		  mAnchorLine = 0
		  mAnchorCol = 0
		  mScrollY = 0
		  mUndoTexts.ResizeTo(-1)
		  mUndoOffsets.ResizeTo(-1)
		  mRedoTexts.ResizeTo(-1)
		  mRedoOffsets.ResizeTo(-1)
		  mLastEditKind = kEditOther
		  TextDidChange
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetCursorKind(kind As Integer)
		  If kind = mCursorKind Then Return
		  mCursorKind = kind
		  Select Case kind
		  Case kCursorLink
		    Self.MouseCursor = System.Cursors.FingerPointer
		  Case kCursorArrow
		    Self.MouseCursor = System.Cursors.StandardPointer
		  Else
		    Self.MouseCursor = System.Cursors.IBeam
		  End Select
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetToolbarState(visible As Boolean, hoverItem As Integer)
		  If Not visible Then hoverItem = -1
		  If visible = mToolbarVisible And hoverItem = mToolbarHoverItem Then Return
		  
		  // Toolbar buttons explain themselves in a tooltip; the developer's tooltip comes back afterwards
		  If hoverItem <> mToolbarHoverItem Then
		    If hoverItem >= 0 Then
		      If Not mToolbarTooltipActive Then mSavedTooltip = Self.Tooltip
		      mToolbarTooltipActive = True
		      Var items() As Integer = ToolbarItems
		      Self.Tooltip = ToolbarTooltip(items(hoverItem))
		    ElseIf mToolbarTooltipActive Then
		      mToolbarTooltipActive = False
		      Self.Tooltip = mSavedTooltip
		    End If
		  End If
		  
		  mToolbarVisible = visible
		  mToolbarHoverItem = hoverItem
		  Refresh(False)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SplitTableCells(line As String, starts() As Integer, ends() As Integer)
		  // Character ranges of the cells' trimmed contents. Pipes inside `code` or escaped as \| do not split.
		  starts.ResizeTo(-1)
		  ends.ResizeTo(-1)
		  Var chars() As String
		  If line.Length > 0 Then chars = line.Split("")
		  Var n As Integer = chars.Count
		  
		  Var bounds() As Integer
		  bounds.Add(-1)
		  Var inCode As Boolean
		  Var i As Integer = 0
		  While i < n
		    Var c As String = chars(i)
		    If c = "\" Then
		      i = i + 2
		      Continue
		    End If
		    If c = "`" Then
		      inCode = Not inCode
		    ElseIf c = "|" And Not inCode Then
		      bounds.Add(i)
		    End If
		    i = i + 1
		  Wend
		  bounds.Add(n)
		  
		  For k As Integer = 0 To bounds.LastIndex - 1
		    Var s As Integer = bounds(k) + 1
		    Var e As Integer = bounds(k + 1)
		    While s < e And IsSpace(chars(s))
		      s = s + 1
		    Wend
		    While e > s And IsSpace(chars(e - 1))
		      e = e - 1
		    Wend
		    // Outer pipes ("| a | b |") leave empty pieces at both ends; those are not cells
		    If s = e And bounds.Count > 2 And (k = 0 Or k = bounds.LastIndex - 1) Then Continue
		    starts.Add(s)
		    ends.Add(e)
		  Next
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StartImageDownload(url As String)
		  Var connection As New URLConnection
		  AddHandler connection.ContentReceived, WeakAddressOf ImageDownloaded
		  AddHandler connection.Error, WeakAddressOf ImageDownloadFailed
		  // Keeps the connection alive until it finishes, and remembers which source it loads
		  If mDownloads = Nil Then mDownloads = New Dictionary
		  mDownloads.Value(connection) = url
		  connection.Send("GET", url)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StartRow(lineIndex As Integer, top As Double, height As Double, baseline As Double, startCol As Integer, startX As Double)
		  Var row As MDRow
		  row.Line = lineIndex
		  row.Top = top
		  row.Height = height
		  row.Baseline = baseline
		  row.StartCol = startCol
		  row.EndCol = startCol
		  row.StartX = startX
		  row.FirstFragment = mFragments.Count
		  row.LastFragment = mFragments.Count - 1
		  row.SubHeight = height
		  mRows.Add(row)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StepPosition(direction As Integer, byWord As Boolean, ByRef lineIndex As Integer, ByRef col As Integer)
		  // Moves one character or one word left (direction < 0) or right, crossing line breaks
		  Var line As String = mLines(lineIndex)
		  
		  If direction < 0 Then
		    If col = 0 Then
		      If lineIndex > 0 Then
		        lineIndex = lineIndex - 1
		        col = mLines(lineIndex).Length
		      End If
		      Return
		    End If
		    If Not byWord Then
		      col = col - 1
		      Return
		    End If
		    While col > 0 And Not IsWordCharacter(line.Middle(col - 1, 1))
		      col = col - 1
		    Wend
		    While col > 0 And IsWordCharacter(line.Middle(col - 1, 1))
		      col = col - 1
		    Wend
		  Else
		    Var n As Integer = line.Length
		    If col >= n Then
		      If lineIndex < mLines.LastIndex Then
		        lineIndex = lineIndex + 1
		        col = 0
		      End If
		      Return
		    End If
		    If Not byWord Then
		      col = col + 1
		      Return
		    End If
		    While col < n And Not IsWordCharacter(line.Middle(col, 1))
		      col = col + 1
		    Wend
		    While col < n And IsWordCharacter(line.Middle(col, 1))
		      col = col + 1
		    Wend
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub StopClickFreeze()
		  mClickFreeze = False
		  If mClickTimer <> Nil Then mClickTimer.RunMode = Timer.RunModes.Off
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function SymbolWidth(g As Graphics, flags As Integer, scale As Double) As Double
		  // Width of a drawn replacement for list syntax: a bullet for "-", a checkbox for "[ ]"
		  ApplyFont(g, 0, scale)
		  If (flags And kFlagBullet) <> 0 Then Return g.TextWidth("•")
		  Return Round(g.FontAscent * 0.9) + 2
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TableBounds(table As Integer, ByRef x As Double, ByRef width As Double)
		  Var first As Integer = mTableFirstColumn(table)
		  Var last As Integer = first + mTableColumnCount(table) - 1
		  x = mTableColumnX(first)
		  width = mTableColumnX(last) + mTableColumnW(last) - x
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TableLineFlags(lineIndex As Integer, flags() As Integer)
		  // Inline Markdown inside the cells; pipes and cell padding are hidden, the header is bold on orange
		  Var line As String = mLines(lineIndex)
		  Var n As Integer = line.Length
		  ApplyInlineFlags(line, flags, 0)
		  
		  Var starts() As Integer
		  Var ends() As Integer
		  SplitTableCells(line, starts, ends)
		  Var inCell() As Boolean
		  inCell.ResizeTo(n - 1)
		  For k As Integer = 0 To starts.LastIndex
		    For c As Integer = starts(k) To ends(k) - 1
		      inCell(c) = True
		    Next
		  Next
		  For c As Integer = 0 To n - 1
		    If Not inCell(c) Then flags(c) = flags(c) Or kFlagHidden
		  Next
		  
		  If mBlockKinds(lineIndex) = kKindTableHeader Then AddFlags(flags, 0, n, kFlagBold Or kFlagOnAccent)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub TextDidChange()
		  mLayoutDirty = True
		  mDesiredX = -1
		  CaretMoved
		  RaiseEvent TextChanged
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ThumbHeight() As Double
		  Return Max(kMinimumThumbHeight, (Height - 4) * Height / Max(1, mContentHeight))
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub ToggleInlineMarker(marker As String)
		  // Bold, italic, strikethrough and code: wraps the selection, or removes the formatting
		  // when the selection already is (or sits inside) text formatted this way
		  If mReadOnly Then Return
		  Var sl, sc, el, ec As Integer
		  GetSelection(sl, sc, el, ec)
		  Var k As Integer = marker.Length
		  Var markerCharacter As String = marker.Left(1)
		  
		  If sl <> el Then
		    // Inline Markdown cannot span lines: format the selected part of every line on its own
		    Var parts() As String
		    For i As Integer = sl To el
		      Var line As String = mLines(i)
		      Var a As Integer = 0
		      Var b As Integer = line.Length
		      If i = sl Then a = sc
		      If i = el Then b = ec
		      Var piece As String = line.Middle(a, b - a)
		      Var core As String = piece.Trim
		      If core <> "" Then
		        Var leading As Integer = piece.Length - piece.TrimLeft.Length
		        piece = piece.Left(leading) + marker + core + marker + piece.Middle(leading + core.Length)
		      End If
		      parts.Add(piece)
		    Next
		    ReplaceSelection(String.FromArray(parts, Chr(10)), kEditOther)
		    mAnchorLine = sl
		    mAnchorCol = sc
		    CaretMoved
		    Return
		  End If
		  
		  Var line As String = mLines(sl)
		  If sc = ec Then
		    // No selection: insert an empty pair and put the caret between the markers
		    ReplaceSelection(marker + marker, kEditOther)
		    MoveCaret(sl, sc + k, False)
		    Return
		  End If
		  
		  Var selected As String = line.Middle(sc, ec - sc)
		  
		  // The selection includes the markers: **text**
		  Var leadingRun As Integer = RunLength(selected, 0, 1, markerCharacter)
		  Var trailingRun As Integer = RunLength(selected, selected.Length - 1, -1, markerCharacter)
		  If selected.Length > 2 * k And leadingRun < selected.Length And MarkerRunMatches(leadingRun, markerCharacter, k) And MarkerRunMatches(trailingRun, markerCharacter, k) Then
		    Var inner As String = selected.Middle(k, selected.Length - (2 * k))
		    ReplaceSelection(inner, kEditOther)
		    SelectRange(sl, sc, sl, sc + inner.Length)
		    Return
		  End If
		  
		  // The markers surround the selection: **[text]**
		  Var runBefore As Integer = RunLength(line, sc - 1, -1, markerCharacter)
		  Var runAfter As Integer = RunLength(line, ec, 1, markerCharacter)
		  If MarkerRunMatches(runBefore, markerCharacter, k) And MarkerRunMatches(runAfter, markerCharacter, k) Then
		    SelectRange(sl, sc - k, sl, ec + k)
		    ReplaceSelection(selected, kEditOther)
		    SelectRange(sl, sc - k, sl, sc - k + selected.Length)
		    Return
		  End If
		  
		  ReplaceSelection(marker + selected + marker, kEditOther)
		  SelectRange(sl, sc + k, sl, sc + k + selected.Length)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5772617073207468652073656C656374696F6E20696E202A2A206F722072656D6F7665732069742E
		Sub ToggleSelectionBold()
		  ToggleInlineMarker("**")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5772617073207468652073656C656374696F6E20696E202A206F722072656D6F7665732069742E
		Sub ToggleSelectionItalic()
		  ToggleInlineMarker("*")
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 4D61726B646F776E20686173206E6F20756E6465726C696E652073796E7461782C20736F207468697320646F6573206E6F7468696E672E204B65707420666F72204465736B746F70546578744172656120636F6D7061746962696C6974792E
		Sub ToggleSelectionUnderline()
		  // Markdown has no underline syntax; kept for DesktopTextArea compatibility
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarAllowed() As Boolean
		  // While read-only, the toolbar is reduced to the view toggle (see ToolbarItems),
		  // shown only when ReadOnlyRenderToggle allows it
		  If mReadOnly And Not mReadOnlyRenderToggle Then Return False
		  Return mHasToolbar
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarButtonWidth() As Double
		  // The read-only view toggle is a smaller button than the editing toolbar's
		  If mReadOnly Then Return kViewButtonWidth
		  Return kToolbarButtonWidth
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarContains(x As Integer, y As Integer) As Boolean
		  If Not ToolbarAllowed Then Return False
		  LayoutToolbar
		  Return mToolbarVisibleCount > 0 And x >= mToolbarLeft And x < mToolbarLeft + mToolbarWidth And y >= kToolbarMargin And y < kToolbarMargin + ToolbarHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarHeight() As Double
		  If mReadOnly Then Return kViewButtonHeight
		  Return kToolbarHeight
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarInset() As Double
		  // The read-only view toggle has no frame around its button
		  If mReadOnly Then Return 0
		  Return kToolbarInset
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarItemAt(x As Integer, y As Integer) As Integer
		  // Index of the toolbar button under the point, or -1
		  If Not ToolbarContains(x, y) Then Return -1
		  Var items() As Integer = ToolbarItems
		  For i As Integer = 0 To mToolbarVisibleCount - 1
		    If items(i) >= 0 And x >= mToolbarX(i) And x < mToolbarX(i) + ToolbarButtonWidth Then Return i
		  Next
		  Return -1
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarItems() As Integer()
		  // Toolbar buttons in order; kToolSeparator draws a divider between groups.
		  // A read-only editor can't be edited, so it only gets the view toggle.
		  If mReadOnly Then
		    Var viewItems() As Integer
		    viewItems.Add(kToolPlainText)
		    Return viewItems
		  End If
		  If mToolbarItems.Count = 0 Then
		    mToolbarItems = Array(kToolPlainText, kToolSeparator, _
		    kToolBold, kToolItalic, kToolStrike, kToolCode, kToolSeparator, _
		    kToolH1, kToolH2, kToolH3, kToolSeparator, _
		    kToolBullet, kToolNumbered, kToolTask, kToolQuote, kToolSeparator, _
		    kToolLink, kToolImage, kToolCodeBlock, kToolTable, kToolRule)
		  End If
		  Return mToolbarItems
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ToolbarTooltip(action As Integer) As String
		  Var shortcut As String
		  #If TargetMacOS Then
		    shortcut = "⌘"
		  #Else
		    shortcut = "Ctrl+"
		  #EndIf
		  
		  Select Case action
		  Case kToolBold
		    Return kLangBold + " (" + shortcut + "B)"
		  Case kToolItalic
		    Return kLangItalic + " (" + shortcut + "I)"
		  Case kToolStrike
		    Return kLangStrikethrough
		  Case kToolCode
		    Return kLangInlineCode
		  Case kToolH1
		    Return kLangHeading1
		  Case kToolH2
		    Return kLangHeading2
		  Case kToolH3
		    Return kLangHeading3
		  Case kToolBullet
		    Return kLangBulletedList
		  Case kToolNumbered
		    Return kLangNumberedList
		  Case kToolTask
		    Return kLangTaskList
		  Case kToolQuote
		    Return kLangQuote
		  Case kToolLink
		    Return kLangLink + " (" + shortcut + "K)"
		  Case kToolImage
		    Return kLangImage
		  Case kToolCodeBlock
		    Return kLangCodeBlock
		  Case kToolTable
		    Return kLangTable
		  Case kToolRule
		    Return kLangHorizontalRule
		  Case kToolPlainText
		    If mRenderMarkdown Then Return kLangShowPlainText
		    Return kLangShowFormattedText
		  End Select
		  Return ""
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 54616B6573206261636B20746865206C617374206368616E67652E20547970696E6720697320756E646F6E6520776F726420627920776F72642E
		Sub Undo()
		  If mUndoTexts.Count = 0 Or mReadOnly Then Return
		  
		  mRedoTexts.Add(String.FromArray(mLines, Chr(10)))
		  mRedoOffsets.Add(OffsetOf(mCaretLine, mCaretCol))
		  RestoreState(mUndoTexts.Pop, mUndoOffsets.Pop)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateCurrentLine()
		  // The caret line is frozen while drag-selecting so text does not jump under the mouse,
		  // and right after a click so a following click of a double click hits the same layout
		  If mMouseSelecting Or mClickFreeze Then Return
		  
		  Var newLine As Integer = -1
		  If mHasFocus Then
		    newLine = mCaretLine
		    // A selection ending at the very start of a line (e.g. a triple-clicked line including
		    // its line break) does not touch that line; the line it really ends on is the caret line
		    If mCaretCol = 0 And mCaretLine > mAnchorLine Then newLine = mCaretLine - 1
		  End If
		  If newLine <> mCurrentLine Then
		    mCurrentLine = newLine
		    mLayoutDirty = True
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateMouseCursor()
		  // Arrow over the toolbar and the scroll bar, hand while Cmd (macOS) / Ctrl (Windows, Linux) is held over a link
		  If mToolbarVisible And ToolbarContains(mMouseX, mMouseY) Then
		    SetCursorKind(kCursorArrow)
		  ElseIf mDraggingScrollbar Or (mHasVerticalScrollbar And mContentHeight > Height And mMouseX >= Width - kScrollbarHitWidth) Then
		    SetCursorKind(kCursorArrow)
		  ElseIf LinkModifierDown(True) And Not mMouseSelecting And LinkAt(mMouseX, mMouseY) <> "" Then
		    SetCursorKind(kCursorLink)
		  Else
		    SetCursorKind(kCursorText)
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub UpdateToolbarHover(x As Integer, y As Integer)
		  // The toolbar shows while the mouse is within ToolbarRevealDistance of the top edge,
		  // and stays while the mouse is on it
		  If mToolbarPressed <> -1 Then Return
		  Var inside As Boolean = x >= 0 And x < Width And y >= 0 And y < Height
		  If mReadOnly Then
		    // The read-only view toggle shows while the mouse is anywhere over the editor, not only near the top edge
		    Var hoverItem As Integer = -1
		    If inside Then hoverItem = ToolbarItemAt(x, y)
		    SetToolbarState(ToolbarAllowed And inside, hoverItem)
		    Return
		  End If
		  Var show As Boolean = ToolbarAllowed And Not mMouseSelecting And inside And (y <= mToolbarRevealDistance Or (mToolbarVisible And ToolbarContains(x, y)))
		  Var hover As Integer = -1
		  If show Then hover = ToolbarItemAt(x, y)
		  SetToolbarState(show, hover)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WheelStep() As Double
		  // Pixels scrolled per unit of MouseWheel's deltaY
		  #If TargetWindows Then
		    // Xojo already reports one unit per line, following the system's wheel setting (3 per notch by default)
		    Return BaseRowHeight
		  #ElseIf TargetLinux Then
		    // One wheel notch is one unit; scroll three lines like most Linux applications
		    Return 3 * BaseRowHeight
		  #Else
		    // macOS reports precise, already accelerated deltas
		    Return kWheelStep
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ReadOnlyBackgroundColor() As Color
		  // A read-only TextArea sits on the system fill color. On macOS Color.FillColor is the same white
		  // as an editable text view, so the light gray NSColor.underPageBackgroundColor is used instead.
		  #If TargetMacOS Then
		    Declare Function NSClassFromString Lib "Foundation" (className As CFStringRef) As Ptr
		    Declare Function sharedApplication Lib "AppKit" Selector "sharedApplication" (classRef As Ptr) As Ptr
		    Declare Function effectiveAppearance Lib "AppKit" Selector "effectiveAppearance" (app As Ptr) As Ptr
		    Declare Function currentAppearance Lib "AppKit" Selector "currentAppearance" (classRef As Ptr) As Ptr
		    Declare Sub setCurrentAppearance Lib "AppKit" Selector "setCurrentAppearance:" (classRef As Ptr, appearance As Ptr)
		    Declare Function underPageBackgroundColor Lib "AppKit" Selector "underPageBackgroundColor" (classRef As Ptr) As Ptr
		    Declare Function sRGBColorSpace Lib "AppKit" Selector "sRGBColorSpace" (classRef As Ptr) As Ptr
		    Declare Function colorUsingColorSpace Lib "AppKit" Selector "colorUsingColorSpace:" (colorRef As Ptr, space As Ptr) As Ptr
		    Declare Function redComponent Lib "AppKit" Selector "redComponent" (colorRef As Ptr) As CGFloat
		    Declare Function greenComponent Lib "AppKit" Selector "greenComponent" (colorRef As Ptr) As CGFloat
		    Declare Function blueComponent Lib "AppKit" Selector "blueComponent" (colorRef As Ptr) As CGFloat

		    // The dynamic system color resolves against the current appearance, so make that the app's appearance
		    Var appearanceClass As Ptr = NSClassFromString("NSAppearance")
		    Var previous As Ptr = currentAppearance(appearanceClass)
		    setCurrentAppearance(appearanceClass, effectiveAppearance(sharedApplication(NSClassFromString("NSApplication"))))
		    Var rgb As Ptr = colorUsingColorSpace(underPageBackgroundColor(NSClassFromString("NSColor")), sRGBColorSpace(NSClassFromString("NSColorSpace")))
		    Var result As Color = Color.FillColor
		    If rgb <> Nil Then
		      result = Color.RGB(Round(redComponent(rgb) * 255), Round(greenComponent(rgb) * 255), Round(blueComponent(rgb) * 255))
		    End If
		    setCurrentAppearance(appearanceClass, previous)
		    Return result
		  #Else
		    Return Color.FillColor
		  #EndIf
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UseDarkColors() As Boolean
		  // Printed pages are always light, whatever the appearance of the app
		  Return Color.IsDarkMode And mPrintWidth = 0
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub WordBounds(lineIndex As Integer, col As Integer, ByRef startCol As Integer, ByRef endCol As Integer)
		  // The word at col; outside a word, the single character at col
		  Var line As String = mLines(lineIndex)
		  Var n As Integer = line.Length
		  startCol = col
		  endCol = col
		  
		  If col < n And IsWordCharacter(line.Middle(col, 1)) Or (col > 0 And IsWordCharacter(line.Middle(col - 1, 1))) Then
		    While startCol > 0 And IsWordCharacter(line.Middle(startCol - 1, 1))
		      startCol = startCol - 1
		    Wend
		    While endCol < n And IsWordCharacter(line.Middle(endCol, 1))
		      endCol = endCol + 1
		    Wend
		  ElseIf col < n Then
		    endCol = col + 1
		  End If
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function XForCol(rowIndex As Integer, col As Integer) As Double
		  // Horizontal position of a column on the given row (relative to the content's left edge)
		  Var row As MDRow = mRows(rowIndex)
		  Var x As Double = row.StartX
		  
		  For f As Integer = row.FirstFragment To row.LastFragment
		    Var frag As MDFragment = mFragments(f)
		    If col < frag.EndCol Then
		      If col <= frag.StartCol Or (frag.Flags And kFlagHidden) <> 0 Then Return frag.X
		      If (frag.Flags And kSymbolFlags) <> 0 Then Return frag.X + frag.Width
		      Var g As Graphics = MeasureGraphics
		      ApplyFont(g, frag.Flags, frag.Scale)
		      Return frag.X + g.TextWidth(mLines(frag.Line).Middle(frag.StartCol, col - frag.StartCol))
		    End If
		    x = frag.X + frag.Width
		  Next
		  Return x
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0, Description = 526169736564207768656E2074686520636F6E74726F6C2069732061626F757420746F20636C6F73652E
		Event Closing()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 41646420796F7572206F776E206974656D7320746F20626173652E2054686579206170706561722061626F7665204375742C20436F70792C20506173746520616E642053656C65637420416C6C2E2052657475726E205472756520746F2073686F77206F6E6C7920796F7572206974656D732E
		Event ConstructContextualMenu(base As DesktopMenuItem, x As Integer, y As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 52616973656420666F7220636F6E7465787475616C206D656E75206974656D7320796F7520616464656420696E20436F6E737472756374436F6E7465787475616C4D656E752E2052657475726E2054727565207768656E20796F752068616E646C65642069742E
		Event ContextualMenuItemSelected(selectedItem As DesktopMenuItem) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E2074686520656469746F72206C6F73657320746865206B6579626F61726420666F6375732E
		Event FocusLost()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E2074686520656469746F72206765747320746865206B6579626F61726420666F6375732E
		Event FocusReceived()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 4C65747320746865206170706C69636174696F6E20737570706C7920746865207069637475726520666F7220616E20696D61676520736F757263652E2052657475726E204E696C20746F206C6574204D61726B646F776E41726561206C6F61642069742E
		Event ImageRequested(source As String) As Picture
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564206265666F72652074686520656469746F722068616E646C65732061206B65792E2052657475726E205472756520746F2073746F702074686520656469746F722066726F6D2068616E646C696E672069742E
		Event KeyDown(key As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 52616973656420666F7220436D642F4374726C2B636C69636B206F6E2061206C696E6B2E2052657475726E205472756520746F2068616E646C6520697420796F757273656C662E
		Event LinkClicked(url As String) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E20746865206D6F75736520627574746F6E20676F657320646F776E20696E2074686520656469746F722E2052657475726E205472756520746F2068616E646C652074686520636C69636B20796F757273656C6620616E642072656365697665204D6F7573654472616720616E64204D6F75736555702E
		Event MouseDown(x As Integer, y As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768696C6520746865206D6F757365206973206472616767656420616674657220796F752072657475726E656420547275652066726F6D204D6F757365446F776E2E
		Event MouseDrag(x As Integer, y As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E20746865206D6F757365206D6F76657320696E746F2074686520656469746F722E
		Event MouseEnter()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E20746865206D6F757365206C65617665732074686520656469746F722E
		Event MouseExit()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E20746865206D6F757365206D6F766573206F7665722074686520656469746F722E
		Event MouseMove(x As Integer, y As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E20746865206D6F75736520627574746F6E20676F657320757020616674657220796F752072657475726E656420547275652066726F6D204D6F757365446F776E2E
		Event MouseUp(x As Integer, y As Integer)
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564206265666F72652074686520656469746F72207363726F6C6C732E2052657475726E205472756520746F2073746F702069742066726F6D207363726F6C6C696E672E
		Event MouseWheel(x As Integer, y As Integer, deltaX As Integer, deltaY As Integer) As Boolean
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E2074686520636F6E74726F6C206973206372656174656420616E642061626F757420746F2062652073686F776E2E
		Event Opening()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 5261697365642061667465722074686520656469746F7220647265772069747320636F6E74656E742C20736F20796F752063616E2064726177206F6E20746F70206F662069742E2054686520746F6F6C62617220697320647261776E20616674657220746869732E
		Event Paint(g As Graphics, areas() As Rect)
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E20746865206361726574206D6F766573206F72207468652073656C656374696F6E206368616E6765732E
		Event SelectionChanged()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 526169736564207768656E207468652074657874206368616E6765732C20627920747970696E67206F722066726F6D20636F64652E
		Event TextChanged()
	#tag EndHook

	#tag Hook, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792E204D61726B646F776E4172656120646F6573206E6F742075736520612076616C69646174696F6E206D61736B2C20736F2074686973206973206E65766572207261697365642E
		Event ValidationFailed(invalidText As String, startPosition As Integer)
	#tag EndHook


	#tag Note, Name = HowTo
		MarkdownArea: a live-rendering Markdown editor, written in pure Xojo.
		
		SETUP
		1. Add MarkdownArea.xojo_code to your project.
		2. Drag a DesktopCanvas onto a window and set its Super to MarkdownArea.
		   To replace an existing DesktopTextArea, change its Super to MarkdownArea instead.
		   The values you set in the Inspector carry over and your code keeps compiling.
		3. Optional, for printing: also add the MarkdownPrinting module (MarkdownPrinting.xojo_code
		   and the MarkdownPrinting folder with MarkdownTextPrinter.xojo_code).
		
		LOADING AND SAVING
		The property you load the text through picks the view:
		
		  MarkdownArea1.Markdown = readme   // shows the text rendered as Markdown
		  MarkdownArea1.Text = notes        // shows the text as plain text, like a DesktopTextArea
		  MarkdownArea1.RenderMarkdown = True // switches the view, the text stays the same
		
		Markdown and Text always return the same raw, unchanged text, so save either one:
		
		  Var markdown As String = MarkdownArea1.Markdown
		
		Setting Markdown or Text to "" clears the editor and keeps the current view.
		To show design-time text rendered, set Markdown in the Opening event.
		
		COMMON TASKS
		  MarkdownArea1.BaseFolder = documentFile.Parent  // resolves relative image paths
		  MarkdownArea1.AddText(EndOfLine + "- [ ] New task") // appends text at the end
		  MarkdownArea1.ReadOnly = True        // users can select and copy, but not edit
		  MarkdownArea1.ReadOnlyRenderToggle = False // hides the view button while ReadOnly
		  MarkdownArea1.HasToolbar = False     // no formatting toolbar
		  MarkdownArea1.TableAlignment = MarkdownArea.TableAlignments.Center
		  MarkdownArea1.TableFullWidth = True  // stretches tables to the editor width
		  MarkdownArea1.LineSpacing = 1.5
		  MarkdownArea1.ToggleSelectionBold    // wraps the selection in ** or removes it
		
		EVENTS
		LinkClicked(url) As Boolean
		  Raised when a link is Cmd/Ctrl-clicked. Return True to handle it yourself:
		
		  If url.BeginsWith("app://") Then
		    HandleInternalLink(url)
		    Return True
		  End If
		
		ImageRequested(source) As Picture
		  Supply pictures from a database or your app's resources. Return Nil to let
		  MarkdownArea load http(s) URLs, data: URIs and local files itself:
		
		  If source.BeginsWith("db:") Then Return LoadPictureFromDatabase(source.Middle(3))
		  Return Nil
		
		TextChanged, SelectionChanged and the usual DesktopCanvas events work as expected.
		
		PRINTING (needs the MarkdownPrinting module)
		  Const kMargin As Integer = 36
		  Var settings As New PrinterSetup
		  Var g As Graphics = settings.ShowPrinterDialog(Self)
		  If g = Nil Then Return
		
		  Var printer As MarkdownTextPrinter = MarkdownArea1.StyledTextPrinter(g, g.Width - (2 * kMargin))
		  Do
		    printer.DrawBlock(kMargin, kMargin, g.Height - (2 * kMargin))
		    If printer.EOF Then Exit Do
		    g.NextPage
		  Loop
		
		DESKTOPTEXTAREA COMPATIBILITY
		Some DesktopTextArea members are only there so existing code compiles and have
		no effect, because Markdown keeps its formatting in the text itself. Their
		descriptions say "Only for DesktopTextArea compatibility".
		
		More details are in README.md.
	#tag EndNote


	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c4DA3FF
			  Return &c0B62D6
			End Get
		#tag EndGetter
		Private AccentColor As Color
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		AllowSpellChecking As Boolean
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792E20466F726D617474696E6720636F6D65732066726F6D20746865204D61726B646F776E20697473656C662E
		AllowStyledText As Boolean = True
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 436F6C6F722074686520656469746F722069732066696C6C65642077697468207768656E204861734261636B67726F756E64436F6C6F7220697320547275652E
		#tag Getter
			Get
			  Return mBackgroundColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBackgroundColor = value
			  Refresh(False)
			End Set
		#tag EndSetter
		BackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 466F6C646572207468617420696D61676520706174687320696E20746865204D61726B646F776E206172652072656C617469766520746F2E
		#tag Getter
			Get
			  Return mBaseFolder
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBaseFolder = value
			  // Relative image paths may now resolve differently, so load images again
			  mImageCache = Nil
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		BaseFolder As FolderItem
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 447261777320616C6C207465787420626F6C642C206C696B65204465736B746F7054657874417265612E426F6C642E
		#tag Getter
			Get
			  Return mBold
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBold = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		Bold As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c4A4A4A
			  Return &cBEBEBE
			End Get
		#tag EndGetter
		Private BorderColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c2C2C30
			  Return &cF2F2F4
			End Get
		#tag EndGetter
		Private CodeBackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &cF07178
			  Return &cC0392B
			End Get
		#tag EndGetter
		Private CodeColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If mHasBackgroundColor Then Return mBackgroundColor
			  // Like a read-only TextArea, a read-only editor sits on a fill color, but printed pages stay white
			  If mReadOnly And mPrintWidth = 0 Then Return ReadOnlyBackgroundColor
			  If UseDarkColors Then Return &c1E1E1E
			  Return &cFFFFFF
			End Get
		#tag EndGetter
		Private EffectiveBackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If mHasTextColor Then Return mTextColor
			  If mPrintWidth > 0 Then Return &c000000
			  Return Color.TextColor
			End Get
		#tag EndGetter
		Private EffectiveTextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 466F6E7420666F722074686520746578742E20436F646520697320616C7761797320647261776E20696E2061206D6F6E6F73706163656420666F6E742E
		#tag Getter
			Get
			  Return mFontName
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mFontName = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		FontName As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 466F6E742073697A6520696E20706F696E747320666F72206E6F726D616C20746578742E2048656164696E677320616E6420636F646520617265207363616C65642066726F6D2069742E20302075736573207468652073797374656D2073697A652E
		#tag Getter
			Get
			  Return mFontSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mFontSize = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		FontSize As Single
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E20466F6E7453697A6520697320616C7761797320696E20706F696E74732E
		FontUnit As FontUnits
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		Format As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 54686520746578743B2073616D6520617320546578742073696E6365204D61726B646F776E4172656120686173206E6F20666F726D6174206D61736B2E
		#tag Getter
			Get
			  Return Text
			End Get
		#tag EndGetter
		FormattedText As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 5768656E20547275652C2074686520656469746F722069732066696C6C65642077697468204261636B67726F756E64436F6C6F7220696E7374656164206F66207468652073797374656D2074657874206261636B67726F756E642E
		#tag Getter
			Get
			  Return mHasBackgroundColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasBackgroundColor = value
			  Refresh(False)
			End Set
		#tag EndSetter
		HasBackgroundColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4472617773206120626F726465722061726F756E642074686520656469746F722E
		#tag Getter
			Get
			  Return mHasBorder
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasBorder = value
			  Refresh(False)
			End Set
		#tag EndSetter
		HasBorder As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E205465787420616C7761797320777261707320746F2074686520656469746F722077696474682E
		HasHorizontalScrollbar As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 53686F777320746865204D61726B646F776E20746F6F6C626172207768656E20746865206D6F75736520636F6D6573206E6561722074686520746F70206F662074686520656469746F722E
		#tag Getter
			Get
			  Return mHasToolbar
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasToolbar = value
			  If Not value Then SetToolbarState(False, -1)
			  Refresh(False)
			End Set
		#tag EndSetter
		HasToolbar As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 53686F777320746865207363726F6C6C207468756D62207768656E2074686520746578742069732074616C6C6572207468616E2074686520656469746F722E
		#tag Getter
			Get
			  Return mHasVerticalScrollbar
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mHasVerticalScrollbar = value
			  Refresh(False)
			End Set
		#tag EndSetter
		HasVerticalScrollbar As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		HideSelection As Boolean
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		#tag Getter
			Get
			  // Text always wraps, so there is no horizontal scrolling
			  Return 0
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		HorizontalScrollPosition As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 447261777320616C6C2074657874206974616C69632C206C696B65204465736B746F7054657874417265612E4974616C69632E
		#tag Getter
			Get
			  Return mItalic
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mItalic = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		Italic As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E20557365204C696E6553706163696E6720696E73746561642E
		LineHeight As Double
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 4C696E6520686569676874206173206120666163746F72206F662074686520666F6E742773207465787420686569676874202864656661756C7420312E33292E
		#tag Getter
			Get
			  Return mLineSpacing
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLineSpacing = Max(1.0, value)
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		LineSpacing As Double
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mAnchorCol As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mAnchorLine As Integer
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 54686520726177204D61726B646F776E20746578742E2053657474696E6720697420746F2061206E6F6E2D656D70747920737472696E672073686F77732074686520746578742072656E6465726564206173204D61726B646F776E2E
		#tag Getter
			Get
			  Return Text
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Text handed over as Markdown is shown rendered; clearing it keeps the current view
			  If value <> "" Then mRenderMarkdown = True
			  SetContent(value)
			End Set
		#tag EndSetter
		Markdown As String
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4D6178696D756D206C656E677468206F662074686520746578742E2030206D65616E73206E6F206C696D69742E
		MaximumCharactersAllowed As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBackgroundColor As Color = &cFFFFFF
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBaseFolder As FolderItem
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlinkTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBlockKinds() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBold As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaretCol As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaretLine As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaretVisible As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mClickCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mClickFreeze As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mClickTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mContentHeight As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCurrentLine As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCursorKind As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDesiredX As Double = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDoubleClickTicks As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDownloads As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDraggingScrollbar As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDragStartScroll As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mDragStartY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFontName As String = "System"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFontSize As Single = 0
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mFragments() As MDFragment
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasBackgroundColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasBorder As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasFocus As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasTextColor As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasToolbar As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHasVerticalScrollbar As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mHoverTimer As Timer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mImageCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mItalic As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastClickTicks As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastClickX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastClickY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastEditKind As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastSelectionLength As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLastSelectionStart As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLayoutDirty As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLayoutMeasuredInPaint As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLayoutWidth As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineBottom() As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineFirstRow() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineImages() As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineKinds() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineLastRow() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLines() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineSpacing As Double = 1.3
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineTable() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLineTop() As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMeasurePicture As Picture
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseHandledByApp As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseSelecting As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseX As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mMouseY As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOriginEndCol As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOriginEndLine As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOriginStartCol As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mOriginStartLine As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPaintGraphics As Graphics
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrintHeight As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mPrintWidth As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mReadOnly As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mReadOnlyRenderToggle As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRedoOffsets() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRedoTexts() As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRegExCache As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRenderMarkdown As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mRows() As MDRow
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSavedTooltip As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mScrollY As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableAlign() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableAlignment As TableAlignments = TableAlignments.Left
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableColumnCount() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableColumnW() As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableColumnX() As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableEnd() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableFirstColumn() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableFullWidth As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTableStart() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextAlignment As TextAlignments
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextColor As Color = &c000000
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarHoverItem As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarItems() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarLeft As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarPressed As Integer = -1
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarRevealDistance As Integer = 40
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarTooltipActive As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarVisible As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarVisibleCount As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarWidth As Double
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mToolbarX() As Double
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 5768656E2046616C73652C2052657475726E20616E6420456E74657220646F6E277420696E73657274206C696E6520627265616B732E
		MultiLine As Boolean = True
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUnderline As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUndoOffsets() As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mUndoTexts() As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  Return Color.DisabledTextColor
			End Get
		#tag EndGetter
		Private MutedColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 5768656E20547275652C2074686520746578742063616E2062652073656C656374656420616E6420636F7069656420627574206E6F74206368616E6765642E
		#tag Getter
			Get
			  Return mReadOnly
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mReadOnly = value
			  // A read-only editor shows only the view toggle, once the mouse moves over it (see UpdateToolbarHover)
			  mToolbarPressed = -1
			  SetToolbarState(False, -1)
			  Refresh(False)
			End Set
		#tag EndSetter
		ReadOnly As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 53686F77732074686520736D616C6C204D61726B646F776E2F706C61696E2074657874207669657720627574746F6E20696E2074686520746F7020726967687420636F726E6572207768696C6520526561644F6E6C7920697320547275652E204E6565647320486173546F6F6C6261722E
		#tag Getter
			Get
			  Return mReadOnlyRenderToggle
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value = mReadOnlyRenderToggle Then Return
			  mReadOnlyRenderToggle = value
			  If mReadOnly Then
			    mToolbarPressed = -1
			    SetToolbarState(False, -1)
			    Refresh(False)
			  End If
			End Set
		#tag EndSetter
		ReadOnlyRenderToggle As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 5768656E2046616C73652C2074686520746578742069732073686F776E206173207261772C20756E72656E6465726564204D61726B646F776E2E
		#tag Getter
			Get
			  Return mRenderMarkdown
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mRenderMarkdown = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		RenderMarkdown As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 5468652073656C656374656420726177204D61726B646F776E20746578742E2053657474696E67206974207265706C61636573207468652073656C656374696F6E2E
		#tag Getter
			Get
			  Var sl, sc, el, ec As Integer
			  GetSelection(sl, sc, el, ec)
			  If sl = el Then Return mLines(sl).Middle(sc, ec - sc)
			  
			  Var parts() As String
			  parts.Add(mLines(sl).Middle(sc))
			  For i As Integer = sl + 1 To el - 1
			    parts.Add(mLines(i))
			  Next
			  parts.Add(mLines(el).Left(ec))
			  Return String.FromArray(parts, EndOfLine)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLastEditKind = kEditOther
			  ReplaceSelection(value, kEditOther)
			End Set
		#tag EndSetter
		SelectedText As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		#tag Getter
			Get
			  Return 0
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		SelectionAlignment As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 54727565207768656E207468652073656C656374696F6E206973207772617070656420696E202A2A2E2053657474696E672069742061646473206F722072656D6F76657320746865206D61726B6572732E
		#tag Getter
			Get
			  Return SelectionHasMarker("**")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value <> SelectionHasMarker("**") Then ToggleInlineMarker("**")
			End Set
		#tag EndSetter
		SelectionBold As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If mHasFocus Then Return Color.HighlightColor
			  If UseDarkColors Then Return &c464646
			  Return &cDCDCDC
			End Get
		#tag EndGetter
		Private SelectionColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E2052657475726E7320466F6E744E616D652E
		#tag Getter
			Get
			  Return mFontName
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		SelectionFontName As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E2052657475726E7320466F6E7453697A652E
		#tag Getter
			Get
			  Return mFontSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		SelectionFontSize As Single
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 54727565207768656E207468652073656C656374696F6E206973207772617070656420696E202A2E2053657474696E672069742061646473206F722072656D6F76657320746865206D61726B6572732E
		#tag Getter
			Get
			  Return SelectionHasMarker("*") And Not SelectionHasMarker("**")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value <> SelectionItalic Then ToggleInlineMarker("*")
			End Set
		#tag EndSetter
		SelectionItalic As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4E756D626572206F6620636861726163746572732073656C656374656420696E207468652072617720746578742E2053657474696E67206974206B656570732053656C656374696F6E537461727420616E64206D6F7665732074686520656E642E
		#tag Getter
			Get
			  Var sl, sc, el, ec As Integer
			  GetSelection(sl, sc, el, ec)
			  Return OffsetOf(el, ec) - OffsetOf(sl, sc)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Var sl, sc, el, ec As Integer
			  GetSelection(sl, sc, el, ec)
			  Var lineIndex, col As Integer
			  PositionOfOffset(OffsetOf(sl, sc) + Max(0, value), lineIndex, col)
			  mAnchorLine = sl
			  mAnchorCol = sc
			  MoveCaret(lineIndex, col, True)
			End Set
		#tag EndSetter
		SelectionLength As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 54727565207768656E207468652073656C656374696F6E206973206E65697468657220626F6C64206E6F72206974616C69632E2053657474696E6720697420746F20547275652072656D6F76657320626F74682E
		#tag Getter
			Get
			  Return Not SelectionBold And Not SelectionItalic
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value Then
			    SelectionBold = False
			    SelectionItalic = False
			  End If
			End Set
		#tag EndSetter
		SelectionPlain As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 436861726163746572206F666673657420696E20746865207261772074657874207768657265207468652073656C656374696F6E207374617274732E2053657474696E67206974206D6F7665732074686520636172657420746865726520616E6420636C65617273207468652073656C656374696F6E2E
		#tag Getter
			Get
			  Var sl, sc, el, ec As Integer
			  GetSelection(sl, sc, el, ec)
			  Return OffsetOf(sl, sc)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Var lineIndex, col As Integer
			  PositionOfOffset(value, lineIndex, col)
			  MoveCaret(lineIndex, col, False)
			End Set
		#tag EndSetter
		SelectionStart As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E2052657475726E732054657874436F6C6F722E
		#tag Getter
			Get
			  Return EffectiveTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		SelectionTextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E204D61726B646F776E20686173206E6F20756E6465726C696E652073796E7461782E
		#tag Getter
			Get
			  Return False
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  #Pragma Unused value
			End Set
		#tag EndSetter
		SelectionUnderline As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 41205374796C65645465787420686F6C64696E672074686520726177204D61726B646F776E2E2053657474696E67206974207265706C616365732054657874207769746820746865205374796C656454657874277320706C61696E20746578742E
		#tag Getter
			Get
			  // Markdown carries its formatting in the text itself, so this is a plain copy of Text.
			  // Changing styles on the returned object does not affect the control.
			  Var st As New StyledText
			  st.Text = Text
			  Return st
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value = Nil Then
			    Text = ""
			  Else
			    Text = value.Text
			  End If
			End Set
		#tag EndSetter
		StyledText As StyledText
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 486F77207461626C6573206E6172726F776572207468616E2074686520656469746F722061726520706C61636564202D206C6566742C2063656E746572206F722072696768742E
		#tag Getter
			Get
			  Return mTableAlignment
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTableAlignment = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		TableAlignment As TableAlignments
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c48484E
			  Return &cD5D5DB
			End Get
		#tag EndGetter
		Private TableBorderColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 5472756520737472657463686573206576657279207461626C6520746F207468652066756C6C207769647468206F662074686520656469746F723B2046616C7365206B65657073207461626C6573206173206E6172726F7720617320746865697220636F6E74656E742E
		#tag Getter
			Get
			  Return mTableFullWidth
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value = mTableFullWidth Then Return
			  mTableFullWidth = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		TableFullWidth As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &cB85F14
			  Return &cDB7A1E
			End Get
		#tag EndGetter
		Private TableHeaderBorderColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &cD9731A
			  Return &cF28C28
			End Get
		#tag EndGetter
		Private TableHeaderColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c2B2B2F
			  Return &cF7F7F9
			End Get
		#tag EndGetter
		Private TableStripeColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 546865207261772C20756E72656E646572656420746578742E2053657474696E6720697420746F2061206E6F6E2D656D70747920737472696E672073686F777320746865207465787420617320706C61696E20746578742C206C696B6520612054657874417265612E
		#tag Getter
			Get
			  Return String.FromArray(mLines, EndOfLine)
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // Text handed over as plain text is shown unrendered; clearing it keeps the current view
			  If value <> "" Then mRenderMarkdown = False
			  SetContent(value)
			End Set
		#tag EndSetter
		Text As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 416C69676E73207468652074657874206C6566742C2063656E7465726564206F722072696768742E20436F646520626C6F636B7320616E64207461626C6573206B656570207468656972206F776E20616C69676E6D656E742E
		#tag Getter
			Get
			  Return mTextAlignment
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  If value = mTextAlignment Then Return
			  mTextAlignment = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		TextAlignment As TextAlignments
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 436F6C6F72206F66206E6F726D616C20746578742E20266330303030303020287468652064656661756C74292075736573207468652073797374656D207465787420636F6C6F722C20736F206461726B206D6F646520776F726B732E
		#tag Getter
			Get
			  Return EffectiveTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  // &c000000 (the inspector default) means "use the system text color" so dark mode works
			  mTextColor = value
			  mHasTextColor = value <> &c000000
			  Refresh(False)
			End Set
		#tag EndSetter
		TextColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c323236
			  Return &cFCFCFD
			End Get
		#tag EndGetter
		Private ToolbarBackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c4A4A50
			  Return &cE8E8EC
			End Get
		#tag EndGetter
		Private ToolbarHoverColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h21
		#tag Getter
			Get
			  If UseDarkColors Then Return &c5C5C63
			  Return &cD6D6DC
			End Get
		#tag EndGetter
		Private ToolbarPressedColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 44697374616E636520696E20706F696E74732066726F6D2074686520746F7020656467652077697468696E20776869636820746865206D6F7573652072657665616C732074686520746F6F6C6261722E
		#tag Getter
			Get
			  Return mToolbarRevealDistance
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mToolbarRevealDistance = Max(0, value)
			End Set
		#tag EndSetter
		ToolbarRevealDistance As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0, Description = 556E6465726C696E657320616C6C20746578742C206C696B65204465736B746F7054657874417265612E556E6465726C696E652E
		#tag Getter
			Get
			  Return mUnderline
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mUnderline = value
			  mLayoutDirty = True
			  Refresh(False)
			End Set
		#tag EndSetter
		Underline As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		UnicodeMode As DesktopTextArea.UnicodeModes
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 4F6E6C7920666F72204465736B746F70546578744172656120636F6D7061746962696C6974792C20686173206E6F206566666563742E
		ValidationMask As String
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0, Description = 5363726F6C6C20706F736974696F6E20696E20706F696E74732066726F6D2074686520746F70206F662074686520646F63756D656E742E
		#tag Getter
			Get
			  Return mScrollY
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mScrollY = value
			  ClampScroll
			  Refresh(False)
			End Set
		#tag EndSetter
		VerticalScrollPosition As Integer
	#tag EndComputedProperty


	#tag Constant, Name = kAlignCenter, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAlignLeft, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kAlignRight, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kBlinkPeriod, Type = Double, Dynamic = False, Default = \"530", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCaretWidth, Type = Double, Dynamic = False, Default = \"1.5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCellPadding, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCellPaddingV, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeFontScale, Type = Double, Dynamic = False, Default = \"0.92", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCodeInset, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCursorArrow, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCursorLink, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kCursorText, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kDoubleClickTicks, Type = Double, Dynamic = False, Default = \"30", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEditDelete, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEditOther, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kEditTyping, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagAccent, Type = Double, Dynamic = False, Default = \"1024", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagBold, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagBullet, Type = Double, Dynamic = False, Default = \"128", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagCode, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagHidden, Type = Double, Dynamic = False, Default = \"32", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagImage, Type = Double, Dynamic = False, Default = \"2048", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagItalic, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagLink, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagMuted, Type = Double, Dynamic = False, Default = \"16", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagOnAccent, Type = Double, Dynamic = False, Default = \"4096", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagStrike, Type = Double, Dynamic = False, Default = \"64", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagTaskDone, Type = Double, Dynamic = False, Default = \"512", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFlagTaskOpen, Type = Double, Dynamic = False, Default = \"256", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kFocusFreezePeriod, Type = Double, Dynamic = False, Default = \"100", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kHoverPeriod, Type = Double, Dynamic = False, Default = \"100", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kImageMargin, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindCode, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindFence, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindHeading, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindImage, Type = Double, Dynamic = False, Default = \"7", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindList, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindNormal, Type = Double, Dynamic = False, Default = \"0", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindQuote, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindRule, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindTableDelimiter, Type = Double, Dynamic = False, Default = \"9", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindTableHeader, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kKindTableRow, Type = Double, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kLangBold, Type = String, Dynamic = True, Default = \"Bold", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Fett"
	#tag EndConstant

	#tag Constant, Name = kLangBulletedList, Type = String, Dynamic = True, Default = \"Bulleted list", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Aufz\xC3\xA4hlung"
	#tag EndConstant

	#tag Constant, Name = kLangCodeBlock, Type = String, Dynamic = True, Default = \"Code block", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Codeblock"
	#tag EndConstant

	#tag Constant, Name = kLangCopy, Type = String, Dynamic = True, Default = \"Copy", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Kopieren"
	#tag EndConstant

	#tag Constant, Name = kLangCut, Type = String, Dynamic = True, Default = \"Cut", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Ausschneiden"
	#tag EndConstant

	#tag Constant, Name = kLangHeading1, Type = String, Dynamic = True, Default = \"Heading 1", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"\xC3\x9Cberschrift 1"
	#tag EndConstant

	#tag Constant, Name = kLangHeading2, Type = String, Dynamic = True, Default = \"Heading 2", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"\xC3\x9Cberschrift 2"
	#tag EndConstant

	#tag Constant, Name = kLangHeading3, Type = String, Dynamic = True, Default = \"Heading 3", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"\xC3\x9Cberschrift 3"
	#tag EndConstant

	#tag Constant, Name = kLangHorizontalRule, Type = String, Dynamic = True, Default = \"Horizontal rule", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Trennlinie"
	#tag EndConstant

	#tag Constant, Name = kLangImage, Type = String, Dynamic = True, Default = \"Image", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Bild"
	#tag EndConstant

	#tag Constant, Name = kLangInlineCode, Type = String, Dynamic = True, Default = \"Inline code", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Inline-Code"
	#tag EndConstant

	#tag Constant, Name = kLangItalic, Type = String, Dynamic = True, Default = \"Italic", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Kursiv"
	#tag EndConstant

	#tag Constant, Name = kLangLink, Type = String, Dynamic = True, Default = \"Link", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Link"
	#tag EndConstant

	#tag Constant, Name = kLangNumberedList, Type = String, Dynamic = True, Default = \"Numbered list", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Nummerierte Liste"
	#tag EndConstant

	#tag Constant, Name = kLangPaste, Type = String, Dynamic = True, Default = \"Paste", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Einsetzen"
	#tag EndConstant

	#tag Constant, Name = kLangQuote, Type = String, Dynamic = True, Default = \"Quote", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Zitat"
	#tag EndConstant

	#tag Constant, Name = kLangSelectAll, Type = String, Dynamic = True, Default = \"Select All", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Alles ausw\xC3\xA4hlen"
	#tag EndConstant

	#tag Constant, Name = kLangShowFormattedText, Type = String, Dynamic = True, Default = \"Show Formatted Text", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Formatiert anzeigen"
	#tag EndConstant

	#tag Constant, Name = kLangShowPlainText, Type = String, Dynamic = True, Default = \"Show Plain Text", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Als Klartext anzeigen"
	#tag EndConstant

	#tag Constant, Name = kLangStrikethrough, Type = String, Dynamic = True, Default = \"Strikethrough", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Durchgestrichen"
	#tag EndConstant

	#tag Constant, Name = kLangTable, Type = String, Dynamic = True, Default = \"Table", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Tabelle"
	#tag EndConstant

	#tag Constant, Name = kLangTaskList, Type = String, Dynamic = True, Default = \"Task list", Scope = Private
		#Tag Instance, Platform = Any, Language = de, Definition  = \"Aufgabenliste"
	#tag EndConstant

	#tag Constant, Name = kLineBreakWidth, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMaxUndo, Type = Double, Dynamic = False, Default = \"200", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuTagCopy, Type = String, Dynamic = False, Default = \"MarkdownArea.Copy", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuTagCut, Type = String, Dynamic = False, Default = \"MarkdownArea.Cut", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuTagPaste, Type = String, Dynamic = False, Default = \"MarkdownArea.Paste", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMenuTagSelectAll, Type = String, Dynamic = False, Default = \"MarkdownArea.SelectAll", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumColumnWidth, Type = Double, Dynamic = False, Default = \"36", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumContentWidth, Type = Double, Dynamic = False, Default = \"20", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kMinimumThumbHeight, Type = Double, Dynamic = False, Default = \"24", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kPadding, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kQuoteInset, Type = Double, Dynamic = False, Default = \"14", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kScrollbarHitWidth, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kScrollbarReserve, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kSymbolFlags, Type = Double, Dynamic = False, Default = \"2944", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarButtonWidth, Type = Double, Dynamic = False, Default = \"28", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarGap, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarHeight, Type = Double, Dynamic = False, Default = \"32", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarInset, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarMargin, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarSeparatorWidth, Type = Double, Dynamic = False, Default = \"9", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolbarSwallow, Type = Double, Dynamic = False, Default = \"-2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolBold, Type = Double, Dynamic = False, Default = \"1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolBullet, Type = Double, Dynamic = False, Default = \"8", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolCode, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolCodeBlock, Type = Double, Dynamic = False, Default = \"13", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolH1, Type = Double, Dynamic = False, Default = \"5", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolH2, Type = Double, Dynamic = False, Default = \"6", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolH3, Type = Double, Dynamic = False, Default = \"7", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolImage, Type = Double, Dynamic = False, Default = \"17", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolItalic, Type = Double, Dynamic = False, Default = \"2", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolLink, Type = Double, Dynamic = False, Default = \"12", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolNumbered, Type = Double, Dynamic = False, Default = \"9", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolPlainText, Type = Double, Dynamic = False, Default = \"16", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolQuote, Type = Double, Dynamic = False, Default = \"11", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolRule, Type = Double, Dynamic = False, Default = \"15", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolSeparator, Type = Double, Dynamic = False, Default = \"-1", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolStrike, Type = Double, Dynamic = False, Default = \"3", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolTable, Type = Double, Dynamic = False, Default = \"14", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kToolTask, Type = Double, Dynamic = False, Default = \"10", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kViewButtonHeight, Type = Double, Dynamic = False, Default = \"22", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kViewButtonWidth, Type = Double, Dynamic = False, Default = \"30", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kWheelStep, Type = Double, Dynamic = False, Default = \"4", Scope = Private
	#tag EndConstant


	#tag Structure, Name = MDFragment, Flags = &h21
		Line As Integer
		  StartCol As Integer
		  EndCol As Integer
		  X As Double
		  Width As Double
		  Flags As Integer
		  Scale As Double
		DY As Double
	#tag EndStructure

	#tag Structure, Name = MDRow, Flags = &h21
		Line As Integer
		  Top As Double
		  Height As Double
		  Baseline As Double
		  StartCol As Integer
		  EndCol As Integer
		  StartX As Double
		  FirstFragment As Integer
		  LastFragment As Integer
		SubHeight As Double
	#tag EndStructure


	#tag Enum, Name = TableAlignments, Type = Integer, Flags = &h0
		Left
		  Center
		Right
	#tag EndEnum


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
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="Integer"
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabPanelIndex"
			Visible=false
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabStop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowAutoDeactivate"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Backdrop"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="Picture"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Tooltip"
			Visible=true
			Group="Appearance"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocusRing"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowFocus"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowTabs"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Transparent"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Text"
			Visible=true
			Group="Initial State"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="RenderMarkdown"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReadOnly"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ReadOnlyRenderToggle"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBorder"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasBackgroundColor"
			Visible=true
			Group="Appearance"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackgroundColor"
			Visible=true
			Group="Appearance"
			InitialValue="&cFFFFFF"
			Type="Color"
			EditorType="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextColor"
			Visible=true
			Group="Appearance"
			InitialValue="&c000000"
			Type="Color"
			EditorType="Color"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontName"
			Visible=true
			Group="Font"
			InitialValue="System"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontSize"
			Visible=true
			Group="Font"
			InitialValue="0"
			Type="Single"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LineSpacing"
			Visible=true
			Group="Font"
			InitialValue="1.3"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TableAlignment"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="TableAlignments"
			EditorType="Enum"
			#tag EnumValues
				"0 - Left"
				"1 - Center"
				"2 - Right"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="TableFullWidth"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasToolbar"
			Visible=true
			Group="Toolbar"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ToolbarRevealDistance"
			Visible=true
			Group="Toolbar"
			InitialValue="40"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectedText"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionLength"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionStart"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="VerticalScrollPosition"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Bold"
			Visible=true
			Group="Font"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Italic"
			Visible=true
			Group="Font"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Underline"
			Visible=true
			Group="Font"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="FontUnit"
			Visible=true
			Group="Font"
			InitialValue="0"
			Type="FontUnits"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Pixel"
				"2 - Point"
				"3 - Inches"
				"4 - Millimeter"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="LineHeight"
			Visible=true
			Group="Font"
			InitialValue="0"
			Type="Double"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextAlignment"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="TextAlignments"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Left"
				"2 - Center"
				"3 - Right"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="MultiLine"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowStyledText"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="AllowSpellChecking"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HideSelection"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="MaximumCharactersAllowed"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Format"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ValidationMask"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UnicodeMode"
			Visible=true
			Group="Behavior"
			InitialValue="1"
			Type="DesktopTextArea.UnicodeModes"
			EditorType="Enum"
			#tag EnumValues
				"0 - Native"
				"1 - Characters"
				"2 - Codepoints"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasVerticalScrollbar"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="HasHorizontalScrollbar"
			Visible=true
			Group="Appearance"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Markdown"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="FormattedText"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="HorizontalScrollPosition"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionAlignment"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionBold"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionFontName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionFontSize"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Single"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionItalic"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionPlain"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionTextColor"
			Visible=false
			Group="Behavior"
			InitialValue="&c000000"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectionUnderline"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
