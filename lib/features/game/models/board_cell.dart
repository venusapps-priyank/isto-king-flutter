class BoardCell {
  const BoardCell(this.col, this.row);

  final int col;
  final int row;

  @override
  bool operator ==(Object other) {
    return other is BoardCell && other.col == col && other.row == row;
  }

  @override
  int get hashCode => Object.hash(col, row);
}
