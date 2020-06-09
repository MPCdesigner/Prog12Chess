import processing.net.*;
color lightbrown = #FFFFC3;
color darkbrown  = #D8864E;
PImage wrook, wbishop, wknight, wqueen, wking, wpawn;
PImage brook, bbishop, bknight, bqueen, bking, bpawn;
boolean firstClick;
int row1, col1, row2, col2;
boolean whiteTurn = true;
Client myClient;
ArrayList<char[][]> positions;

boolean whiteCanCastleQueenSide = true;
boolean blackCanCastleQueenSide = true;
boolean whiteCanCastleKingSide = true;
boolean blackCanCastleKingSide = true;

int whiteTimer = 5*60;
int blackTimer = 5*60;
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

  myClient = new Client(this, "127.0.0.1", 1234);

  positions = new ArrayList<char[][]>();
}

void draw() {
  drawBoard();
  drawPieces();
  receiveMove();

  //Timer
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
  highlightLegalMoves(row1, col1);
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

  if (myClient.available() > 0) {
    String incoming = myClient.readString();

    //RECIEVE TIMER 
    if (incoming.substring(0, 2).equals("wt")) 
      whiteTimer = int(incoming.substring(2));
    if (incoming.substring(0, 2).equals("bt")) 
      blackTimer = int(incoming.substring(2));

    //RECIEVE UNDO MOVE
    if (incoming.equals("undoMove")) {
      board = positions.get(positions.size()-2);
      positions.remove(positions.size()-1);
      whiteTurn = !whiteTurn;
    }

    //RECIEVE MOVE
    if (incoming.substring(0, 1).equals("m")) {

      int r1 = int(incoming.substring(1, 2));
      int c1 = int(incoming.substring(3, 4));
      int r2 = int(incoming.substring(5, 6));
      int c2 = int(incoming.substring(7, 8));

      //en passent exception
      if (board[r1][c1] == 'P' && board[r2][c2] == ' ' && Math.abs(c1-c2) ==1) {
        board[r1][c2] = ' ';
      }
      //check if move affects castling priveleges
      if (r1 == 7 && c1==0)
        whiteCanCastleQueenSide = false;
      else if (r1 == 7 && c1 == 7)
        whiteCanCastleKingSide = false;
      else if (r1 == 7 && c1 ==4) {
        whiteCanCastleKingSide = false;
        whiteCanCastleQueenSide = false;
      }
      
        //castling exception
        if(board[r1][c1] == 'K' && c2-c1 == 2){
          board[7][5] = board[7][7];
          board[7][7] = ' ';
        } else if(board[r1][c1] == 'K' && c2-c1 == -2){
          board[7][3] = board[7][0];
          board[7][0] = ' ';
        }
      
      //normal move
      board[r2][c2] = board[r1][c1];
      board[r1][c1] = ' ';
      whiteTurn = false;
      //record the position
      char[][] temp = new char[8][8];
      for (int i = 0; i < 8; i++)
        for (int j = 0; j < 8; j++)
          temp[i][j]=board[i][j];
      positions.add(temp);
    }
  }
}
void mouseReleased() {
  if (!whiteTurn) {
    if (firstClick) {
      row1 = mouseY/100;
      col1 = mouseX/100;
      firstClick = false;
    } else {
      row2 = mouseY/100;
      col2 = mouseX/100;
      if (checkLegal(row1, col1, row2, col2)) {

        //en passent exception
        if (board[row1][col1] == 'p' && board[row2][col2] == ' ' && Math.abs(col1-col2) ==1) {
          board[row1][col2] = ' ';
        }

        //check if move affects castling priveleges
        if (row1 == 0 && col1 == 0)
          blackCanCastleQueenSide = false;
        else if (row1==0 && col1 == 7)
          blackCanCastleKingSide = false;
        else if (row1==0 && col1 == 4) {
          blackCanCastleKingSide = false;
          blackCanCastleQueenSide = false;
        }

        //castling exception
        if(board[row1][col1] == 'k' && col2-col1 == 2){
          board[0][5] = board[0][7];
          board[0][7] = ' ';
        } else if(board[row1][col1] == 'k' && col2-col1 == -2){
          board[0][3] = board[0][0];
          board[0][0] = ' ';
        }

        //normal move
        board[row2][col2] = board[row1][col1];
        board[row1][col1] = ' ';
        myClient.write("m" + row1+"," +col1+"," + row2 +"," +col2);
        whiteTurn = true;
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
}
void highlightLegalMoves(int r1, int c1) {
  for (int i = 0; i < 8; i++) {
    for (int j = 0; j < 8; j++) {
      if (checkLegal(r1, c1, i, j)&& blackPieces.contains(str(board[row1][col1]))) {
        fill(255, 255, 0, 150);
        stroke(0);
        strokeWeight(0);
        rect(j*100, i*100, 100, 100);
      }
    }
  }
}
void keyReleased() {

  if (keyCode == LEFT && positions.size() > 1) {
    board = positions.get(positions.size()-2);
    positions.remove(positions.size()-1);
    myClient.write("undoMove");
    whiteTurn = !whiteTurn;
  }
}
