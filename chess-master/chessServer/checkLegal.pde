String whitePieces = "RNBQKP";
  String blackPieces = "rnbqkp";

boolean checkLegal(int r1, int c1, int r2, int c2) {

  //preconditions

  if ((r2 == r1 && c2 == c1)) return false;
  if (whitePieces.contains(str(board[r2][c2]))) return false;

  //ROOK========================================================
  if (board[r1][c1] == 'R' || board[r1][c1] == 'r') {
    boolean ans = true;

    if (r2 - r1 == 0 || c2 - c1 == 0)
      ans = true;
    else
      ans = false;

    // CHECK BLOCKING
    int i = r2-r1 == 0 ? Math.min(r1, r2): Math.min(r1, r2) +1;
    int j = c2-c1 == 0 ? Math.min(c1, c2):Math.min(c1, c2) +1;

    if (r2 - r1 == 0) {

      while (j < Math.max(c1, c2)) {
        if (board[i][j] != ' ')
          ans = false;
        //        System.out.println(i);
        //        System.out.println(j);

        j++;
      }
    } else if (c2 - c1 == 0) {
      while (i < Math.max(r1, r2)) {

        if (board[i][j] != ' ')
          ans = false;
        //        System.out.println(i);
        //        System.out.println(j);
        i++;
      }
    }

    return ans;
  }

  //BISHOP===============================================================
  if (board[r1][c1] == 'b' || board[r1][c1] == 'B') {
    boolean ans = true;
    if (Math.abs(r2-r1) == Math.abs(c2-c1)) {
      ans = true;
    } else ans = false;


    int i = r1;
    int j = c1;

    if (r2>r1 && c2>c1) {
      i += 1;
      j += 1;
      while (i < r2 && j < c2) {
        if (board[i][j] != ' ') ans = false;
        i++;
        j++;
      }
    }

    if (r2<r1 && c2 >c1) {
      i -=1;
      j +=1;
      while (i > r2 && j < c2) {
        if (board [i][j] != ' ') ans = false;
        i--;
        j++;
      }
    }

    if (r2>r1 && c2<c1) {
      i++;
      j--;
      while ( i < r2 && j > c2) {
        if (board[i][j] != ' ') ans = false;
        i++;
        j--;
      }
    }

    if (r2 < r1 && c2 < c1) {
      i--;
      j--;
      while ( i > r2 && j > c2) {
        if (board[i][j] != ' ') ans = false;
        i--;
        j--;
      }
    }
    return ans;
  }

  //QUEEN========================================================================
  if (board[r1][c1] == 'q' || board[r1][c1] == 'Q') {
    boolean ans = true;

    //See if the move is either vertical or diagonal
    if ((r2 - r1 == 0 || c2-c1 == 0) || (Math.abs(r2-r1) == Math.abs(c2-c1))) ans = true;
    else ans = false;


    int i = c2-c1 == 0 ? Math.min(r1, r2) + 1 : r1;
    int j = (r2 - r1 == 0) ? Math.min(c1, c2) +1: c1;

    //Check blocking vertically
    if (r2 - r1 == 0) {
      while (j < Math.max(c1, c2)) {
        if (board[i][j] != ' ')
          ans = false;
        j++;
      }
    }

    if (c2 - c1 == 0) {
      while (i < Math.max(r1, r2)) {
        if (board[i][j] != ' ')
          ans = false;
        i++;
      }
    }

    //Check blocking diagonally
    if (r2>r1 && c2>c1) {
      i += 1;
      j += 1;
      while (i < r2 && j < c2) {
        if (board[i][j] != ' ') ans = false;
        i++;
        j++;
      }
    }

    if (r2<r1 && c2 >c1) {
      i -=1;
      j +=1;
      while (i > r2 && j < c2) {
        if (board [i][j] != ' ') ans = false;
        i--;
        j++;
      }
    }

    if (r2>r1 && c2<c1) {
      i++;
      j--;
      while ( i < r2 && j > c2) {
        if (board[i][j] != ' ') ans = false;
        i++;
        j--;
      }
    }

    if (r2 < r1 && c2 < c1) {
      i--;
      j--;
      while ( i > r2 && j > c2) {
        if (board[i][j] != ' ') ans = false;
        i--;
        j--;
      }
    }

    return ans;
  }

  //KNIGHT=======================================================================
  if (board[r1][c1] == 'n' || board[r1][c1] == 'N') {
    if ((Math.abs(r2-r1)==1 && Math.abs(c2-c1) == 2) || (Math.abs(r2-r1) == 2 && Math.abs(c2-c1) == 1)) {
      return true;
    } else return false;
  } 

  //KING================================================================
  if (board[r1][c1] == 'k' || board[r1][c1] == 'K') {
    if (((r2 - r1 == 0 || c2-c1 == 0) && Math.abs(r2-r1+c2-c1) == 1)|| (Math.abs(r2-r1) == Math.abs(c2-c1) && Math.abs(r2-r1)==1) ) 
      return true;
    else if(board[r1][c1] == 'K' && whiteCanCastleKingSide && r2==7 && c2 == 6 && !blackAttacking(7, 4) && !blackAttacking(7,5) && !blackAttacking (7, 6)){
      return true;
    } else if(board[r1][c1] == 'K' && whiteCanCastleQueenSide && r2==7 && c2 == 2&& !blackAttacking(7, 4) && !blackAttacking(7,3) && !blackAttacking (7, 2)){
      return true;
      
    }else if(board[r1][c1] == 'k' && blackCanCastleKingSide && r2 == 0 && c2 == 6&& !whiteAttacking(0, 4) && !whiteAttacking(0,5) && !whiteAttacking (0, 6)){
      return true;
    }else if(board[r1][c1] == 'k' &&  blackCanCastleQueenSide && r2 == 0 && c2 == 2&& !whiteAttacking(0, 4) && !whiteAttacking(0,3) && !whiteAttacking (0, 2)){
      return true;
    }else 
      return false;
  }

  //PAWN==========================================================
  if (board[r1][c1] == 'P') {
    boolean ans = true;
    if (board[r2][c2] == ' ') {
      if ((r1 - r2 == 1 && c2==c1) 
        || (r1-r2 == 2 && r1 == 6 && c2==c1&& board[5][c1] == ' ')) {
        ans =true;
      } else if (c1 !=7 && r1==3 && board[r1][c1+1] == 'p' && board[1][c1+1] == ' ' &&  positions.get(positions.size()-2)[1][c1+1] == 'p' &&positions.get(positions.size()-2)[3][c1+1] == ' ' && c2-c1 == 1 && r1-r2 ==1) {
        ans = true;
      } else if (c1 !=0 && r1==3 && board[r1][c1-1] == 'p' && board[1][c1-1] == ' ' &&  positions.get(positions.size()-2)[1][c1-1] == 'p' &&positions.get(positions.size()-2)[3][c1-1] == ' ' && c1-c2 == 1 && r1-r2 ==1) {
        ans = true;
      } else 
      ans = false;
    } else {
      if (r1-r2 == 1 && Math.abs(c1-c2) ==1) ans = true;
      else ans = false;
    }
    return ans;
  }

  if (board[r1][c1] == 'p') {
    boolean ans = true;
    if (board[r2][c2] == ' ') {
      if ((r2 - r1 == 1 && c2== c1) 
        || (r2-r1 == 2 && r1==1 && c2==c1&& board[3][c1] == ' ')) {
        ans =true;
      } else if ( c1 !=7 && r1==4 && board[r1][c1+1] == 'P' && board[6][c1+1] == ' ' &&  positions.get(positions.size()-2)[6][c1+1] == 'P' &&positions.get(positions.size()-2)[4][c1+1] == ' ' && c2-c1 == 1 && r2-r1 ==1) {
        ans = true;
      } else if (c1 !=0 && r1==4 && board[r1][c1-1] == 'P' && board[6][c1-1] == ' ' &&  positions.get(positions.size()-2)[6][c1-1] == 'P' &&positions.get(positions.size()-2)[4][c1-1] == ' ' && c1-c2 == 1 && r2-r1 ==1) {
        ans = true;
      } else 
      ans = false;
    } else {
      if (r2-r1 == 1 && Math.abs(c1-c2) ==1) ans = true;
      else ans = false;
    }
    return ans;
  }


  return false;
}

boolean whiteAttacking(int r, int c){
  
  for(int i = 0; i < 8; i++){
    for(int j =0; j < 8; j++){
      if(whitePieces.contains(str(board[i][j])) && checkLegal(i, j, r, c))
        return true;
    }
  }
  return false;
}

boolean blackAttacking(int r, int c){
  
  for(int i = 0; i < 8; i++){
    for(int j =0; j < 8; j++){
      if(blackPieces.contains(str(board[i][j])) && checkLegal(i, j, r, c))
        return true;
    }
  }
  return false;
}
