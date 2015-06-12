
class Minefield
  attr_reader :row_count, :column_count

  
  def initialize(row_count, column_count, mine_count)
    @column_count = column_count
    @row_count = row_count

    @cleared = []
    @mined = []
    @n_adjacent = []

    @cleared = Array.new(column_count) {Array.new(row_count, false)}
    @mined = Array.new(column_count) {Array.new(row_count, false)}
    @n_adjacent = Array.new(column_count) {Array.new(row_count, 0)}

    @pending_adjacents = []
    
    # you can access this array using array[x][y]    

    sprinkle_mines_randomly(mine_count)

    compose_n_adjacent

=begin    
    mined_string = @mined.to_s
    mined_string.gsub!(/],/,"],\n")
    mined_string.gsub!(/true/, "1")
    mined_string.gsub!(/false/, "0")

    n_adjacent_string = @n_adjacent.to_s
    n_adjacent_string.gsub!(/],/,"],\n")

    puts " @mined = "
    puts " #{mined_string}"
    puts ""
    puts " @n_adjacent = "
    puts " #{n_adjacent_string}"
    puts ""
=end
    
  end

  def n_mines(i, j)

      cells = adjacent_cells(i, j)
      sum = 0
      
      cells.each do |coord|
        sum += 1 if @mined [coord[0]][coord[1]] == true
      end

      return sum
  end
  
  def compose_n_adjacent
    @mined.each_with_index do |array, i|
      array.each_with_index do |number, j|
        @n_adjacent[i][j] = n_mines(i,j)
      end
    end
  end

  
  def sprinkle_mines_randomly(mine_count)
    mines = []
    mined = 0
    while mined < mine_count
      x = rand(row_count)
      y = rand(column_count)
      unless mines.include?([x,y])
        mines << [x, y]
        mined += 1
      end
    end
    mines.each do |xy|
      x = xy[0]
      y = xy[1]
      @mined[x][y] = true
    end

    # puts "@mined:   \n#{@mined}"
  end

  def adjacent_cells(i, j)
    # return an array [[3,5], [4,5]] all adjacent cells coordinates

    i_limit = @cleared[0].length - 1
    j_limit = @cleared.length - 1
    
    adjacent = []

    adjacent << [i-1, j-1]   unless ( i - 1 < 0) || ( j -1 < 0) 
    adjacent << [i-1, j]     unless ( i - 1 < 0) 
    adjacent << [i - 1, j + 1] unless ( i - 1 < 0) || (j + 1 > j_limit)
    adjacent << [ i, j - 1]  unless  ( j - 1 < 0) 
    adjacent << [ i, j + 1]  unless (j + 1 > j_limit)
    adjacent << [ i + 1, j - 1] if ( i + 1 <= i_limit) && ( j - 1 >= 0) 
    adjacent << [ i + 1, j] if ( i + 1 <= i_limit)
    adjacent << [ i + 1, j + 1]     if  ( i + 1 <= i_limit) && (j + 1 <= j_limit) 

    return adjacent

  end

  def cell_cleared?(row, col)
    @cleared[row][col]
  end

  # Uncover the given cell. If there are no adjacent mines to this cell
  # it should also clear any adjacent cells as well. This is the action
  # when the player clicks on the cell.
  
  #  should be done recursively - e.g. searching for all directions
  #   following until a limit is hit (no zero-adjacents)
  
  def clear_unused(row, col)

    @cleared[row][col] = true

    if @n_adjacent[row][col]== 0

      cells = adjacent_cells(row, col)
      
      cells.each do |coord|
        @cleared[coord[0]][coord[1]] = true
      end
    end

  end


  def adjacent_zero_cells(i, j)

    adjacent = adjacent_cells(i, j)
    ret_array = []

    adjacent.each do |coord|
      ret_array << coord if @n_adjacent[coord[0]][coord[1]] == 0

    end

    ret_array
  end

#   
#   Flood-fill (node, target-color, replacement-color):
#  1. If target-color is equal to replacement-color, return.
#  2. If the color of node is not equal to target-color, return.
#  3. Set the color of node to replacement-color.
#  4. Perform Flood-fill (one step to the west of node, target-color, replacement-color).
#     Perform Flood-fill (one step to the east of node, target-color, replacement-color).
#     Perform Flood-fill (one step to the north of node, target-color, replacement-color).
#     Perform Flood-fill (one step to the south of node, target-color, replacement-color).
#  5. Return.
#                         
#  

  def clear_adjacent_cells(row, col)
    
    cells = adjacent_cells(row, col)
    #puts "Debug: cell: #{row}, #{col} is clearing adjacent_cells: #{cells.to_s}"
 
    cells.each do |coord|

   #   puts "Debug: cell: #{coord[0]}, #{coord[1]} adjacent to #{row}, #{col} is being examined"
      
      if @mined[coord[0]][coord[1]] == false

        #puts "Debug: cell: #{coord[0]}, #{coord[1]} is being cleared"

        @cleared[coord[0]][coord[1]] = true  
      end
    end
    
  end

  def clear(row, col)

    @pending_adjacents = []

    # if first cell is non-zero, it is a boundary, do not do recursive clear
    if( @n_adjacent[row][col] != 0)
      @cleared[row][col] = true
      @pending_adjacents << [row, col]
    else      
      clear_recursive(row,col)
    end

    clear_adjacent_queue(@pending_adjacents)
    
  end

  def clear_adjacent_queue(pending_adjacents)
    if pending_adjacents == nil
      return
    else
      pending_adjacents.each do |cell|
        clear_adjacent_cells(cell[0], cell[1])
      end
    end
  end
  
  def clear_recursive(row, col)

        
    if( @n_adjacent[row][col] == 0)  # target this to clear

      #puts "Debug: cell: #{row}, #{col} post target this to clear"
      
      if (@cleared[row][col] == true)
        # puts "Debug: cell: #{row}, #{col} is already cleared, returning"
        return
      end

      @cleared[row][col] = true

      @pending_adjacents << [row, col]
      @pending_adjacents.uniq!          # tune this, might be slow
      
      i_limit = @cleared[0].length - 1
      j_limit = @cleared.length - 1
      i = row
      j = col

      clear_recursive(i - 1, j + 1) unless ( i - 1 < 0) || (j + 1 > j_limit) 
      clear_recursive(i, j - 1)  unless  ( j - 1 < 0)  # West
      clear_recursive(i, j + 1)  unless (j + 1 > j_limit)  # East
      clear_recursive(i + 1, j - 1) if ( i + 1 <= i_limit) && ( j - 1 >= 0)  
      clear_recursive(i-1, j-1)  unless ( i - 1 < 0) || ( j -1 < 0)          
      clear_recursive(i-1, j)     unless ( i - 1 < 0)  # North
      clear_recursive(i + 1, j ) if ( i + 1 <= i_limit)  #South
      clear_recursive( i + 1, j + 1)     if  ( i + 1 <= i_limit) && (j + 1 <= j_limit)

      return

    end

  end
  
    
  
  # Check if any cells have been uncovered that also contained a mine. This is
  # the condition used to see if the player has lost the game.
  def any_mines_detonated?

    @cleared.each_with_index do |array, i|
      array.each_with_index do |number, j|
        if @cleared[i][j] == true
          if @mined[i][j] == true
            return true              # cleared intersect mined -> kaboom!
          end
        end
      end
    end
    false
  end

  # Check if all cells that don't have mines have been uncovered. This is the
  # condition used to see if the player has won the game.
  def all_cells_cleared?
     @cleared.each do |array|
       if array.include?(false)
         return false
       end
     end
     true
  end

  # Returns the number of mines that are surrounding this cell (maximum of 8).
  def adjacent_mines(row, col)
    @n_adjacent[row][col]
  end

  # Returns true if the given cell contains a mine, false otherwise.
  def contains_mine?(row, col)
    @mined[row][col]
  end
end

