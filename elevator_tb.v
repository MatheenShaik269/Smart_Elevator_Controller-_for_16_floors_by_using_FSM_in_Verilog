`timescale 1ns / 1ps
module elevator_tb();
    //inputs
    reg clk,rst,electricity,generator,up,down,e_stop,fan,light;
    reg [8:0] weight;
    reg [3:0] floor;
    //outputs
    wire m_up,m_down,d_open,d_close,light_on,fan_on,alarm_on;
    //declaration for string
    reg [18*8-1:0] state;
    //register to store previous_state
   
    //module instantiation
    elevator dut(
                    //inputs port connection
                    .clk(clk),
                    .rst(rst),
                    .electricity(electricity),
                    .generator(generator),
                    .up(up),
                    .down(down),
                    .e_stop(e_stop),
                    .weight(weight),
                    .floor(floor),
                    .fan(fan),
                    .light(light),
                    //outputs port connection
                    .m_up(m_up),
                    .m_down(m_down),
                    .d_open(d_open),
                    .d_close(d_close),
                    .light_on(light_on),
                    .fan_on(fan_on),
                    .alarm_on(alarm_on)
                );
 
        
    //assigning strings (Names) to current state to use them in output            
    always @(*)
        begin
            case(dut.current_state)
                4'd0 : state="electricity_check" ;
                4'd1 : state="idle" ;
                4'd2 : state="move_up" ;
                4'd3 : state="move_down" ;
                4'd4 : state="door_open" ;
                4'd5 : state="weight_check" ;
                4'd6 : state="alarm" ;
                4'd7 : state="door_close" ;
                4'd8 : state="emergency_stop" ;
                default : state="Unknown State" ;
            endcase
              
            
        end
   //generating clock 
   initial
    begin
        clk=0;
        forever
        #5 clk=~clk;
    end
  //Displaying outputs of Test Cases
  always @(posedge clk)
    begin
        $display("rst = %b | clk = %b | electricity = %b | generator = %b |weight = %b | current_state = %s | floor = %b | current_floor = %b | move_up = %b | move_down = %b | door_open = %b | door_close = %b | light_on = %b | fan_on = %b | alarm_on = %b | e_stop = %b |p_state = %b | n_state = %b | ",
                 rst,clk,electricity,generator,weight,state,floor,dut.current_floor,m_up,m_down,d_open,d_close,light_on,fan_on,alarm_on,e_stop,dut.previous_state,dut.next_state
               );
    end
    initial begin
    //dont forget to initialize the initial values
    clk = 0;
    rst = 1;

    electricity = 0;
    generator   = 0;
    up          = 0;
    down        = 0;
    e_stop      = 0;
    fan         = 0;
    light       = 0;
    weight      = 9'd0;
    floor       = 4'd0;

   
end
 initial
    begin
         rst=1'b1;
         #20
         rst=1'b0;
         #20
         $display("============Test Case 1 : Testing idle state when there is  electricity============");
         electricity=1'b1 ;
         #20
         $display("============Test Case 2 : Testing idle state when there is no electricity and no generator============ ");
         electricity=1'b0; generator=1'b0;
         #40
        $display("============Test Case 3 : Testing electricity_check state when there is no electricity and there is generator============");
        electricity=1'b0 ; generator=1'b1;
        #20
        $display("============Test Case 4 : Lift is in ground floor and people is also in ground floor then pressing any of the up or down button to open the door============");
        up=1'b1  ;
        #40
        $display("After entering into Lift they are moving up to fifth floor with lights and fans are ON");
        floor=4'd5 ; light=1'b1 ; fan=1'b1 ; weight=9'd400 ; // here floor is selected inside the lift
        #420
        up=1'b0;
        $display("============Test Case 6 : Now lift is at fifth floor let us assume that people are in ground floor now if down=1  and people outside the lift selected floor=0 then lift need to come to ground floor============");
        down=1'b1; floor=4'd0 ;
        #400
        down=1'b0;
        $display("============Test Case 7 : Now lift is at ground floor now people is at fifteenth floor now they will press up button from outside the lift in fifteenth floor and lift goes to fifeteenth floor============");
        floor=4'd15 ; up=1'b1 ;
        #800
        up=1'b0;
       $display("============Test Case 8 : Now lift is at fifteenth floor now people is at first floor now they will press up button from outside the lift in fifteenth floor and lift will go to first floor============");
        up=1'b1; floor=4'd1;
        #400
        up=1'b0;
        $display("============Test Case 9 : Now lift is at first floor now people is at second floor now even though they will press down button from outside lift goes to second floor============");
        down=1'b1 ; floor =4'd2 ;
        #400
        down=1'b0;
        $display("============Test Case 10 : when lift door is opened at second floor before the closing of door people og weight=500kg rushed into lift.============");
        $display("Now checking what happens if there is overload");
        weight=9'd500; floor=4'd3;
        #400
        $display("Now reducing weight in a lift");
        weight=9'd400;
        #400
        $display("============Test Case 11 : Now lift is at thid floor but people is at second floor so pressing down button outside the lift===========");
        down=1'b1 ;floor=4'd2;
        #400
        $display("Now door is open people is entering with heavy weight");
        weight=9'd500;
        #400
        $display("Now reducing the weght and going to third floor");
        weight=9'd400;floor=4'd3;
        #400
        $display("============ Test Case 12 : Emergency Stop when lift is moving =============");
        $display("people at fourth floor weighting for lift");
        up=1'b1; floor=4'd15 ;  //selected in forth floor outside the lift
        #800
        up=1'b0;
        $display("people entering into the lift");
        weight=9'd300 ; floor=4'd9; light=1'b0 ; fan=1'b0 ;
        #150
        e_stop=1'b1; //lift will stop at nearest floor after pressing e_stop
        #300
        e_stop=1'b0;
        $display("============Test Case 13 : Emergency stop at ideal state============");
        weight=9'd200 ; floor=4'd0 ; e_stop=1'b1;
        #300
        e_stop=1'b0;
        $display("============Test Case 14 : what happens if people in the lift selects floor and people outside the lift also selects floor at a time============");
        //people inside the lift;
        floor=4'd0 ; 
        //people outside the lift
        up=1'b1 ;floor=4'd11; //it gives priority to latest (last) given input
        #400
        up=1'b0;
        $display("============Test Case 15 : what happens if people in the lift selects floor and people outside the lift also selects floor after  some time============");
        //First it goes to ground floor then it goes to fifteenth floor.
        floor=4'd0; #300;
        up=1'b1 ; floor=4'd15;
        #300
        $display("============Test Case 16 : what happens if the people inside the lift selects two floors at a time============");
        floor=4'd0 ; floor=4'd13; //it gives priority to latest one
        #300
        $display("============Test Case 17 : what happens if the people inside the lift selects two floors after some time============");
        //First it goes to fourth floor and then to ground floor.
        floor=4'd4 ; 
        #300
        floor=4'd0;
        #300
        $display("============Test Case 18 : What happens if up=1 down=1  down=0 ============");
        up=1'b1 ; down=1'b1 ; down=1'b0 ; floor=4'd5;
        #300
        up=1'b0;
        $display("============Test case 19 : what happens if up=1 and down =1");
        up=1'b1 ; down=1'b1 ; floor=4'd8;
        #300;
        up=1'b0;
        $display("============Test case 20 : what happens if people outside the lift in tenth floor calls lift and in ground floor calls the lift at a time");
        up=1'b1;floor=4'd10;
        down=1'b1;floor=4'd0;//It goes to ground floor
        #300
        up=1'b0;down=1'b0;
        $display("============Test case 20 : what happens if people outside the lift in tenth floor calls lift and in third floor calls the lift after some time");
        //It first goes to tenth then to third
        up=1'b1; floor=4'd10;
        #300
        up=1'b1 ; floor=4'd3;
        #300
        up=1'b0;
        $finish;
        

         
    end
        
   
endmodule


