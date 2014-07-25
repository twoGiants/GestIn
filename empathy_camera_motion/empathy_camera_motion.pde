/**
<p>Don't move too fast &mdash; you might scare it. Click to forgive and forget.</p>
*/
import processing.video.*;

// Variable for capture device
Capture video;
// Previous Frame
PImage prevFrame;
// How different must a pixel be to be a "motion" pixel
float threshold = 50;
boolean motion = false;  

int n = 5000; // number of cells
float bd = 37; // base line length
float sp = 0.004; // rotation speed step
float sl = .97; // slow down rate
 
Cell[] all = new Cell[n];
 
class Cell{
  int x, y;
  float s = 0; // spin velocity
  float c = 0; // current angle
  Cell(int x, int y) {
    this.x=x;
    this.y=y;
  }
  void sense() {
//    if(pmouseX != 0 || pmouseY != 0)
//      s += sp * det(x, y, pmouseX, pmouseY, mouseX, mouseY) / (dist(x, y, mouseX, mouseY) + 1);
    if(motion)
      s += sp * det(x, y, 0, 0, 5, 5) / (dist(x, y, 5, 5) + 1);
    s *= sl;
    c += s;
    float d = bd * s + .001;
    line(x, y, x + d * cos(c), y + d * sin(c));
  }
}
 
void setup(){
  size(320, 240);
  stroke(0, 0, 0, 20);
  for(int i = 0; i < n; i++){
    float a = i + random(0, PI / 9);
    float r = ((i / (float) n) * (width / 2) * (((n-i) / (float) n) * 3.3)) + random(-3,3) + 3;
    all[i] = new Cell(int(r*cos(a)) + (width/2), int(r*sin(a)) + (height/2));
  }
  
  video = new Capture(this, width, height, 30);
  video.start();
  // Create an empty image the same size as the video
  prevFrame = createImage(video.width, video.height, RGB);
}

void captureEvent(Capture video) {
  // Save previous frame for motion detection!!
  prevFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height); // Before we read the new frame, we always save the previous frame for comparison!
  prevFrame.updatePixels();  // Read image from the camera
  video.read();
}
 
void draw() {
  loadPixels();
  video.loadPixels();
  prevFrame.loadPixels();

  // Start with a total of 0
  float totalMotion = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < video.width; x ++ ) {
    for (int y = 0; y < video.height; y ++ ) {

      int loc = x + y*video.width;            // Step 1, what is the 1D pixel location
      color current = video.pixels[loc];      // Step 2, what is the current color
      color previous = prevFrame.pixels[loc]; // Step 3, what is the previous color

      // Step 4, compare colors (previous vs. current)
      float r1 = red(current); 
      float g1 = green(current); 
      float b1 = blue(current);
      float r2 = red(previous); 
      float g2 = green(previous); 
      float b2 = blue(previous);
      float diff = dist(r1, g1, b1, r2, g2, b2);
      
      // totalMotion is the sum of all color differences.
      totalMotion += diff;
      
      // Step 5, How different are the colors?
      // If the color at that pixel has changed, then there is motion at that pixel.
      if (diff > threshold) { 
        // If motion, display black
        pixels[loc] = color(0);
        
      } else {
        // If not, display white
        pixels[loc] = color(255);
      }
    }
  }
  updatePixels();
  
  // averageMotion is total motion divided by the number of pixels analyzed.
  float avgMotion = totalMotion / video.pixels.length;
  //println(avgMotion);
  if(avgMotion > 5.0) {
    motion = true;
  }
  else {
    motion = false;
  }
  
  background(255);
  for(int i = 0; i < n; i++)
    all[i].sense();
}
 
void mousePressed() {
  for(int i=0;i<n;i++)
    all[i].c = 0;
}
 
float det(int x1, int y1, int x2, int y2, int x3, int y3) {
  return (float) ((x2-x1)*(y3-y1) - (x3-x1)*(y2-y1));
}

