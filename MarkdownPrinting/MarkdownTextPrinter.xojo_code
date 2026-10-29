#tag Class
Class MarkdownTextPrinter
	#tag Method, Flags = &h0
		Sub Constructor(area As MarkdownArea, g As Graphics, width As Double)
		  mArea = area
		  mGraphics = g
		  Self.Width = width
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0, Description = 5072696E747320746865206E6578742070617274206F662074686520646F63756D656E742074686174206669747320696E746F2068656967687420617420782C20792E
		Sub DrawBlock(x As Double, y As Double, height As Double)
		  If EOF Then Return
		  If mArea = Nil Or mGraphics = Nil Then
		    // Nothing to print; end here so a print loop waiting for EOF stops
		    mNextRow = -1
		    Return
		  End If
		  mNextRow = mArea.PrintBlock(mGraphics, Width, mNextRow, x, y, height)
		End Sub
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0, Description = 54727565207768656E207468652077686F6C6520646F63756D656E7420686173206265656E207072696E7465642E
		#tag Getter
			Get
			  Return mNextRow < 0
			End Get
		#tag EndGetter
		EOF As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mArea As MarkdownArea
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mGraphics As Graphics
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mNextRow As Integer
	#tag EndProperty

	#tag Property, Flags = &h0, Description = 5769647468206F6620746865207072696E746564207465787420696E20706F696E74732E
		Width As Double
	#tag EndProperty


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
			InitialValue="-2147483648"
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
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Double"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
