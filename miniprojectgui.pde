int led_width = 64;
int led_height = 32;
int[][] box_color = new int[led_width*led_height][3];
ToggleButton[] tg = new ToggleButton[3];
int selected_pixel = -1;
float[] selected_pos = new float[2];

void setup(){
  size(1000,600);
  String[] name = {"Red","Green","Blue"};
  for (int i=0;i<3;i++){
    tg[i] = new ToggleButton(name[i],66+i*60,549);//sizex=50 but use 60 for space
  }
}

void draw(){
  background(100);
  draw_pixels();
  draw_overlay_select_pixel();
  draw_color_panel();
  draw_send_button();
  for (int i=0;i<3;i++) tg[i].draws();
  println(mouseX,mouseY);
}

void mousePressed(){
 selected_pixels();
 for (int i=0;i<3;i++) tg[i].change_state();
 change_selected_pixel_color();
 send_button_pressed();
}

void keyPressed() {
 if (keyCode==96 || keyCode=='0') {
     selected_pixel = -1;
 }
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

void draw_overlay_select_pixel(){
  float sizex = float(width)/float(led_width);
  float sizey = float(height-100)/float(led_height);
  if (selected_pixel != -1){
    fill(255,255,0,80);
    rect(selected_pos[0],selected_pos[1],sizex,sizey);
  }
}

void draw_color_panel(){
 fill(50);
 rect(50,height-75,370,50); 
}

void draw_send_button(){
 fill(22);
 rect(270,height-65,100,30); 
 fill(255);
 text("Send",270+35,height-45);
}
void send_button_pressed(){
  if (chc_pos(270, 270+100, height-65, height-65+30)){
    fill(199);
    rect(270,height-65,100,30); 
  } 
}

void selected_pixels(){
  float sizex = float(width)/led_width;
  float sizey = float(height-100)/led_height;
  for (int j=0;j<led_height;j++){
     for (int i=0;i<led_width;i++){
       if (chc_pos(i*sizex, i*sizex+sizex, j*sizey, j*sizey+sizey)){
         //box_color[i*led_height+j][0] = 255;
         selected_pixel = i*led_height+j; // select
         selected_pos[0] = i*sizex; // keep select position
         selected_pos[1] = j*sizey;
          // receive state from pixel
         for (int k=0;k<3;k++) tg[k].receive_state(box_color[i*led_height+j][k]);
       } 
     }
   }
}



void change_selected_pixel_color(){
  if (selected_pixel != -1){
    for (int i=0;i<3;i++){
      if (tg[i].state) {
        box_color[selected_pixel][i] = 255;
      } else {
        box_color[selected_pixel][i] = 0;
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