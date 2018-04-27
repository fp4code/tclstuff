#!/usr/bin/tcl
# Simple Test file to test all mysqltcl commands and parameters
# please create test database first
# from test.sql file
# >mysql -u root
# >create database uni;
#
# >mysql -u root <test.sql
# please adapt the parameters for mysqlconnect some lines above

load ./.libs/libmysqltcl.so
#load /usr/lib/libmysqltcl.so

set handle [mysqlconnect -user root]

# use implicit database notation
puts "1 rows [mysqlsel $handle {select * from uni.Student}]"
puts "1 Table-col [mysqlcol $handle -current {name type length table non_null prim_key decimals numeric}]"
puts "1 [mysqlnext $handle]"

# Test sel and next functions
mysqluse $handle uni
puts "rows [mysqlsel $handle {select * from Student}]"
puts "Table-col [mysqlcol $handle -current {name type length table non_null prim_key decimals numeric}]"
# result status
puts "cols [mysqlresult $handle cols]"
puts "rows [mysqlresult $handle rows]"

puts [mysqlnext $handle]
puts "current [mysqlresult $handle current]"
puts [mysqlnext $handle]
puts [mysqlnext $handle]
mysqlseek $handle 0
puts "seek to first tupel"
puts [mysqlnext $handle]
puts [mysqlnext $handle]

# Test map function
mysqlsel $handle {select MatrNr,Name
    from Student
    order by Name}

mysqlmap $handle {nr name} {
    if {$nr == {}} continue
    set tempr [list $nr $name]
    puts  [format  "nr %16s  name:%s"  $nr $name]
}

# used for comparing with old version mysqltcl1.53
proc timecheck {} {
    global handle
    set rows [mysqlsel $handle {select * from Student}]
    for {set x 0} {$x<$rows} {incr x} {
	set res  [mysqlnext $handle]
	set nr [lindex $res 0]
	set name [lindex $res 1]
	set sem [lindex $res 2]
    }
    mysqlseek $handle 0
    mysqlmap $handle {nr name sem} {
	if {$nr == {}} continue
	set temos [list $nr $name $sem]
	puts $temos
    }

}

#puts [time timecheck 100]

# Mysqlexec Test
mysqlexec $handle {INSERT INTO Student (Name,Semester) VALUES ('Artur Trzewik',11)}
puts "newid [set newid [mysqlinsertid $handle]]"
mysqlexec $handle "DELETE FROM Student WHERE MatrNr=$newid"

# Metadata querries
puts "Table-col [mysqlcol $handle Student name]"
puts "Table-col [mysqlcol $handle Student {name type length table non_null prim_key decimals numeric}]"

# Info  
puts "databases: [mysqlinfo $handle databases]"
puts "dbname: [mysqlinfo $handle dbname]"
puts "host?: [mysqlinfo $handle  host?]"
puts "tables: [mysqlinfo $handle tables]"
 
# State
puts "state: [mysqlstate $handle]"
puts "state numeric: [mysqlstate $handle -numeric]"


# Error Handling
puts "Error Handling"

# bad handle
catch { mysqlsel bad0 {select * from Student} }
puts $errorInfo
# bad querry 
catch { mysqlsel $handle {select * from Unknown} }
puts $errorInfo

# bad command
catch { mysqlexec $handle {unknown command} }
puts $errorInfo

# read after end by sel
set rows [mysqlsel $handle {select * from Student}]
for {set x 0} {$x<$rows} {incr x} {
    set res  [mysqlnext $handle]
    set nr [lindex $res 0]
    set name [lindex $res 1]
    set sem [lindex $res 2]
}
puts "afterend [mysqlnext $handle]"
puts "read after end"

#read after end by map
mysqlsel $handle {select * from Student}
mysqlmap $handle {nr name} {
    puts  [format  "nr %16s  name:%s"  $nr $name]
}
mysqlseek $handle 0
catch {
    mysqlmap $handle {nr name ere ere} {
	puts  [format  "nr %16s  name:%s"  $nr $name]
    }
}
puts $errorInfo

puts [mysqlsel $handle {select * from Student} -list]
puts [mysqlsel $handle {select * from Student} -flatlist]

mysqlclose $handle

# Test multi-conection 20 handles

for {set x 0} {$x<20} {incr x} {
    lappend handles [mysqlconnect -user root -db uni]
}
foreach h $handles {
    puts "sel $h"
    mysqlsel $h {select * from Student}
}
mysqlclose
