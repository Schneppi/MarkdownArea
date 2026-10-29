#tag Module
Protected Module MarkdownPrinting
	#tag Method, Flags = &h0, Description = 52657475726E732061207072696E7465722074686174207072696E7473207468652072656E6465726564204D61726B646F776E20626C6F636B20627920626C6F636B2C206C696B65204465736B746F7054657874417265612E5374796C6564546578745072696E7465722E20576F726B73206F6E20657665727920706C6174666F726D2E
		Function StyledTextPrinter(Extends area As MarkdownArea, g As Graphics, width As Integer) As MarkdownTextPrinter
		  // DesktopTextArea.StyledTextPrinter only exists on macOS; this one is drawn by MarkdownArea itself.
		  // It lives in this module so MarkdownArea compiles without it in projects that don't print.
		  Return New MarkdownTextPrinter(area, g, width)
		End Function
	#tag EndMethod


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
	#tag EndViewBehavior
End Module
#tag EndModule
