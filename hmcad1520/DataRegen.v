module DataRegen
	(
		DivClk,
		FrameVector,
		RawData,
		DataReady,
		DataVector
	);	
   
   input 	 		DivClk;
   input [7:0] 	FrameVector;
   input [7:0] 	RawData;
   output 	 		DataReady;	 
   output [15:0] 	DataVector;


   reg 			IntData15,IntData14,IntData13,IntData12,IntData11,IntData10,IntData9,IntData8,
					IntData7, IntData6, IntData5, IntData4, IntData3, IntData2, IntData1,IntData0;	
   reg 			Carry6, Carry5, Carry4, Carry3, Carry2, Carry1, Carry0;	
   reg 			IDataReady, DataReady;
   reg [7:0] 	IFrameVector;
   reg 			Data7, Data6, Data5, Data4, Data3, Data2, Data1, Data0;
   

   always @(posedge DivClk)
		begin
			IFrameVector <= FrameVector;
		end // always @ (posedge DivClk)

   always @(posedge DivClk)
     begin
			Data7 <= RawData[7];
			Data6 <= RawData[6];
			Data5 <= RawData[5];
			Data4 <= RawData[4];
			Data3 <= RawData[3];
			Data2 <= RawData[2];
			Data1 <= RawData[1];
			Data0 <= RawData[0];
     end // always @ (posedge DivClk)
   

   always @(posedge DivClk)
     begin
	     case (IFrameVector)
	       8'b00111111:            // 0
		 begin
		    IntData15 <= Data0; //D0
		    IntData14 <= Data1;
		    IntData13 <= Data2;
		    IntData12 <= Data3;
		    IntData11 <= Data4;
		    IntData10 <= Data5;
		    IntData9  <= Data6;
		    IntData8  <= Data7; //D7
		    IDataReady <= 0;	      
		 end  
	       8'b00011111:            // 1
		 begin
		    IntData15 <= Carry0;//D0 from carry
		    IntData14 <= Data0; //D1
		    IntData13 <= Data1;
		    IntData12 <= Data2;
		    IntData11 <= Data3;
		    IntData10 <= Data4;
		    IntData9  <= Data5;
		    IntData8  <= Data6;
		    IntData7  <= Data7; //D8
		    IDataReady <= 0;	      
		 end  
	       8'b00001111:            // 2
		 begin
		    IntData15 <= Carry1;//D0 from carry
		    IntData14 <= Carry0;//D1 from carry
		    IntData13 <= Data0; //D2
		    IntData12 <= Data1;
		    IntData11 <= Data2;
		    IntData10 <= Data3;
		    IntData9  <= Data4;
		    IntData8  <= Data5;
		    IntData7  <= Data6;
		    IntData6  <= Data7; //D9
		    IDataReady <= 0;	      
		 end  
	       8'b00000111:            // 3
		 begin
		    IntData15 <= Carry2;//D0 from carry
		    IntData14 <= Carry1;
		    IntData13 <= Carry0;//D2 from carry
		    IntData12 <= Data0; //D3
		    IntData11 <= Data1;
		    IntData10 <= Data2;
		    IntData9  <= Data3;
		    IntData8  <= Data4;
		    IntData7  <= Data5;
		    IntData6  <= Data6;
		    IntData5  <= Data7; //D10
		    IDataReady <= 0;	      
		 end  
	       8'b00000011:            // 4
		 begin
		    IntData15 <= Carry3;//D0 from carry
		    IntData14 <= Carry2;
		    IntData13 <= Carry1;
		    IntData12 <= Carry0;//D3 from carry
		    IntData11 <= Data0; //D4
		    IntData10 <= Data1;
		    IntData9  <= Data2;
		    IntData8  <= Data3;
		    IntData7  <= Data4;
		    IntData6  <= Data5;
		    IntData5  <= Data6;
		    IntData4  <= Data7; //D11
		    IDataReady <= 1;	      
		 end
	       8'b10000001:            // 5
		 begin
		    IntData15 <= Carry4;//D0 from carry
		    IntData14 <= Carry3;
		    IntData13 <= Carry2;
		    IntData12 <= Carry1;
		    IntData11 <= Carry0;//D4 from carry
		    IntData10 <= Data0; //D5
		    IntData9  <= Data1;
		    IntData8  <= Data2;
		    IntData7  <= Data3;
		    IntData6  <= Data4;
		    IntData5  <= Data5;
		    IntData4  <= Data6; //D11
		    Carry0    <= Data7; //D0 to carry
		    IDataReady <= 1;	      
		 end
	       8'b11000000:            // 6
		 begin
		    IntData15 <= Carry5;//D0 from carry
		    IntData14 <= Carry4;
		    IntData13 <= Carry3;
		    IntData12 <= Carry2;
		    IntData11 <= Carry1;
		    IntData10 <= Carry0;//D5 from carry
		    IntData9  <= Data0; //D6
		    IntData8  <= Data1;
		    IntData7  <= Data2;
		    IntData6  <= Data3;
		    IntData5  <= Data4;
		    IntData4  <= Data5; //D11
		    Carry1    <= Data6; //D0 to carry
		    Carry0    <= Data7; //D1 to carry
		    IDataReady <= 1;	      
		 end  
	       8'b11100000:            // 7
		 begin
		    IntData15 <= Carry6;//D0 from carry
		    IntData14 <= Carry5;
		    IntData13 <= Carry4;
		    IntData12 <= Carry3;
		    IntData11 <= Carry2;
		    IntData10 <= Carry1;
		    IntData9  <= Carry0;//D6 from carry
		    IntData8  <= Data0; //D7
		    IntData7  <= Data1;
		    IntData6  <= Data2;
		    IntData5  <= Data3;
		    IntData4  <= Data4; //D11
		    Carry2    <= Data5; //D0 to carry
		    Carry1    <= Data6;
		    Carry0    <= Data7; //D2 to carry
		    IDataReady <= 1;	      
		 end  
	       8'b11110000:            // 8
		 begin
		    IntData7  <= Data0; //D8
		    IntData6  <= Data1;
		    IntData5  <= Data2;
		    IntData4  <= Data3; //D11
		    Carry3    <= Data4; //D0 to carry
		    Carry2    <= Data5;
		    Carry1    <= Data6;
		    Carry0    <= Data7; //D3 to carry
		    IDataReady <= 1;	      
		 end  
	       8'b11111000:            // 9
		 begin
		    IntData6  <= Data0; //D9
		    IntData5  <= Data1;
		    IntData4  <= Data2; //D11
		    Carry4    <= Data3; //D0 to carry
		    Carry3    <= Data4;
		    Carry2    <= Data5;
		    Carry1    <= Data6;
		    Carry0    <= Data7; //D4 to carry
		    IDataReady <= 1;	      
		 end  
	       8'b11111100:            // 10
		 begin
		    IntData5  <= Data0; //D10
		    IntData4  <= Data1; //D11
		    Carry5    <= Data2; //D0 to carry
		    Carry4    <= Data3;
		    Carry3    <= Data4;
		    Carry2    <= Data5;
		    Carry1    <= Data6;
		    Carry0    <= Data7; //D5 to carry
		    IDataReady <= 1;	      
		 end  
	       8'b01111110:            // 11
		 begin
		    IntData4  <= Data0;//D11
		    Carry6    <= Data1;//D0 to carry
		    Carry5    <= Data2;
		    Carry4    <= Data3;
		    Carry3    <= Data4;
		    Carry2    <= Data5;
		    Carry1    <= Data6;
		    Carry0    <= Data7;//D6 to carry
		    IDataReady <= 1;	      
		 end 
	       default: 
		 IDataReady <= 0;
	     endcase // case (IFrameVector)
	     IntData3 <= 0;
	     IntData2 <= 0;
	     IntData1 <= 0;
	     IntData0 <= 0;
     end // always @ (posedge DivClk)
   
   
   // ********************************************************************************

   // **************************** Data Out Preparation  *****************************

   reg  [15:0] DataVector;
   
      always @(posedge DivClk)
	begin
	   DataVector   <= {IntData0,
			    IntData1,
			    IntData2,
			    IntData3,
			    IntData4,
			    IntData5,
			    IntData6,
			    IntData7,
			    IntData8,
			    IntData9,
			    IntData10,
			    IntData11,
			    IntData12,
			    IntData13,
			    IntData14,
			    IntData15};
	   DataReady <= IDataReady;
	end
   
   // ********************************************************************************

endmodule

   

		
			
	