void send_to_fpga(){
    // SEND START BIT
    int a = 0; 
    StopWatchTimer timer = new StopWatchTimer();
    timer.start();
      for (int j=0;j<led_height;j++){
        myPort.write("#"); // Write Start Byte
        myPort.write(j); //  Write Address
        //delay(a);
       for (int i=0;i<led_width;i+=2){
         int data;
         data = cal_bf_send(i,j,0);
         myPort.write(data);
         data = cal_bf_send(i,j,1);
         myPort.write(data);
         data = cal_bf_send(i,j,2);
         myPort.write(data);
         delay(a);
         //if ( box_color[(j*led_width)+i][0] == 255 ) {myPort.write(60); }else {myPort.write(0);}
         //if ( box_color[(j*led_width)+i][1] == 255 ) {myPort.write(60); }else {myPort.write(0);}
         //delay(a);
         //if ( box_color[(j*led_width)+i][2] == 255 ) {myPort.write(60); }else {myPort.write(0);}
         //delay(a);
         //}
       }

}
       timer.stop();
       println("Time:"+timer.getElapsedTime());

     
// ******************* for printing value *************************** //

 /* for (int x=0;x<3;x++){
    for (int j=0;j<led_height;j++){
        print('"');
         for (int i=0;i<led_width;i++){
           if (box_color[(j*led_width)+i][x] == 255) {
             print('1');
             // SEND BIT
             // DELAY 1 MS
           } else print('0');
        }
        print('"');
        println("&");
    }
    println("===============================");
  }*/
}
int cal_bf_send(int i, int j, int colors){
  int data = 0;
  if ( box_color[(j*led_width)+i][colors] == 255 ){
    data+=240;
  }
  if ( box_color[(j*led_width)+i+1][colors] == 255 ){
    data+=15;
  }
  return data;
}