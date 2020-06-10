import processing.net.*;
color lightbrown = #FFFFC3;
color darkbrown  = #D8864E;
PImage wrook, wbishop, wknight, wqueen, wking, wpawn;
PImage brook, bbishop, bknight, bqueen, bking, bpawn;
boolean firstClick;
int row1, col1, row2, col2;
boolean whiteTurn = true;

Server myServer;
int whiteTimer = 5*60;
int blackTimer = 5*60;

boolean whiteCanCastleQueenSide = true;
boolean blackCanCastleQueenSide = true;
boolean whiteCanCastleKingSide = true;
boolean blackCanCastleKingSide = true;

char board[][] = {
  {'r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'}, 
  {'p', 'p', 'p', 'p', 'p', 'p', 'p', 'p'}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {' ', ' ', ' ', ' ', ' ', ' ', ' ', ' '}, 
  {'P', 'P', 'P', 'P', 'P', 'P', 'P', 'P'}, 
  {'R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'}
};
ArrayList<char[][]> positions;

boolean pawnIsPromoting;
int promotionRow;
int promotionCol;

char promoteTo;

void setup() {
  size(800, 800);

  firstClick = true;

  brook = loadImage("blackRook.png");
  bbishop = loadImage("blackBishop.png");
  bknight = loadImage("blackKnight.png");
  bqueen = loadImage("blackQueen.png");
  bking = loadImage("blackKing.png");
  bpawn = loadImage("blackPawn.png");

  wrook = loadImage("whiteRook.png");
  wbishop = loadImage("whiteBishop.png");
  wknight = loadImage("whiteKnight.png");
  wqueen = loadImage("whiteQueen.png");
  wking = loadImage("whiteKing.png");
  wpawn = loadImage("whitePawn.png");

  myServer = new Server(this, 1234);

  positions = new ArrayList<char[][]>();
}

void draw() {
  drawBoard();

  drawPieces();
  receiveMove();
  highlightLegalMoves(row1, col1);

  //Timer
  if (whiteTurn && frameCount %30 == 0) {
    whiteTimer --;
    myServer.write("wt" + whiteTimer);
  }
  if (!whiteTurn && frameCount %30 == 0) {
    blackTimer--;
    myServer.write("bt" + blackTimer);
  }
  noStroke();
  fill(255);
  rect(720, 780, 60, 20);
  fill(0);
  textSize(20);
  text(whiteTimer/60 +":" + whiteTimer%60/10 + whiteTimer%60%10, 720, 800);

  fill(255);
  rect(720, 0, 60, 20);
  fill(0);
  textSize(20);
  text(blackTimer/60 +":" + blackTimer%60/10 + blackTimer%60%10, 720, 15);

  if (pawnIsPromoting) {
    fill(0, 180);
    rect(0, 0, 800, 800);

    if (row2 == 0) {
      image(wqueen, 0, 0, 400, 400);
      image(wknight, 400, 0, 400, 400);
      image(wbishop, 0, 400, 400, 400);
      image(wrook, 400, 400, 400, 400);
    } else if (row2 == 7) {
      image(bqueen, 0, 0, 400, 400);
      image(bknight, 400, 0, 400, 400);
      image(bbishop, 0, 400, 400, 400);
      image(brook, 400, 400, 400, 400);
    }
  }
}

void drawBoard() {

  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) { 
      if ( (r%2) == (c%2) ) { 
        fill(lightbrown);
      } else { 
        fill(darkbrown);
      }
      stroke(0);
      strokeWeight(0);
      rect(c*100, r*100, 100, 100);
    }
  }

  if (!firstClick) {
    noFill();
    strokeWeight(5);
    stroke(255, 0, 0);
    rect(col1*100, row1*100, 100, 100);
  }
}

void drawPieces() {
  for (int r = 0; r < 8; r++) {
    for (int c = 0; c < 8; c++) {
      if (board[r][c] == 'R') image (wrook, c*100, r*100, 100, 100);
      if (board[r][c] == 'r') image (brook, c*100, r*100, 100, 100);
      if (board[r][c] == 'B') image (wbishop, c*100, r*100, 100, 100);
      if (board[r][c] == 'b') image (bbishop, c*100, r*100, 100, 100);
      if (board[r][c] == 'N') image (wknight, c*100, r*100, 100, 100);
      if (board[r][c] == 'n') image (bknight, c*100, r*100, 100, 100);
      if (board[r][c] == 'Q') image (wqueen, c*100, r*100, 100, 100);
      if (board[r][c] == 'q') image (bqueen, c*100, r*100, 100, 100);
      if (board[r][c] == 'K') image (wking, c*100, r*100, 100, 100);
      if (board[r][c] == 'k') image (bking, c*100, r*100, 100, 100);
      if (board[r][c] == 'P') image (wpawn, c*100, r*100, 100, 100);
      if (board[r][c] == 'p') image (bpawn, c*100, r*100, 100, 100);
    }
  }
}

void receiveMove() {
  Client myclient = myServer.available();
  if (myclient!= null) {
    String incoming = myclient.readString();

    //RECIEVE UNDO MOVE
    if (incoming.equals("undoMove")) {
      board = positions.get(positions.size()-2);
      positions.remove(positions.size()-1);
      whiteTurn = !whiteTurn;
    }
      //Recieve promotion move
      if (incoming.substring(0, 1).equals("p")) {
        board[int(incoming.substring(1, 2))][int(incoming.substring(3, 4))] = incoming.charAt(5);
      }

    //Recieve move
    if (incoming.substring(0, 1).equals("m")) {

      //make the move
      int r1 = int(incoming.substring(1, 2));
      int c1 = int(incoming.substring(3, 4));
      int r2 = int(incoming.substring(5, 6));
      int c2 = int(incoming.substring(7, 8));

      //en passent move
      if (board[r1][c1] == 'p' && board[r2][c2] == ' ' && Math.abs(c1-c2) ==1) {
        board[r1][c2] = ' ';
      }

      //check if move affects castling priveleges
      if (r1 == 0 && c1 == 0)
        blackCanCastleQueenSide = false;
      else if (r1==0 && c1 == 7)
        blackCanCastleKingSide = false;
      else if (r1==0 && c1 == 4) {
        blackCanCastleKingSide = false;
        blackCanCastleQueenSide = false;
      }
      //castling exception
      if (board[r1][c1] == 'k' && c2-c1 == 2) {
        board[0][5] = board[0][7];
        board[0][7] = ' ';
      } else if (board[r1][c1] == 'k' && c2-c1 == -2) {
        board[0][3] = board[0][0];
        board[0][0] = ' ';
      }

      //normal move
      board[r2][c2] = board[r1][c1];
      board[r1][c1] = ' ';
      whiteTurn = true;


      //record the position
      char[][] temp = new char[8][8];
      for (int i = 0; i < 8; i++)
        for (int j = 0; j < 8; j++)
          temp[i][j]=board[i][j];
      positions.add(temp);
    }
  }
}
void highlightLegalMoves(int row, int col) {

  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {

      if (checkLegal(row, col, i, j)&& whitePieces.contains(str(board[row1][col1]))) {
        fill(255, 255, 0, 150);
        stroke(0);
        strokeWeight(0);
        rect(j*100, i*100, 100, 100);
      }
    }
  }
}

void mouseReleased() {
  if (!pawnIsPromoting) {
    if (whiteTurn) {
      if (firstClick) {
        row1 = mouseY/100;
        col1 = mouseX/100;
        firstClick = false;
      } else {
        row2 = mouseY/100;
        col2 = mouseX/100;
        if (checkLegal(row1, col1, row2, col2) && whitePieces.contains(str(board[row1][col1]))) {

          //en passent exception
          if (board[row1][col1] == 'P' && board[row2][col2] == ' ' && Math.abs(col1-col2) ==1) {
            board[row1][col2] = ' ';
          }

          //check if move affects castling priveleges
          if (row1 == 7 && col1==0)
            whiteCanCastleQueenSide = false;
          else if (row1 == 7 && col1 == 7)
            whiteCanCastleKingSide = false;
          else if (row1 == 7 && col1 ==4) {
            whiteCanCastleKingSide = false;
            whiteCanCastleQueenSide = false;
          }

          //castling exception
          if (board[row1][col1] == 'K' && col2-col1 == 2) {
            board[7][5] = board[7][7];
            board[7][7] = ' ';
          } else if (board[row1][col1] == 'K' && col2-col1 == -2) {
            board[7][3] = board[7][0];
            board[7][0] = ' ';
          }

          //pawn promotion move
          if ((board[row1][col1] == 'p' && row2== 7) || (board[row1][col1] == 'P' && row2== 0)) {
            pawnIsPromoting = true;
            promotionRow = row2;
            promotionCol = col2;
          }

          //normal move
          board[row2][col2] = board[row1][col1];
          board[row1][col1] = ' ';
          myServer.write("m" +row1+"," +col1+"," + row2 +"," +col2);
          whiteTurn = false;
          firstClick = true;


          //record the position
          char[][] temp = new char[8][8];
          for (int i = 0; i < 8; i++)
            for (int j = 0; j < 8; j++)
              temp[i][j]=board[i][j];
          positions.add(temp);
        } else {
          firstClick = true;
          row1 = mouseY/100;
          col1 = mouseX/100;
          firstClick = false;
        }
      }
    }
  } else {


    //PROMOTE PAWN
    if (mouseX <400 && mouseX < 400) {
      board[promotionRow][promotionCol] = row2 == 0? 'Q' : 'q';
      promoteTo = row2 == 0? 'Q' : 'q';
    } else if (mouseX > 400 && mouseY<400) {
      board[promotionRow][promotionCol] = row2 == 0? 'N' : 'n';
      promoteTo = row2 == 0? 'N' : 'n';
    } else if (mouseX < 400 && mouseY>400) {
      board[promotionRow][promotionCol] = row2 == 0? 'B' : 'b';
      promoteTo = row2 == 0? 'B' : 'b';
    } else if (mouseX > 400 && mouseY > 400) {
      board[promotionRow][promotionCol] = row2 == 0? 'R' : 'r'; 
      promoteTo = row2 == 0? 'R' : 'r';
    }

    myServer.write("p" + row2 + "," + col2 + "," + promoteTo);
    pawnIsPromoting = false;
  }
}

void keyReleased() {

  if (keyCode == LEFT && positions.size() > 1) {
    board = positions.get(positions.size()-2);
    positions.remove(positions.size()-1);
    myServer.write("undoMove");
    whiteTurn = !whiteTurn;
  }
}
