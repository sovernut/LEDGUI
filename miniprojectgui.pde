import processing.serial.*;
Serial myPort;

int BrushType = 0; 
int led_width = 64;
int led_height = 32;
int[][] box_color = new int[led_width*led_height][3];
//-------- undo
int[] undo_stack = new int[5];
int undo_pointer = 0;

int before_position;

ToggleButton[] tg = new ToggleButton[4];

void setup(){

  size(1000,600);
  String[] name = {"PEN","Red","Green","Blue"};
  for (int i=0;i<4;i++){
    tg[i] = new ToggleButton(name[i],66+i*60,549); //sizex=50 but use 60 for space
  }
  myPort = new Serial(this, Serial.list()[0], 115200);

}

void draw(){
  background(100);
  draw_pixels();
  draw_color_panel();
  draw_send_button();
  draw_brushsize_indicator();
  for (int i=0;i<4;i++) tg[i].draws();
  selected_pixels();
}


void mousePressed(){
 for (int i=0;i<4;i++) tg[i].change_state();
 button_pressed();
 
}

void keyPressed() {
 if (keyCode==96 || keyCode=='0') {
     for (int i=0;i<led_width*led_height;i+=1) {
       box_color[i][0]=0;
       box_color[i][1]=0;
       box_color[i][2]=0;
     }
 }
 if (keyCode==97 || keyCode=='1'){
   selectInput("Select a file to process:", "load_image");
 }

if (keyCode==98 || keyCode=='2'){
   fill_pixels();
 }
 if (keyCode=='z' || keyCode=='Z'){
   undo();
 }
}

void undo(){
  for (int k=0;k<3;k++) box_color[undo_stack[undo_pointer]][k] = 0;
  if (undo_pointer>0) undo_pointer--;
}

void shiftAndAdd(int a[], int val){
  int a_length = a.length;
  System.arraycopy(a, 1, a, 0, a_length-1);
  a[a_length-1] = val;
}

// *************************** LOADPICTURE ********************************** //
void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else if (selection.getAbsolutePath().endsWith(".jpg") || selection.getAbsolutePath().endsWith(".png")) {
    println("User selected " + selection.getAbsolutePath());
  }
}


void load_image(File selection){
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
   PImage Image;
    Image = loadImage(selection.getAbsolutePath());
    Image.resize(led_width,led_height);
    color[] color7 = {color(0,0,0),color(0,0,255),color(0,255,0),color(0,255,255),
                      color(255,0,0),color(255,0,255),color(255,255,0),
                      color(255,255,255)};
    Image.loadPixels();
    for (int i = 0; i < led_height; i++) { 
      for (int j=0; j<led_width;j++){
        
        float smallest = colorDistance(Image.pixels[(i*led_width)+j], color7[0]);
        int nearestColor = color7[0];
          for (int k=1;k<color7.length;k++){
            float distance = colorDistance(Image.pixels[(i*led_width)+j], color7[k]);
            if (distance <= smallest) {
              smallest = distance;
              nearestColor = color7[k];
            }
          }
          
       box_color[i*led_width+j][0]= int(red(nearestColor));
        box_color[i*led_width+j][1]= int(green(nearestColor));
        box_color[i*led_width+j][2]= int(blue(nearestColor));
        
        /*box_color[i*led_width+j][0]= int(red(Image.pixels[(i*led_width)+j]));
        box_color[i*led_width+j][1]= int(green(Image.pixels[(i*led_width)+j]));
        box_color[i*led_width+j][2]= int(blue(Image.pixels[(i*led_width)+j]));*/
      }
    } 
  }
}

float colorDistance(color a, color b) 
{

      float redDiff = red(a) - red(b);
      float grnDiff = green(a) - green(b);
      float bluDiff = blue(a) - blue(b);

      return sqrt( sq(redDiff) + sq(grnDiff) + sq(bluDiff) );
}
// ============================= END LOADPICTURE ============================= //



void fill_pixels(){
  float sizex = float(width)/led_width;
  float sizey = float(height-100)/led_height;
  if (tg[0].state){ // on checked
    for (int j=0;j<led_height;j++){
       for (int i=0;i<led_width;i++){
         if (chc_pos(i*sizex, i*sizex+sizex, j*sizey, j*sizey+sizey)){
           
           // keep original color
           int[] origincolor = new int[3];
           origincolor = box_color[j*led_width+i];
           
           int[] whatcolor = new int[3];
           
           // find what color selected
           for (int k=1;k<4;k++){
             if (tg[k].state) {
               whatcolor[k-1] = 255; 
             } 
           }
           // fill color
           fill_all_near_pixel(box_color,i,j,origincolor,whatcolor);
           
           //break the loop
           i=led_width+1;
           j=led_height+1;
         } 
       }
     }
  }
}

void fill_all_near_pixel(int[][] array,int start_i,int start_j,int[] original,int[] fillcolor){
   box_color[(start_j*led_width)+start_i][0] = fillcolor[0];
   box_color[(start_j*led_width)+start_i][1] = fillcolor[1];
   box_color[(start_j*led_width)+start_i][2] = fillcolor[2];
  for (int j=start_j;j<led_height;j++){
       for (int i=start_i;i<led_width;i++){
         int[] this_box_color = {box_color[(j*led_width)+i][0],box_color[(j*led_width)+i][1],box_color[(j*led_width)+i][2]};
         if (this_box_color == original){
           box_color[(j*led_width)+i][0] = fillcolor[0];
           box_color[(j*led_width)+i][1] = fillcolor[1];
           box_color[(j*led_width)+i][2] = fillcolor[2];
         }
      }
  }
  
  for (int j=start_j;j>=0;j--){
       for (int i=start_i;i>=0;i--){
         color[] this_box_color = {box_color[(j*led_width)+i][0],box_color[(j*led_width)+i][1],box_color[(j*led_width)+i][2]};
         if (this_box_color == original){
           box_color[(j*led_width)+i][0] = fillcolor[0];
           box_color[(j*led_width)+i][1] = fillcolor[1];
           box_color[(j*led_width)+i][2] = fillcolor[2];
         }
      }
  }
  
  for (int j=start_j;j>=0;j--){
       for (int i=start_i;i<led_width;i++){
         color[] this_box_color = {box_color[(j*led_width)+i][0],box_color[(j*led_width)+i][1],box_color[(j*led_width)+i][2]};
         if (this_box_color == original){
           box_color[(j*led_width)+i][0] = fillcolor[0];
           box_color[(j*led_width)+i][1] = fillcolor[1];
           box_color[(j*led_width)+i][2] = fillcolor[2];
         }
      }
  }
  
  for (int j=start_j;j<led_height;j++){
       for (int i=start_i;i>=0;i--){
         color[] this_box_color = {box_color[(j*led_width)+i][0],box_color[(j*led_width)+i][1],box_color[(j*led_width)+i][2]};
         if (this_box_color == original){
           box_color[(j*led_width)+i][0] = fillcolor[0];
           box_color[(j*led_width)+i][1] = fillcolor[1];
           box_color[(j*led_width)+i][2] = fillcolor[2];
         }
      }
  }
}

void draw_pixels(){
   float sizex = float(width)/float(led_width);
   float sizey = float(height-100)/float(led_height);
   stroke(50);
   for (int j=0;j<led_height;j++){
     for (int i=0;i<led_width;i++){
       fill(box_color[(j*led_width)+i][0],box_color[(j*led_width)+i][1],
           (box_color[j*led_width+i])[2]);
       rect(sizex*i,sizey*j,sizex,sizey);
     }
   }
}

void draw_color_panel(){
 fill(50);
 rect(50,height-75,800,50); 
}

void draw_send_button(){
  int x = 320;
 fill(22);
 rect(x,height-65,100,30); 
 fill(255);
 text("Send",x+35,height-45);
}
void draw_brushsize_indicator(){
 int x = 450;
 fill(22);
 rect(x,height-65,100,30); 
 fill(255);
 text("BrushType : "+BrushType,x+5,height-45);
}

// *********************** BUTTON PRESSED ***************************** //
void button_pressed(){
  int x_send = 320;
  int x_brush = 450;
  if (chc_pos(x_send, x_send+100, height-65, height-65+30)){ // Send
    fill(199);
    rect(x_send,height-65,100,30); 
    send_to_fpga();
  } else if (chc_pos(x_brush, x_brush+100, height-65, height-65+30)){ // Brush
    fill(199);
    rect(x_brush,height-65,100,30); 
    toggle_brush_type();
  } 
}

void toggle_brush_type(){
  if(BrushType==0){
    BrushType=1; 
  }else {
    BrushType = 0; 
  }
}

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
     
// ******************* FILLING A BOX **************1************* //
void selected_pixels(){
  float sizex = float(width)/led_width;
  float sizey = float(height-100)/led_height;
  if (tg[0].state && mousePressed){ // on checked
    for (int j=0;j<led_height;j++){
       for (int i=0;i<led_width;i++){
         if (chc_pos(i*sizex, i*sizex+sizex, j*sizey, j*sizey+sizey)){
            fill_pixel(i,j);
         } 
       }
     }
  }
}

void undo_update(int j,int i){
  int present_pos=(j*led_width)+i;
   if (present_pos != before_position) {
       before_position = present_pos;
       if (undo_pointer<4){
         undo_pointer++;
         undo_stack[undo_pointer] = j*led_width+i;
       } else { 
         shiftAndAdd(undo_stack,j*led_width+i);
       }
       }
}

void fill_pixel(int i , int j){
  int col = 0;
  if (mousePressed){
  
    if (mouseButton == LEFT) col = 255; else col = 0;

    for (int k=1;k<4;k++){
     if (tg[k].state) { // CHECK COLOR
       box_color[(j*led_width)+i][k-1]=col; // fill color in a pixel
       undo_update(j,i);
        if (BrushType == 1){ // test fill all
          if ((j*led_width)+i-1 > 0 && (j*led_width)+i+1 < 2048) {
            box_color[(j*led_width)+i+1][k-1]=col;
            box_color[(j*led_width)+i-1][k-1]=col;
          }
        }
     } else {
      box_color[(j*led_width)+i][k-1]=0; 
     }
   }
   
   
  }
  
  
}



// FOR CHECK MOUSE POSITION
boolean chc_pos(float x,float xf,float y,float yf){
  if ( mouseX > x && mouseX < xf && mouseY > y && mouseY < yf) {
     return true; 
  } else {
    return false;
  }
}
