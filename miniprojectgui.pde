int led_width = 64;
int led_height = 32;
int[][] box_color = new int[led_width*led_height][3];
ToggleButton[] tg = new ToggleButton[4];

void setup(){

  size(1000,600);
  String[] name = {"PEN","Red","Green","Blue"};
  for (int i=0;i<4;i++){
    tg[i] = new ToggleButton(name[i],66+i*60,549);//sizex=50 but use 60 for space
  }

}

void draw(){
  background(100);
  draw_pixels();
  draw_color_panel();
  draw_send_button();
  
  for (int i=0;i<4;i++) tg[i].draws();
}
void mouseDragged(){
  selected_pixels();
}


void mousePressed(){
 for (int i=0;i<4;i++) tg[i].change_state();
 send_button_pressed();
}

void keyPressed() {
 if (keyCode==96 || keyCode=='0') {
     for (int i=0;i<led_width*led_height;i++) {
       box_color[i][0]=0;
       box_color[i][1]=0;
       box_color[i][2]=0;
     }
 }
 if (keyCode==97 || keyCode=='1'){
   load_image();
 }
}

void load_image(){
 PImage tower;
  tower = loadImage("image.jpg");
  tower.resize(led_width,led_height);
  //float step = map(1,0,float(dimension),0,led_width*led_height);
  //print(dimension,step);
  color[] color7 = {color(0,0,255),color(0,255,0),color(0,255,255),
                    color(255,0,0),color(255,0,255),color(255,255,0),
                    color(255,255,255)};
  tower.loadPixels();
  for (int i = 0; i < led_height; i++) { 
    for (int j=0; j<led_width;j++){

      float smallest = colorDistance(tower.pixels[(i*64)+j], color7[0]);
      int nearestColor = color7[0];
        for (int k=1;k<color7.length;k++){
          float distance = colorDistance(tower.pixels[(i*64)+j], color7[k]);
          if (distance < smallest) {
            smallest = distance;
            nearestColor = color7[k];
            
          }
        }
      box_color[j*led_height+i][0]= int(red(nearestColor));
      box_color[j*led_height+i][1]= int(green(nearestColor));
      box_color[j*led_height+i][2]= int(blue(nearestColor));
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

void draw_pixels(){
   float sizex = float(width)/float(led_width);
   float sizey = float(height-100)/float(led_height);
   stroke(50);
   for (int j=0;j<led_height;j++){
     for (int i=0;i<led_width;i++){
       fill(box_color[i*led_height+j][0],box_color[i*led_height+j][1],
           box_color[i*led_height+j][2]);
       rect(i*sizex,j*sizey,sizex,sizey);
     }
   }
}

void draw_color_panel(){
 fill(50);
 rect(50,height-75,400,50); 
}

void draw_send_button(){
 fill(22);
 rect(320,height-65,100,30); 
 fill(255);
 text("Send",320+35,height-45);
}
void send_button_pressed(){
  if (chc_pos(320, 320+100, height-65, height-65+30)){
    fill(199);
    rect(320,height-65,100,30); 
  } 
}

void selected_pixels(){
  float sizex = float(width)/led_width;
  float sizey = float(height-100)/led_height;
  if (tg[0].state){ // on checked
    for (int j=0;j<led_height;j++){
       for (int i=0;i<led_width;i++){
         if (chc_pos(i*sizex, i*sizex+sizex, j*sizey, j*sizey+sizey)){
           box_color[i*led_height+j][0] = 255;
            // receive state from pixel
           for (int k=1;k<4;k++){
             if (tg[k].state) {
              box_color[i*led_height+j][k-1]=255; 
             } else {
              box_color[i*led_height+j][k-1]=0; 
             }
           }
         } 
       }
     }
  }
}





boolean chc_pos(float x,float xf,float y,float yf){
  if ( mouseX > x && mouseX < xf && mouseY > y && mouseY < yf) {
     return true; 
  } else {
    return false;
  }
}