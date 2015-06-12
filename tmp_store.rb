
  def clear(row, col)


    if( @n_adjacent[row][col] == 0)  # target this to clear

      puts "Debug: cell: #{row}, #{col} post target this to clear"
      
      if (@cleared[row][col] == true)
        puts "Debug: cell: #{row}, #{col} is already cleared, returning"
            #experiment #3 : clear here
        return
      end

      @cleared[row][col] = true

      i_limit = @cleared[0].length - 1
      j_limit = @cleared.length - 1
      i = row
      j = col

      #      clear_recursive(i-1, j-1)  unless ( i - 1 < 0) || ( j -1 < 0) 
      clear(i-1, j)     unless ( i - 1 < 0) 
      #      clear_recursive(i - 1, j + 1) unless ( i - 1 < 0) || (j + 1 > j_limit)
      clear(i, j - 1)  unless  ( j - 1 < 0) 
      clear(i, j + 1)  unless (j + 1 > j_limit)
      #      clear_recursive(i + 1, j - 1) if ( i + 1 <= i_limit) && ( j - 1 >= 0) 
      clear(i + 1, j ) if ( i + 1 <= i_limit)
      #      clear_recursive( i + 1, j + 1)     if  ( i + 1 <= i_limit) && (j + 1 <= j_limit) 

      # experiment #1:  do the total clear here
      #    this is not doing one cell's (the lasts?) adjacents
      
       cells = adjacent_cells(row, col)
       puts "Debug: cell: #{row}, #{col} is clearing adjacent_cells: #{cells.to_s}"
 
       cells.each do |coord|
         @cleared[coord[0]][coord[1]] = true
       end
 
      return

    else
      return
    end
  end
