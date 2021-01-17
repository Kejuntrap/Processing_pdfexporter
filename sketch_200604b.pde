 /*
 title:Processing PDF Exporter
 description:input json file and then,export a PDF file.
 filename:sketch_200604b.pde
 LICENCE:MIT
 (c) 2020 Kejuntrap
 */
import processing.pdf.*;
JSONArray json;
String LoadedFile;    //読み込んだjsonファイルパス
PGraphicsPDF pdf;    //PDFを書き込む
int pw,ph;    //pdfのよこたてサイズ
PFont defaultfont; //使用するフォント
PrintWriter output;   //log出力
import java.time.LocalDateTime; //log出力でいる

LocalDateTime date;

void setup() {
  size(200, 200);    //傀儡のウィンドウ
  selectInput("Select a file to process:", "exportPDF");
  defaultfont = createFont("mp1mn.ttf", 32, true);
  output = createWriter("output.txt"); 
  date = LocalDateTime.now();
  output.println(date+": Application launched."); 
}

void exportPDF(File selection) {  //動作の99%はココで行うので非常によろしくないけど、機能はpdfをエクスポートするだけなので問題ない
  //プロジェクトのjsonのinput
  if (selection == null) {    //インポートされたjsonがないと、終了
    date = LocalDateTime.now();
    output.println(date+": load file failed error");
    output.flush();  // Writes the remaining data to the file
    output.close();  // Finishes the file
    System.exit(1);
  } else {
    LoadedFile = selection.getAbsolutePath();
  }
  json = loadJSONArray(LoadedFile);    //json load
  date = LocalDateTime.now();
  output.println(date+": json load OK");
  //プロジェクトのjsonのinput
  //jsonの読み込み
  JSONObject info = json.getJSONObject(0);     //jsonの配列の0番目には基本情報が入っている
  ph = Integer.parseInt(info.getString("height"));
  pw = Integer.parseInt(info.getString("width"));
  pdf = (PGraphicsPDF) createGraphics(pw, ph, PDF, "output.pdf");
  beginRecord(pdf);    //pdf書き込み開始
  date = LocalDateTime.now();
  output.println(date+": pdf init OK");
  //json読み込み
  //プレゼンpdf作成
  for (int j = 1; j < json.size() ; j++) {    
      JSONObject slide = json.getJSONObject(j); 
      //背景
      String background = slide.getString("background");
      if(background.equals("")){
        pdf.background(255);  //背景設置
      }else{
        PImage bg = loadImage(background);
        pdf.image(bg, 0, 0);    //背景設置
      }
      date = LocalDateTime.now();
      output.println(date+": background set page "+j);
      //背景
      //文字
      JSONArray strings = slide.getJSONArray("text");
      for(int k=0; k<strings.size(); k++){
        JSONObject str = strings.getJSONObject(k); 
        String content = str.getString("text");    //表示させる内容
        int dispx = Integer.parseInt(str.getString("x"));
        int dispy = Integer.parseInt(str.getString("y"));
        int fontsize = Integer.parseInt(str.getString("size"));
        fill(0);
        textFont(defaultfont);
        textSize(fontsize);
        pdf.text(content, dispx, dispy);
      }
      date = LocalDateTime.now();
      output.println(date+": typography done page "+j);
      //文字
      //pdfのページ更新
      if( j != json.size() -1){
        pdf.nextPage();
        date = LocalDateTime.now();
        output.println(date+": pdf export success "+j+" of "+(json.size()-1));
      }
      //pdfのページ更新
    }
    date = LocalDateTime.now();
    output.println(date+": pdf export success "+(json.size()-1)+" of "+(json.size()-1));
  pdf.dispose();
  endRecord();
  date = LocalDateTime.now();
  output.println(date+": successfully close output pdf file");
  date = LocalDateTime.now();
  output.println(date+": exit program");
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  System.exit(0);
}
/*
参考文献
https://forum.processing.org/two/discussion/8298/using-nextpage-with-a-pdf
*/
