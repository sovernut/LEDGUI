import processing.serial.*;
Serial myPort;

int BrushType = 0; 
int led_width = 64;
int led_height = 32;
int[][] box_color = new int[led_width*led_height][3];
ToggleButton[] tg = new ToggleButton[4];

void setup(){

  size(1000,600);
  String[] name = {"PEN","Red","Green","Blue"};
  for (int i=0;i<4;i++){
    tg[i] = new ToggleButton(name[i],66+i*60,549); //sizex=50 but use 60 for space
  }
  myPort = new Serial(this, Serial.list()[0], 9600);

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
   load_image();
 }

if (keyCode==98 || keyCode=='2'){
   fill_pixels();
 }
}



// *************************** LOADPICTURE ********************************** //
void load_image(){
 PImage Image;
  Image = loadImage("image.jpg");
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
           color[] origincolor = new color[3];
           origincolor = box_color[j*led_width+i];
           
           color[] whatcolor = new color[3];
           
           // find what color selected
           for (int k=1;k<4;k++){
             if (tg[k].state) {
               whatcolor[k-1] = 255; 
             } 
           }
           // recursively fill color
           fill_recursively(box_color,i,j,origincolor,whatcolor);
           
           //break the loop
           i=led_width+1;
           j=led_height+1;
         } 
       }
     }
  }
}

void fill_recursively(int[][] array,int i,int j,color[] original,color[] fillcolor){
  if (j <= led_height && i <= led_width && j >= 0 && i >= 0){
    //if (array[(i*led_height)+j] == original){
      array[(j*led_width)+i] = fillcolor;

       fill_recursively(array,(i-1),j,original,fillcolor); //left
       println(i);
       //fill_recursively(array,i+1,j,original,fillcolor); // right
        /*fill_recursively(array,i,j+1,original,fillcolor); // right
        fill_recursively(array,(i+1),j,original,fillcolor); //bottom*/
    //}
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
      for (int j=0;j<led_height;j++){
        myPort.write("#"); // Write Start Byte
        myPort.write(j); //  Write Address
        //delay(a);
       for (int i=0;i<led_width;i++){
         if ( box_color[(j*led_width)+i][0] == 255 ) {myPort.write(60); }else {myPort.write(0);}
         delay(a);
         if ( box_color[(j*led_width)+i][1] == 255 ) {myPort.write(60); }else {myPort.write(0);}
         delay(a);
         if ( box_color[(j*led_width)+i][2] == 255 ) {myPort.write(60); }else {myPort.write(0);}
         delay(a);
         }
       }
     
     

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

// ******************* FILLING A BOX *************************** //
void selected_pixels(){
  float sizex = float(width)/led_width;
  float sizey = float(height-100)/led_height;
  if (tg[0].state && mousePressed){ // on checked
    for (int j=0;j<led_height;j++){
       for (int i=0;i<led_width;i++){
         if (chc_pos(i*sizex, i*sizex+sizex, j*sizey, j*sizey+sizey)){
           // ----------------- Left Click to Add
            if (mousePressed && (mouseButton == LEFT)){
             for (int k=1;k<4;k++){
               if (tg[k].state) {
                 box_color[(j*led_width)+i][k-1]=255; 
                  if (BrushType == 1){
                    if ((j*led_width)+i-1 > 0 && (j*led_width)+i+1 < 2048) {
                      box_color[(j*led_width)+i+1][k-1]=255;
                      box_color[(j*led_width)+i-1][k-1]=255;
                    }
                  }
               } else {
                box_color[(j*led_width)+i][k-1]=0; 
               }
             } // ----------------- Right Click to Delete
            } else if (mousePressed && (mouseButton == RIGHT)) {
              for(int k=0;k<3;k++)box_color[(j*led_width)+i][k]=0; 
            }
         } 
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