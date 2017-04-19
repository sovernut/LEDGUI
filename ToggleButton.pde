class ToggleButton{
   String name;
   boolean state;
   int x,y;
   int sizex=50;
   int sizey=20;
   ToggleButton(String name,int x,int y) {
     this.name = name;
     this.state = false;
     this.x = x;
     this.y = y;
   }
   void draws(){
     fill(25);
     rect(x,y,sizex,sizey);
     fill(255);
     text(name,x+sizex*0.25,y);
     if (this.state){
       fill(0,255,0);
       rect(x,y,sizex/2,sizey);
       fill(0);
       text("ON",x+sizex*0.1,y+sizey*0.7);
     } else {
       fill(255,0,0);
       rect(x+sizex/2,y,sizex/2,sizey);
       fill(255);
       text("OFF",x+sizex/2,y+sizey*0.7);
     }
   }
   void change_state(){
     if (chc_pos(x,x+sizex,y,y+sizey)) {
       state = !state;
     }
   }
   void receive_state(int number){
     if (number == 255) {
       state = true;
     } else {
      state = false; 
     }
   }
  boolean chc_pos(float x,float xf,float y,float yf){
  if ( mouseX > x && mouseX < xf && mouseY > y && mouseY < yf) {
     return true; 
  } else {
    return false;
  }
}
}