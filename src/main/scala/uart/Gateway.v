//==============================================================================
//	File:     $URL: svn+ssh://repositorypub@repository.eecs.berkeley.edu/public/Projects/GateLib/branches/dev/Publications/Tutorials/Publications/EECS150/Labs/ChipScopeSerial/Solution/Gateway.v $
//	Version:  $Revision: 26904 $
//	Author:   John Wawrzynek
//			 Chris Fletcher (http://cwfletcher.net)
//	Copyright: Copyright 2009-2010 UC Berkeley
//==============================================================================

//==============================================================================
//	Section:	License
//==============================================================================
//	Copyright (c) 2005-2010, Regents of the University of California
//	All rights reserved.
//
//	Redistribution and use in source and binary forms, with or without modification,
//	are permitted provided that the following conditions are met:
//
//		- Redistributions of source code must retain the above copyright notice,
//			this list of conditions and the following disclaimer.
//		- Redistributions in binary form must reproduce the above copyright
//			notice, this list of conditions and the following disclaimer
//			in the documentation and/or other materials provided with the
//			distribution.
//		- Neither the name of the University of California, Berkeley nor the
//			names of its contributors may be used to endorse or promote
//			products derived from this software without specific prior
//			written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//	ANY EXPRESS OR InIMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE InIMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//	ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//==============================================================================

//------------------------------------------------------------------------------
//	Module:	
//	Desc:	
//
//	Author:	John Wawrzynek
//			<a href="http://cwfletcher.net">Chris Fletcher</a>
//	Version:	$Revision: 26904 $
//------------------------------------------------------------------------------
module Gateway(
			//------------------------------------------------------------------
			//	Clock and Related Signals
			//------------------------------------------------------------------
			Clock,
			Reset, 
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	UART Interface
			//------------------------------------------------------------------
			DataIn,
			DataInValid,
			DataInReady,
			DataOut,
			DataOutValid,
			DataOutReady,
			//------------------------------------------------------------------
			
			//------------------------------------------------------------------
			//	Processor Interface
			//------------------------------------------------------------------
			ProcessorDataIn,
			ProcessorDataOut, 
			ProcessorAddress, 
			ProcessorMemRead, 
			ProcessorMemWrite
			//------------------------------------------------------------------
	);
	//--------------------------------------------------------------------------
	//	Parameters
	//--------------------------------------------------------------------------
	parameter		CWidth = 						8, 				// char width
					WWidth = 						32, 			// word width
					AWidth =						WWidth;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Address map
	//--------------------------------------------------------------------------
	localparam		ADDRESS_ControlIn = 			32'hffff_0000,	// control input
					ADDRESS_DataIn =				32'hffff_0004,	// data input 
					ADDRESS_ControlOut =			32'hffff_0008,	// control output
					ADDRESS_DataOut = 				32'hffff_000C;	// data output
	//--------------------------------------------------------------------------

	//--------------------------------------------------------------------------
	//	Clock and Related Signals
	//--------------------------------------------------------------------------
	input wire 										Clock, Reset;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	UART Interface
	//--------------------------------------------------------------------------
	input			[CWidth-1:0]					DataIn;
	input											DataInValid;
	output											DataInReady;
	output			[CWidth-1:0]					DataOut;
	output											DataOutValid;
	input											DataOutReady;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Processor Interface
	//--------------------------------------------------------------------------
	output wire		[WWidth-1:0]					ProcessorDataIn; 
	input wire		[WWidth-1:0]					ProcessorDataOut, ProcessorAddress;
	input wire										ProcessorMemRead, ProcessorMemWrite;
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Wires / Reg Declarations
	//--------------------------------------------------------------------------
	wire			[CWidth-1:0]					DataInReg;
	wire											ControlInReady, PollingControlIn, PollingControlOut, WritingData;
	//--------------------------------------------------------------------------	
	
	//--------------------------------------------------------------------------
	//	Port Assigns
	//--------------------------------------------------------------------------
	assign			DataInReady =					~ControlInReady;
	assign			ProcessorDataIn =				(PollingControlIn) ? {{WWidth-1{1'b0}}, ControlInReady} : (PollingControlOut) ? {{WWidth-1{1'b0}}, DataOutValid} : {{WWidth-CWidth-1{1'b0}}, DataInReg};
	//--------------------------------------------------------------------------		

	//--------------------------------------------------------------------------
	//	Assigns
	//--------------------------------------------------------------------------
	assign			UARTDataInTransfer = 			DataInReady & DataInValid;
	assign			UARTDataOutTransfer = 			DataOutReady & DataOutValid;
	assign			PollingControlIn =				ProcessorAddress == ADDRESS_ControlIn;
	assign			PollingControlOut = 			ProcessorAddress == ADDRESS_ControlOut;
	assign			ReadingData = 					ProcessorMemRead & ProcessorAddress == ADDRESS_DataIn;
	assign			WritingData = 					ProcessorMemWrite & ProcessorAddress == ADDRESS_DataOut;	
	//--------------------------------------------------------------------------
	
	//--------------------------------------------------------------------------
	//	Control Registers
	//--------------------------------------------------------------------------
	Register 		#(			.Width(				1))
					cIn (.Clock(Clock), .Reset(Reset | ReadingData), .Set(UARTDataInTransfer), .Enable(1'b0), .In(1'bx), .Out(ControlInReady)),
					cOut (.Clock(Clock), .Reset(Reset | UARTDataOutTransfer), .Set(WritingData), .Enable(1'b0), .In(1'bx), .Out(DataOutValid));
	//--------------------------------------------------------------------------				
	
	//--------------------------------------------------------------------------
	//	Data Registers
	//--------------------------------------------------------------------------
	Register		#(			.Width(				CWidth))
					dIn (.Clock(Clock), .Reset(Reset), .Set(1'b0), .Enable(UARTDataInTransfer), .In(DataIn), .Out(DataInReg)),
					dOut (.Clock(Clock), .Reset(Reset), .Set(1'b0), .Enable(WritingData), .In(ProcessorDataOut[7:0]), .Out(DataOut));	
	//--------------------------------------------------------------------------
endmodule
//------------------------------------------------------------------------------
