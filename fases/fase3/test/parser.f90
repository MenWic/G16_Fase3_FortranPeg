module parser
	! initial code from FortranPEG grammar
	type :: node
		integer :: value
		type(node), pointer :: next => null()
	end type node
	
	type(node), pointer :: head => null()
	
	! global var for input
	character(len=:), allocatable :: input

contains

! initial code from FortranPEG grammar
subroutine push(value)
	integer, intent(in) :: value
	type(node), pointer :: tmp
    	if (associated(head)) then
        	allocate(tmp)
	    	tmp%value = value
	    	tmp%next => head
	    	head => tmp
		else
			allocate(head)
			head%value = value
			head%next => null()
		end if	
end subroutine push

subroutine show()
	type(node), pointer :: tmp
	tmp => head
	do while (associated(tmp))
		print *, tmp%value
		tmp => tmp%next
	end do
end subroutine show


! parse generated
function parse(inputstr) result(res)
	character(len=:), intent(in), allocatable :: inputstr
	type(node), pointer :: res
	input = inputstr
	
	! call initial rule s function
	res => parses()
end function parse

! rule function s = n:e*
function parses() result(res)
	! type defined by user
	type(node), pointer :: res
	
	! expressions array, type infered from rule e
	integer, allocatable :: s0(:)
	integer, allocatable :: s1(:)
	
	! infered type from rule e
	integer :: s2

	integer :: len
	allocate(s0(0))
	s2 = -999
	s2 = parsee()
	do while (s2 /= -999)
		! rezise array and set s2
		len = size(s0) + 1
		if (allocated(s1)) deallocate(s1)
		allocate(s1(len))
		s1(1:size(s0)) = s0
		s1(len) = s2
		if (allocated(s0)) deallocate(s0)
		allocate(s0(len))
		s0(1:len) = s1
		s2 = -999
		
		! get expression if it exists
		s2 = parsee()
	end do
	
	! return the value of sematic actions
	res => f0(s0)
end function parses

! rule function e = n:num sep
function parsee() result(res)
	! type defined by user
	integer :: res
	
	! expression value, type infered from rule num
	integer :: s0, s1
	
	! expression value, type string because actions does not exist
	character(len=:), allocatable :: s2
	
	! value for EOF or error (suggestion: use classes)
	s0 = -999
	s1 = -999
	
	s2 = ""
	s1 = parsenum()
	if (s1 /= -999) then
		s2 = parsesep()
		if (s2 /= "") then
			! return the value of sematic actions
			s0 = f1(s1)
		end if
	end if
	res = s0
end function parsee

! rule function num = n:[0-9]+
function parsenum() result(res)
	! type defined by user
	integer :: res
	
	! individual lexeme extraction (You can use nextsym())
	integer :: cursor
	character(len=:), allocatable :: s0
	s0 = ""
	cursor = 1
	
	if (cursor > len(input)) then
		res = -999
		return
	end if
	
	do while (cursor <= len_trim(input) .and. (((iachar(input(cursor:cursor)) >= iachar("0") .and. &
		iachar(input(cursor:cursor)) <= iachar("9")))))
		cursor = cursor + 1
	end do
	s0 = input(1:cursor-1)
	input = input(cursor:)
	
	! return the value of sematic actions
	res = f2(s0)
end function parsenum

! rule function sep = "\n"
function parsesep() result(res)
	! res is lexeme, type string because actions does not exist
	character(len=:), allocatable :: res
	
	! individual lexeme extraction (You can use nextsym())
	integer :: cursor

	res = ""
	cursor = 1

	if (cursor > len(input)) return
		if (cursor <= len_trim(input) .and. (char(10) == input(cursor:cursor + 0 ))) then 
			cursor = cursor + 1
		end if
	res = input(1:cursor-1)
	input = input(cursor:)
end function parsesep

! semantic action function from rule s
function f0(n) result(res)
	! type generated from infered type of labels
	integer, dimension(:), intent(in) :: n
	
	! code from user in semantic actions
	type(node), pointer :: res	
	integer i
	do i = 1, size(n)
		call push(n(i))
	end do
	res => head
end function f0

! semantic action function from rule e
function f1(n) result(res)
	! type generated from infered type of labels
	integer, intent(in) :: n
	
	! code from user in semantic actions
	integer :: res
	res = n
end function f1

! semantic action function from rule num
function f2(n) result(res)
	! type generated from infered type of labels
	character(len=:), allocatable :: n
	
	! code from user in semantic actions
	integer :: res
	read(n, *) res
end function f2

end module parser
