module parser
    implicit none

contains

subroutine parse(input)
    character(len=:), intent(inout), allocatable :: input
    do while (len(input) > 0)
        print *, nextsym(input)
    end do
end subroutine parse

function nextsym(input) result(lexval)
    character(len=:), intent(inout), allocatable :: input
    character(len=:), allocatable :: lexval
    integer :: i
    logical :: is_int, is_str, is_space

    lexval = ""
    i = 1
    is_int = .false.
    is_str = .false.
    is_space = .false.

    do while (i <= len(input))
        ! integer
        if (input(i:i) >= '0' .and. input(i:i) <= '9') then
            if (is_str) then
                input = input(i:)
                lexval = lexval // ' - string'
                return
            else if (is_space) then
                input = input(i:)
                lexval = lexval // ' - whitespace'
                return
            end if
            is_int = .true.
            lexval = lexval // input(i:i)
        
        ! string
        else if (input(i:i) >= 'A' .and. input(i:i) <= 'Z' .or. input(i:i) >= 'a' .and. input(i:i) <= 'z') then
            if (is_int) then
                input = input(i:)
                lexval = lexval // ' - integer'
                return
            else if (is_space) then
                input = input(i:)
                lexval = lexval // ' - whitespace'
                return
            end if
            is_str = .true.
            lexval = lexval // input(i:i)
        
        ! whitespace
        else if (input(i:i) == ' ' .or. input(i:i) <= char(9) .or. input(i:i) == char(10)) then
            if (is_int) then
                input = input(i:)
                lexval = lexval // ' - integer'
                return
            else if (is_str) then
                input = input(i:)
                lexval = lexval // ' - string'
                return
            else if (is_space) then
                input = input(i:)
                lexval = lexval // ' - whitespace'
                return
            end if
            is_space = .true.
            if (input(i:i) == ' ') lexval = lexval // '_'
            if (input(i:i) == char(9)) lexval = lexval // '\t'
            if (input(i:i) == char(10)) lexval = lexval // '\n'
        
        ! error
        else
            if (is_int) then
                input = input(i:)
                lexval = lexval // ' - integer'
                return
            else if (is_str) then
                input = input(i:)
                lexval = lexval // ' - string'
                return
            end if
            lexval = input(i:i) // " - error"
            input = input(i+1:)
            return
        end if

        i = i + 1
    end do

    ! eof
    input = input(i:)
    if (is_int) then
        input = input(i:)
        lexval = lexval // ' - integer'// char(10) //' \0 - eof'
        return
    else if (is_space) then
        input = input(i:)
        lexval = lexval // ' - whitespace'// char(10) //' \0 - eof'
        return
    else if (is_str) then
        input = input(i:)
        lexval = lexval // ' - string'// char(10) //' \0 - eof'
        return
    end if
    
end function nextsym

end module parser