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